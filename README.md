
## R environment

## R environment

This project uses [`renv`](https://rstudio.github.io/renv/) to manage R package dependencies and ensure reproducibility.

### Setting up the environment

If you are opening this project for the first time, restore the package library with:

```r
install.packages("renv")
renv::restore()
```

This will install the exact package versions recorded in `renv.lock`.

### Updating dependencies

When you install or update packages in this project, record the changes by running:

```r
renv::snapshot()
```

This updates `renv.lock` so others can reproduce the environment.

### Notes

- All packages are installed in the project-specific library (`renv/library/`).
- Do **not** manually edit `renv.lock`.
- To start fresh, you can remove `renv/library/` and run `renv::restore()` again.


## Python environment

This project uses a Python virtual environment to isolate dependencies such as [DVC](https://dvc.org/).

### Setting up the environment

1. Create and activate a virtual environment (using `venv`):

```bash
# Create
python -m venv .venv

# Activate (Linux / macOS)
source .venv/bin/activate

# Activate (Windows)
.venv\Scripts\activate
```

2. Upgrade `pip` and install dependencies:

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

If `requirements.txt` does not exist yet, you can install packages manually (e.g., `pip install dvc`) and then record them:

```bash
pip freeze > requirements.txt
```


### Notes

- The virtual environment directory `.venv/` is excluded from version control (`.gitignore`).
- To leave the environment, run `deactivate`.
- To recreate the environment, delete `.venv/` and repeat the steps above.
