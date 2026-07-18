# Stack-Man Documentation

Welcome to the `stack-man` repository! This project provides reproducible, containerized, and modular environments for radio astronomy software stacks, leveraging [Pixi](https://pixi.sh) for dependency management and [Apptainer](https://apptainer.org/) for HPC containerization.

## Core Design Principles (Sensible Setup)

1. **Modular Workspaces**: Each major software stack / environment (e.g., CASA, Viper) lives in its own subdirectory with its own `pixi.toml`. This prevents dependency conflicts while keeping everything in one mono-repo.
2. **Zero-Bloat Containers**: We use multi-stage, unprivileged `fakeroot` Apptainer builds. The final image only inherits the strictly necessary compiled environment, completely dropping `uv-cache`, build bloat, and heavy docs dependencies to keep `.sif` images minimal.
3. **Externalized Data**: Calibration data directories (like `casarundata` and IERS tables) are deliberately kept out of the container images. They are bind-mounted at runtime to allow easy updates without rebuilding the containers.
4. **Native-Like CLI**: We define Pixi tasks (like `pixi run casa` or `pixi run casampi`) so the commands feel exactly like the monolithic wrappers users are accustomed to.

## Available Stacks

* [CASA Environment Stack](casa_stack.md)
* [Viper Environment Stack](viper_stack.md)
