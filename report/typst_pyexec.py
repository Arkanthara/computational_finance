#!/usr/bin/env python3
"""
typst_pyexec.py – Execute Python code blocks embedded in a Typst document.

How it works
------------
The script reads a .typ source file, finds every ```python … ``` fenced block,
executes the code, and replaces the fence with:
  - the source shown as a styled code block  (unless %| echo: false)
  - any printed output shown as a text block  (when execute is true)
  - any matplotlib figures saved and inserted as #figure(image(…))  (idem)

All blocks share one Python namespace, so imports and variables defined in an
earlier block are available in later ones.

Per-block options  (place these lines at the very top of the block)
-----------------
  %| execute: false     skip execution – only show the source
  %| echo:    false     hide the source – only show output

CLI
---
    uv run typst_pyexec.py -c report.typ       compile report.typ → report.pdf
    uv run typst_pyexec.py -w report.typ       watch source; recompile PDF on change
    uv run typst_pyexec.py -c -d report.typ    compile and keep intermediate .typ

Dependencies
------------
  Standard library only.  matplotlib is optional: figures are captured only
  when it is importable.
"""

import argparse
import hashlib
import io
import json
import subprocess
import sys
import textwrap
import time
import traceback
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path

# matplotlib is entirely optional.  When missing, figure capture is disabled.
try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
except ImportError:
    plt = None


# ── Parsing ──────────────────────────────────────────────────────────────────

def parse_options(block_lines: list[str]) -> tuple[dict, str]:
    """
    Scan the lines at the top of a ```python block for ``%|`` options.

    Returns:
        options  – dict with keys ``"execute"`` and ``"echo"`` (both bool, default True)
        code     – the actual code string after stripping option/comment lines
    """
    options = {"execute": True, "echo": True}
    code_start = 0

    for i, line in enumerate(block_lines):
        stripped = line.strip()

        if stripped.startswith("%|"):
            # e.g.  "%| execute: false"
            payload = stripped[2:].strip()
            if ":" in payload:
                key, _, raw_value = payload.partition(":")
                key   = key.strip().lower()
                value = raw_value.strip().lower()
                if key in options:
                    options[key] = value not in ("false", "no", "0", "off")
            code_start = i + 1

        elif stripped.startswith("%"):
            # Bare "%" comment line – skip silently.
            code_start = i + 1

        else:
            # First real code line: stop scanning for options.
            code_start = i
            break

    else:
        # Every line was an option/comment – no code at all.
        code_start = len(block_lines)

    code = textwrap.dedent("".join(block_lines[code_start:]))
    return options, code


# ── Output helpers ────────────────────────────────────────────────────────────

def as_raw_block(text: str, lang: str = "") -> str:
    """Wrap plain text in a Typst ``#raw(…)`` call, ready to paste into a .typ file."""
    escaped = text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
    if lang:
        return f'#raw("{escaped}", block: true, lang: "{lang}")\n\n'
    return f'#raw("{escaped}", block: true)\n\n'


def _is_relative_typst_path(path_text: str) -> bool:
    """Return True when a Typst path needs to be remapped for generated files."""
    return not (
        path_text.startswith("/")
        or path_text.startswith("./")
        or path_text.startswith("../")
        or path_text.startswith("@")
        or "://" in path_text
    )


def rewrite_relative_paths(line: str) -> str:
    """
    Remap relative paths in ``#import``/``#include`` lines.

    Generated files live one directory deeper than the source (.typst_pyexec/),
    so bare relative paths (e.g. ``"template.typ"``) must become ``"../template.typ"``.
    """
    stripped = line.lstrip()
    if not (stripped.startswith("#import") or stripped.startswith("#include")):
        return line

    first_quote  = line.find('"')
    if first_quote == -1:
        return line
    second_quote = line.find('"', first_quote + 1)
    if second_quote == -1:
        return line

    path_text = line[first_quote + 1 : second_quote]
    if not _is_relative_typst_path(path_text):
        return line

    return line[: first_quote + 1] + "../" + path_text + line[second_quote:]


# ── Execution ─────────────────────────────────────────────────────────────────

