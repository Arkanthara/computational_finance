# Typst Python Execution Plugin

This project now includes a local plugin runner at:

- `report/typst_pyexec.py`

It preprocesses a Typst file and executes fenced Python blocks delimited by:

```python
# code
```

## Block options

Inside a Python block, put options at the top with `%|`:

```python
%| execute: false
%| echo: false
print("hello")
```

Supported options:

- `%| execute: false` stops execution of that block
- `%| echo: false` hides the code block in the final document

Defaults are `execute: true` and `echo: true`.

## Behavior

- One shared Python namespace is used for all executed blocks in source order.
- `print(...)` output is rendered as a raw text block in Typst.
- New matplotlib figures created in a block are saved as PNG files and injected as Typst figures.

## Commands

Run from the folder containing `typst_pyexec.py` and your `.typ` file.

Live preview/watch mode:

```powershell
uv run typst_pyexec.py -w report.typ
```

Compile once to PDF:

```powershell
uv run typst_pyexec.py -c report.typ
```

With `-d`, keep the generated intermediate Typst file:

```powershell
uv run typst_pyexec.py -c -d report.typ
uv run typst_pyexec.py -w -d report.typ
```

Without `-d`, the intermediate `.typ` file is temporary and removed automatically.

Output naming:

- Input: `report.typ`
- PDF output: `report.pdf`
- Intermediate (only with `-d`): `report.generated.typ`

Optional flags:

- `--images-dir img/pyexec` (default) for generated figure files, relative to generated Typst file
- `--interval 1.0` to change source polling frequency in watch mode
