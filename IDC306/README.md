# IDC306 - Biocomputing

## Instructions

Either clone the entire repository:

```
git clone https://github.com/Vortriz/IISERM
```

or download this subfolder by providing `https://github.com/Vortriz/IISERM/tree/main/IDC101` to [download-directory](https://download-directory.github.io) or [DownGit](https://downgit.github.io/#/home).

### Dependencies

If you use Nix, then simply run `nix develop` to drop into a shell with all dependencies. Else, install the following:

- [`uv`](https://docs.astral.sh/uv/#installation)

After that, install all python dependencies:

```
uv sync
```

### Running the codes

#### With marimo (recommended)

To open the notebooks in edit mode:

```
uv run marimo edit
```

To open a particular notebook in run mode (uneditable):

```
uv run marimo run path/to/marimo/notebook.py
```

#### Without marimo

I have also provided Jupyter notebooks for all marimo notebooks, if you prefer that.
