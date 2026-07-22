# CASA Environment Stack

The `casa/` directory contains a modular installation of the CASA 6 suite, built on top of conda-forge and NRAO pip repositories. It replaces the old monolithic CASA wrappers by using `pixi`, `apptainer`, and `docker`.

## Environments

The `pixi.toml` provides several variants (e.g., `casa674-py312`, `casa675-py312`).
There is also a specialized pipeline environment (`casa674-py312-pipeline`) that directly pulls the ALMA/VLA pipeline source from the Bitbucket repository.

## Local Setup & Usage

To resolve the lockfile and download the dependencies:

```bash
cd casa/
pixi install
```

### Running Commands

Pixi automatically injects the necessary environment variables (like suppressing noisy Python 3.12 `SyntaxWarning`s from legacy CASA code).

Run the standard CASA shell:

```bash
pixi run casa
```

Run CASA across MPI processes (default 4):

```bash
# Default (4 processes)
pixi run casampi

# Dynamic allocation (e.g., 8 processes)
CASA_MPI_NPROCS=8 pixi run casampi
```

**Tip (Silencing Worker Spam):** If you run `casampi` interactively, every worker will print the IPython welcome banner to your terminal. To run cleanly (especially on the grid), pass a python script via the `-c` flag or supply a `.py` file. This automatically disables the IPython initialization banners across all workers:

```bash
CASA_MPI_NPROCS=4 pixi run casampi --nogui --nologger -c "print('MPI Execution Complete!')"
```

To run a specific environment (like the pipeline):

```bash
pixi run -e casa674-py312-pipeline casa
```

## Apptainer (HPC) Setup

We provide an `Apptainer.def` file to package the environment for HPC clusters.

### Building the Container

You can automatically build `.sif` images for all environments defined in `pixi.toml` using the automated script:

```bash
./scripts/build-all.sh
```

Or manually using `fakeroot`:

```bash
apptainer build --fakeroot casa.sif Apptainer.def
```

**Tip (Building Variants):** You can build specific environment flavors by passing the `PIXI_ENV` build argument:

```bash
apptainer build --fakeroot --build-arg PIXI_ENV=casa674-py312-pipeline pipeline.sif Apptainer.def
```

### Running the Container & `casarundata`

To keep the container size small and prevent read-only filesystem issues, **`casarundata` is not baked into the image**. The setup automatically adapts depending on whether you run locally or on a distributed High Throughput Grid (like OSPool).

#### 1. Local Workstation (Bind Mounting)

When running locally, Apptainer automatically bind-mounts your real `$HOME`. The container will safely copy a default `~/.casa/config.py` there if you don't already have one. You must bind-mount your local data directory (or set `CASA_RUNDATA` directly to a local path):

```bash
# Example: Running the Apptainer image with bind-mounted IERS tables
export CASA_RUNDATA="/casarundata"
apptainer run --bind /path/to/your/host/casarundata:/casarundata casa.sif casampi
```

#### 2. HTCondor / OSPool (Grid Execution)

When submitting to HTCondor with `+SingularityImage`, the worker node's local scratch directory is automatically bound as your `$PWD` and `$HOME`. **Do not use `--bind`.**
Because `$HOME` is mapped to this writable scratch directory, the container's `%runscript` will copy the default CASA config to `~/.casa` at runtime, completely avoiding "read-only filesystem" errors when CASA tries to write logs or cache files!

To get data into the container, use HTCondor's file transfer (or OSDF). **Always transfer datasets as a single `.tar` or `.tar.gz` file** to avoid extreme network handshake overheads for the thousands of tiny files in CASA datasets.

**Grid Submit File (`job.sub`):**

```condor
# HTCondor natively supports ghcr.io and will convert it to a local .sif automatically!
+SingularityImage = "docker://ghcr.io/r-xue/stack-man:latest"

# Transfer your large tarred dataset via OSDF
transfer_input_files = osdf:///ospool/ap40/data/rui.xue/casarundata-2026.02.19-1.tar.gz
```

**Grid Wrapper Script (`run_job.sh`):**

```bash
# 1. Untar the data in the local Condor scratch directory ($PWD)
tar -xzf casarundata-2026.02.19-1.tar.gz

# 2. Tell the CASA container where to find the data in the scratch space
export CASA_RUNDATA="$PWD/casarundata-2026.02.19-1"

# 3. Run CASA normally (the container handles the config generation automatically)
pixi run -e casa674-py312-pipeline casa --nogui -c "..."
```

## Docker (Cloud/Local) Setup

We also provide a `Dockerfile` that perfectly mirrors the Apptainer multi-stage logic to build standard OCI images.

### Pulling from GHCR

When a new release tag is pushed, the CI/CD pipeline automatically pushes the container to the GitHub Container Registry (GHCR). You can easily pull the latest image:

```bash
docker pull ghcr.io/r-xue/stack-man/casa:latest
```

### Building Locally

You can manually build the Docker container using standard Docker commands:

```bash
cd casa/
docker build -t casa-env .
```

You can optionally specify a `PIXI_ENV` build argument to build a variant:

```bash
docker build --build-arg PIXI_ENV=casa674-py312-pipeline -t casa-pipeline .
```
