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
  uv run typst_pyexec.py -w report.typ       live preview (opens typst watch)
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

def parse_options(block_lines: list[str]) -> tuple[dict, list[str]]:
    """
    Scan the lines at the top of a ```python block for %| options.

    Returns:
        options   – dict with keys "execute" and "echo" (both bool, default True)
        remaining – the actual code lines after stripping option/comment lines
    """
    options = {"execute": True, "echo": True}
    code_start = 0

    for i, line in enumerate(block_lines):
        stripped = line.strip()

        if stripped.startswith("%|"):
            # e.g.  "%| execute: false"
            payload = stripped[2:].strip()          # "execute: false"
            if ":" in payload:
                key, _, raw_value = payload.partition(":")
                key   = key.strip().lower()
                value = raw_value.strip().lower()
                if key in options:
                    options[key] = value not in ("false", "no", "0", "off")
            code_start = i + 1

        elif stripped.startswith("%"):
            # Bare Typst-style "%" comment line at the top – skip silently.
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
    """Wrap plain text in a Typst #raw(…) call, ready to paste into a .typ file."""
    # Escape backslashes and double-quotes so they survive inside a Typst string.
    escaped = text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
    if lang:
        return f'#raw("{escaped}", block: true, lang: "{lang}")\n\n'
    return f'#raw("{escaped}", block: true)\n\n'


def _is_relative_typst_path(path_text: str) -> bool:
    """True when a Typst path should be remapped for generated files."""
    return not (
        path_text.startswith("/")
        or path_text.startswith("./")
        or path_text.startswith("../")
        or path_text.startswith("@")
        or "://" in path_text
    )


def rewrite_relative_paths(line: str) -> str:
    """
    Remap relative paths in #import/#include lines for files generated under
    .typst_pyexec, so they still resolve to sibling files in report/.
    """
    stripped = line.lstrip()
    if not (stripped.startswith("#import") or stripped.startswith("#include")):
        return line

    first_quote = line.find('"')
    if first_quote == -1:
        return line
    second_quote = line.find('"', first_quote + 1)
    if second_quote == -1:
        return line

    path_text = line[first_quote + 1:second_quote]
    if not _is_relative_typst_path(path_text):
        return line

    remapped = "../" + path_text
    return line[: first_quote + 1] + remapped + line[second_quote:]


# ── Execution ─────────────────────────────────────────────────────────────────

def execute_block(
    code: str,
    *,
    namespace: dict,
    block_index: int,
    abs_image_dir: Path,   # absolute directory to write PNG files
    rel_image_dir: Path,   # same directory but relative to the .typ output file
) -> str:
    """
    Run *code* inside *namespace*, capture its output, save any new matplotlib
    figures, and return the Typst markup to insert after the code block.

    Execution errors are non-fatal: the traceback is embedded as a text block
    so the rest of the document still compiles.
    """
    stdout_buf = io.StringIO()
    stderr_buf = io.StringIO()
    open_figs  = set(plt.get_fignums()) if plt else set()

    # plt.show() is a no-op in headless (Agg) mode: replace it with a no-op so
    # the FigureCanvasAgg warning is never raised.  Figures are captured below
    # via plt.get_fignums() instead of being "shown" interactively.
    if plt:
        plt.show = lambda *a, **kw: None

    try:
        with redirect_stdout(stdout_buf), redirect_stderr(stderr_buf):
            exec(compile(code, f"<block {block_index}>", "exec"), namespace)
    except Exception:
        # Non-fatal: show the traceback inline instead of aborting.
        error_text = traceback.format_exc()
        print(f"[typst-pyexec] WARNING: block {block_index} raised an exception "
              f"(shown in document).", file=sys.stderr)
        return as_raw_block(error_text.strip(), lang="text")

    parts = []

    # ---- Text output ----
    output = stdout_buf.getvalue()
    errors = stderr_buf.getvalue()
    combined = output
    if errors:
        combined = (combined + "\n[stderr]\n" + errors) if combined else ("[stderr]\n" + errors)
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
            # Typst resolves paths relative to the .typ file that imports them.
            rel_path = (rel_image_dir / fname).as_posix()
            parts.append(f'#figure(image("{rel_path}"))\n\n')

    return "".join(parts)


def block_signature(options: dict, code: str) -> str:
    """Stable hash used to detect whether a block changed."""
    payload = json.dumps(
        {
            "execute": options["execute"],
            "echo": options["echo"],
            "code": code,
        },
        sort_keys=True,
        ensure_ascii=True,
    )
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def load_cache(cache_path: Path) -> dict:
    """Load cache data from disk; return an empty cache if unavailable."""
    if not cache_path.exists():
        return {"signatures": [], "rendered": []}
    try:
        data = json.loads(cache_path.read_text(encoding="utf-8"))
        signatures = data.get("signatures", [])
        rendered = data.get("rendered", [])
        if isinstance(signatures, list) and isinstance(rendered, list):
            return {"signatures": signatures, "rendered": rendered}
    except Exception:
        pass
    return {"signatures": [], "rendered": []}


def save_cache(cache_path: Path, signatures: list[str], rendered: list[str]) -> None:
    """Persist block signatures and rendered output for reuse on next run."""
    cache_path.write_text(
        json.dumps({"signatures": signatures, "rendered": rendered}, ensure_ascii=True),
        encoding="utf-8",
    )


# ── Preprocessing pipeline ───────────────────────────────────────────────────