def execute_block(
    code: str,
    *,
    namespace: dict,
    block_index: int,
    abs_image_dir: Path,
    rel_image_dir: Path,
    quiet: bool,
) -> str:
    """
    Run *code* inside *namespace*, capture its output, save any new matplotlib
    figures, and return the Typst markup to insert after the code block.

    Execution errors are non-fatal: the traceback is embedded as a text block
    so the rest of the document still compiles.

    Args:
        code:           Source code to execute.
        namespace:      Shared ``exec`` namespace (state is preserved across blocks).
        block_index:    1-based index used for figure file names and error messages.
        abs_image_dir:  Absolute directory where PNG figures are written.
        rel_image_dir:  Same directory relative to the generated .typ file
                        (used in ``#figure(image(…))`` calls).
        quiet:          When True, suppress progress messages on stderr.
    """
    stdout_buf = io.StringIO()
    stderr_buf = io.StringIO()
    open_figs  = set(plt.get_fignums()) if plt else set()

    # Replace plt.show() with a no-op so the headless Agg warning is never raised.
    # Figures are captured via plt.get_fignums() after execution instead.
    if plt:
        plt.show = lambda *a, **kw: None

    try:
        with redirect_stdout(stdout_buf), redirect_stderr(stderr_buf):
            exec(compile(code, f"<block {block_index}>", "exec"), namespace)
    except Exception:
        error_text = traceback.format_exc()
        if not quiet:
            print(
                f"[typst-pyexec] WARNING: block {block_index} raised an exception "
                "(shown in document).",
                file=sys.stderr,
            )
        return as_raw_block(error_text.strip(), lang="text")

    parts = []

    # ---- Text output ----
    output = stdout_buf.getvalue()
    errors = stderr_buf.getvalue()
    if errors:
        combined = (output + "\n[stderr]\n" + errors) if output else ("[stderr]\n" + errors)
    else:
        combined = output
    if combined.strip():
        parts.append(as_raw_block(combined.strip(), lang="text"))

    # ---- Matplotlib figures ----
    if plt:
        new_figs = sorted(set(plt.get_fignums()) - open_figs)
        for pos, fig_num in enumerate(new_figs, start=1):
            fname = f"block_{block_index:03d}_fig_{pos:02d}.png"
            abs_image_dir.mkdir(parents=True, exist_ok=True)
            fig = plt.figure(fig_num)
            fig.savefig(abs_image_dir / fname, bbox_inches="tight")
            plt.close(fig)
            rel_path = (rel_image_dir / fname).as_posix()
            parts.append(f'#figure(image("{rel_path}"))\n\n')

    return "".join(parts)


# ── Caching ───────────────────────────────────────────────────────────────────

def block_signature(options: dict, code: str) -> str:
    """Return a stable SHA-256 hex digest that changes when a block's content changes."""
    payload = json.dumps(
        {"execute": options["execute"], "echo": options["echo"], "code": code},
        sort_keys=True,
        ensure_ascii=True,
    )
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def load_cache(cache_path: Path) -> dict:
    """Load cached block data from disk; return an empty cache if unavailable."""
    if not cache_path.exists():
        return {"signatures": [], "rendered": []}
    try:
        data = json.loads(cache_path.read_text(encoding="utf-8"))
        sigs     = data.get("signatures", [])
        rendered = data.get("rendered", [])
        if isinstance(sigs, list) and isinstance(rendered, list):
            return {"signatures": sigs, "rendered": rendered}
    except Exception:
        pass
    return {"signatures": [], "rendered": []}


def save_cache(cache_path: Path, signatures: list[str], rendered: list[str]) -> None:
    """Persist block signatures and rendered output for reuse on the next run."""
    cache_path.write_text(
        json.dumps({"signatures": signatures, "rendered": rendered}, ensure_ascii=True),
        encoding="utf-8",
    )


# ── Preprocessing pipeline ───────────────────────────────────────────────────

