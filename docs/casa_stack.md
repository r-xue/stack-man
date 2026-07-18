# CASA Environment Stack

The `casa/` directory contains a modular installation of the CASA 6 suite, built on top of conda-forge and NRAO pip repositories. It replaces the old monolithic CASA wrappers by using `pixi` and `apptainer`.

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

Run CASA across 4 MPI cores:

```bash
pixi run casampi
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

To keep the container size small and prevent read-only filesystem crashes during MPI runs, **`casarundata` is not baked into the image**. The container expects the data to be bind-mounted from your host machine into `/casarundata`.

```bash
# Example: Running the Apptainer image with bind-mounted IERS tables
apptainer run --bind /path/to/your/host/casarundata:/casarundata casa.sif casampi
```

**Tip:** If you need to mount the data to a different location inside the container, you can override the path using the `CASA_RUNDATA` environment variable!