def preprocess(source: Path, output: Path, image_dir: Path, cache_path: Path) -> None:
    """
    Read *source*, execute all ```python blocks, and write the result to *output*.

    *image_dir* is a path relative to *output* where generated PNG figures are
    stored.
    """
    lines = source.read_text(encoding="utf-8").splitlines(keepends=True)
    segments: list[tuple[str, object]] = []
    blocks: list[dict] = []
    block_idx = 0
    i = 0

    abs_image_dir = output.parent / image_dir

    while i < len(lines):
        # Pass through every line that is not an opening Python fence.
        if lines[i].strip() != "```python":
            segments.append(("text", rewrite_relative_paths(lines[i])))
            i += 1
            continue

        # ---- Opening fence found ----
        block_idx += 1
        i += 1  # move past the opening fence

        raw_lines = []
        while i < len(lines) and lines[i].strip() != "```":
            raw_lines.append(lines[i])
            i += 1

        if i >= len(lines):
            raise SyntaxError(f"Unclosed ```python block #{block_idx} in {source}")

        i += 1  # move past the closing fence

        opts, code = parse_options(raw_lines)
        blocks.append({"index": block_idx, "options": opts, "code": code})
        segments.append(("block", len(blocks) - 1))

    signatures = [block_signature(b["options"], b["code"]) for b in blocks]
    cached = load_cache(cache_path)

    full_cache_hit = (
        signatures == cached["signatures"]
        and len(cached["rendered"]) == len(blocks)
    )

    if full_cache_hit:
        rendered_blocks = cached["rendered"]
        print("[typst-pyexec] Reusing cached Python outputs (no code changes).")
    else:
        namespace = {"__name__": "__main__"}
        rendered_blocks: list[str] = []
        for block in blocks:
            rendered = ""
            opts = block["options"]
            code = block["code"]
            idx = block["index"]

            if opts["echo"]:
                rendered += as_raw_block(code.rstrip("\n"), lang="python")

            if opts["execute"] and code.strip():
                rendered += execute_block(
                    code,
                    namespace=namespace,
                    block_index=idx,
                    abs_image_dir=abs_image_dir,
                    rel_image_dir=image_dir,
                )

            rendered_blocks.append(rendered)

        save_cache(cache_path, signatures, rendered_blocks)

    result: list[str] = []
    for kind, payload in segments:
        if kind == "text":
            result.append(str(payload))
        else:
            block_pos = int(payload)
            result.append(rendered_blocks[block_pos])

    output.write_text("".join(result), encoding="utf-8")


# ── Typst integration ─────────────────────────────────────────────────────────

def compile_pdf(typ: Path, pdf: Path, root: Path) -> None:
    """Run `typst compile <typ> <pdf>` and raise on failure."""
    proc = subprocess.run(
        ["typst", "compile", str(typ), str(pdf), "--root", str(root)],
        check=False,
    )
    if proc.returncode != 0:
        raise RuntimeError("typst compile failed.")


def watch_preview(source: Path, generated: Path, pdf: Path,
                  image_dir: Path, cache_path: Path, interval: float) -> None:
    """
    Preprocess once, then hand off to `typst watch` for live rendering while
    polling the source directory for changes.  On every detected change the
    source is re-preprocessed, and `typst watch` picks up the updated
    intermediate file automatically.
    """
    watch_root = source.parent.resolve()
    print("[typst-pyexec] Initial preprocessing…")
    preprocess(source, generated, image_dir, cache_path)

    typst_proc = subprocess.Popen(
        ["typst", "watch", str(generated), str(pdf), "--root", str(source.parent)]
    )

    # These files are written by us – do not treat them as user edits.
    ignore_files = {generated.resolve(), pdf.resolve()}
    ignore_dirs  = {(generated.parent / image_dir).resolve()}

    def snapshot() -> dict:
        mtimes = {}
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
                preprocess(source, generated, image_dir, cache_path)
                last = snapshot()
    finally:
        if typst_proc.poll() is None:
            typst_proc.terminate()
            try:
                typst_proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                typst_proc.kill()


# ── CLI ───────────────────────────────────────────────────────────────────────

def intermediate_path(temp_root: Path, source: Path, *, debug: bool) -> Path:
    """Return the path for the intermediate generated .typ file."""
    if debug:
        return temp_root / f"{source.stem}.generated.typ"
    return temp_root / f"{source.stem}.pyexec.typ"


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="typst_pyexec.py",
        description="Execute Python blocks in a Typst document and produce a PDF.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "examples:\n"
            "  uv run typst_pyexec.py -c report.typ       compile → report.pdf\n"
            "  uv run typst_pyexec.py -w report.typ       live preview\n"
            "  uv run typst_pyexec.py -c -d report.typ    compile, keep intermediate .typ\n"
        ),
    )

    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("-c", "--compile", action="store_true", help="Compile to PDF once.")
    mode.add_argument("-w", "--watch",   action="store_true", help="Live preview via typst watch.")

    parser.add_argument("input",         type=Path,  help="Source .typ file.")
    parser.add_argument("-d", "--debug", action="store_true",
                        help="Keep the intermediate generated .typ file.")
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

    generated = intermediate_path(temp_root, source, debug=args.debug)
    image_dir = args.images_dir
    cache_path = temp_root / "block-cache.json"
    pdf       = source.with_suffix(".pdf")

    try:
        if args.compile:
            preprocess(source, generated, image_dir, cache_path)
            print(f"[typst-pyexec] Preprocessed → {generated}")
            compile_pdf(generated, pdf, source.parent)
            print(f"[typst-pyexec] Compiled     → {pdf}")

        elif args.watch:
            watch_preview(source, generated, pdf, image_dir, cache_path, args.interval)

    except KeyboardInterrupt:
        print("\n[typst-pyexec] Stopped.")
    except Exception as exc:
        print(f"[typst-pyexec] ERROR: {exc}", file=sys.stderr)
        return 1
    finally:
        if not args.debug:
            generated.unlink(missing_ok=True)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