def preprocess(
    source: Path,
    output: Path,
    image_dir: Path,
    cache_path: Path,
    *,
    quiet: bool,
) -> None:
    """
    Read *source*, execute all ```python blocks, and write the result to *output*.

    *image_dir* is the path (relative to *output*) where generated PNG figures
    are stored.  If no code has changed since the last run the cached rendered
    output is reused without re-executing any Python.
    """
    lines = source.read_text(encoding="utf-8").splitlines(keepends=True)
    segments: list[tuple[str, object]] = []  # ("text", str) | ("block", int)
    blocks:   list[dict] = []
    block_idx = 0
    i = 0

    abs_image_dir = output.parent / image_dir

    # ---- Parse: split plain text from python fences ----
    while i < len(lines):
        if lines[i].strip() != "```python":
            segments.append(("text", rewrite_relative_paths(lines[i])))
            i += 1
            continue

        block_idx += 1
        i += 1  # skip opening fence

        raw_lines: list[str] = []
        while i < len(lines) and lines[i].strip() != "```":
            raw_lines.append(lines[i])
            i += 1

        if i >= len(lines):
            raise SyntaxError(f"Unclosed ```python block #{block_idx} in {source}")

        i += 1  # skip closing fence

        opts, code = parse_options(raw_lines)
        blocks.append({"index": block_idx, "options": opts, "code": code})
        segments.append(("block", len(blocks) - 1))

    # ---- Per-block cache check ----
    #
    # Strategy: find the *first* block whose signature changed (first_dirty).
    # All blocks before it have identical code/options, so:
    #   - their cached rendered output is reused as-is, AND
    #   - their code is silently re-executed to restore the shared namespace state
    #     (later blocks may depend on variables they define).
    # All blocks from first_dirty onward are fully re-executed and their output
    # is regenerated.
    #
    # This means that editing block N only re-runs blocks N, N+1, N+2, …
    # leaving blocks 0 … N-1 untouched.
    signatures = [block_signature(b["options"], b["code"]) for b in blocks]
    cached     = load_cache(cache_path)

    cached_sigs     = cached["signatures"]
    cached_rendered = cached["rendered"]

    # Determine first_dirty: the index of the first block that changed.
    if (
        len(cached_sigs) == len(blocks)
        and len(cached_rendered) == len(blocks)
        and signatures == cached_sigs
    ):
        # Full cache hit – nothing to do.
        rendered_blocks: list[str] = cached_rendered
        if not quiet:
            print("[typst-pyexec] All blocks cached – skipping Python execution.")
    else:
        # Find first changed index (or 0 if block count changed).
        first_dirty = 0
        if len(cached_sigs) == len(blocks) and len(cached_rendered) == len(blocks):
            for i, (sig, csig) in enumerate(zip(signatures, cached_sigs)):
                if sig != csig:
                    first_dirty = i
                    break

        if not quiet:
            n_clean = first_dirty
            n_dirty = len(blocks) - first_dirty
            if n_clean > 0:
                print(
                    f"[typst-pyexec] {n_clean} block(s) unchanged; "
                    f"re-running block(s) {first_dirty + 1}–{len(blocks)}…"
                )
            else:
                print(f"[typst-pyexec] Running all {len(blocks)} block(s)…")

        # ---- Replay unchanged prefix to restore namespace state ----
        # We execute unchanged blocks silently (output already cached) so that
        # the shared namespace is in the correct state for the dirty blocks.
        namespace: dict = {"__name__": "__main__"}
        if plt:
            plt.show = lambda *a, **kw: None

        for block in blocks[:first_dirty]:
            if block["options"]["execute"] and block["code"].strip():
                try:
                    exec(compile(block["code"], f"<block {block['index']}>", "exec"), namespace)
                except Exception:
                    pass  # error output is already stored in cached_rendered

        # ---- Execute dirty blocks; collect fresh rendered output ----
        fresh_rendered: list[str] = []
        for block in blocks[first_dirty:]:
            rendered = ""
            opts = block["options"]
            code = block["code"]
            idx  = block["index"]

            if opts["echo"]:
                rendered += as_raw_block(code.rstrip("\n"), lang="python")

            if opts["execute"] and code.strip():
                rendered += execute_block(
                    code,
                    namespace=namespace,
                    block_index=idx,
                    abs_image_dir=abs_image_dir,
                    rel_image_dir=image_dir,
                    quiet=quiet,
                )

            fresh_rendered.append(rendered)

        rendered_blocks = list(cached_rendered[:first_dirty]) + fresh_rendered
        save_cache(cache_path, signatures, rendered_blocks)

    # ---- Assemble the output file ----
    result: list[str] = []
    for kind, payload in segments:
        if kind == "text":
            result.append(str(payload))
        else:
            result.append(rendered_blocks[int(payload)])

    output.write_text("".join(result), encoding="utf-8")


# ── Typst integration ─────────────────────────────────────────────────────────

def compile_pdf(typ: Path, pdf: Path, root: Path) -> None:
    """Run ``typst compile <typ> <pdf>`` and raise ``RuntimeError`` on failure."""
    proc = subprocess.run(
        ["typst", "compile", str(typ), str(pdf), "--root", str(root)],
        check=False,
    )
    if proc.returncode != 0:
        raise RuntimeError("typst compile failed.")


def watch_on_save(
    source: Path,
    generated: Path,
    pdf: Path,
    image_dir: Path,
    cache_path: Path,
    interval: float,
) -> None:
    """
    Preprocess once, launch ``typst watch`` for live PDF rendering, then poll
    the source directory for file-system changes.

    When any user-owned file changes, the source is re-preprocessed and
    ``typst watch`` picks up the updated intermediate file automatically.
    Files inside .typst_pyexec/ are excluded from the change detector so that
    a re-preprocessing run does not trigger another one immediately after.
    """
    watch_root = source.parent.resolve()

    print("[typst-pyexec] Initial preprocessing…")
    preprocess(source, generated, image_dir, cache_path, quiet=False)

    typst_proc = subprocess.Popen(
        ["typst", "watch", str(generated), str(pdf), "--root", str(source.parent)]
    )

    # Paths we write ourselves – exclude from the change detector.
    ignore_files = {generated.resolve(), pdf.resolve()}
    ignore_dirs  = {(generated.parent / image_dir).resolve()}

    def snapshot() -> dict[Path, float]:
        """Collect the mtime of every user-owned file under watch_root."""
        mtimes: dict[Path, float] = {}
        for p in watch_root.rglob("*"):
            if not p.is_file():
                continue
            resolved = p.resolve()
            if resolved in ignore_files:
                continue
            if any(resolved.is_relative_to(d) for d in ignore_dirs):
                continue
            try:
                mtimes[resolved] = p.stat().st_mtime
            except OSError:
                pass
        return mtimes

    last = snapshot()
    print(f"[typst-pyexec] Watching {watch_root}  (Ctrl+C to stop)")

    try:
        while True:
            time.sleep(interval)

            if typst_proc.poll() is not None:
                raise RuntimeError("`typst watch` exited unexpectedly.")

            current = snapshot()
            if current != last:
                print("[typst-pyexec] Change detected – re-preprocessing…")
                preprocess(source, generated, image_dir, cache_path, quiet=False)
                last = snapshot()
    finally:
        if typst_proc.poll() is None:
            typst_proc.terminate()
            try:
                typst_proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                typst_proc.kill()


# ── CLI ───────────────────────────────────────────────────────────────────────

def intermediate_path(temp_root: Path, source: Path) -> Path:
    """Return the canonical path for the intermediate generated .typ file."""
    return temp_root / f"{source.stem}.generated.typ"


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="typst_pyexec.py",
        description="Execute Python blocks in a Typst document and produce a PDF.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "examples:\n"
            "  uv run typst_pyexec.py -c report.typ       compile → report.pdf\n"
            "  uv run typst_pyexec.py -w report.typ       watch source; recompile on change\n"
            "  uv run typst_pyexec.py -c -d report.typ    compile and keep generated file\n"
        ),
    )

    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("-c", "--compile", action="store_true", help="Compile to PDF once.")
    mode.add_argument("-w", "--watch",   action="store_true", help="Watch source; recompile PDF on change.")

    parser.add_argument("input",         type=Path,  help="Source .typ file.")
    parser.add_argument("-d", "--debug", action="store_true",
                        help="Keep the intermediate generated .typ file after compilation.")
    parser.add_argument("--images-dir",  type=Path,  default=Path("img"),
                        help="Image output directory inside .typst_pyexec (default: img).")
    parser.add_argument("--interval",    type=float, default=1.0,
                        help="Source-polling interval in seconds for watch mode (default: 1.0).")

    args   = parser.parse_args()
    source = args.input.resolve()

    if not source.exists():
        print(f"[typst-pyexec] ERROR: file not found: {source}", file=sys.stderr)
        return 1
    if source.suffix.lower() != ".typ":
        print("[typst-pyexec] ERROR: input must be a .typ file.", file=sys.stderr)
        return 1

    temp_root = source.parent / ".typst_pyexec"
    temp_root.mkdir(parents=True, exist_ok=True)

    if args.images_dir.is_absolute():
        print("[typst-pyexec] ERROR: --images-dir must be a relative path.", file=sys.stderr)
        return 1

    generated  = intermediate_path(temp_root, source)
    image_dir  = args.images_dir
    cache_path = temp_root / "block-cache.json"
    pdf        = source.with_suffix(".pdf")

    try:
        if args.compile:
            preprocess(source, generated, image_dir, cache_path, quiet=False)
            print(f"[typst-pyexec] Preprocessed → {generated}")
            compile_pdf(generated, pdf, source.parent)
            print(f"[typst-pyexec] Compiled     → {pdf}")

        elif args.watch:
            watch_on_save(source, generated, pdf, image_dir, cache_path, args.interval)

    except KeyboardInterrupt:
        print("\n[typst-pyexec] Stopped.")
    except Exception as exc:
        print(f"[typst-pyexec] ERROR: {exc}", file=sys.stderr)
        return 1
    finally:
        # In watch mode the generated file must stay on disk for typst watch.
        # In compile mode it is cleaned up unless --debug is set.
        if not args.debug and not args.watch:
            generated.unlink(missing_ok=True)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
