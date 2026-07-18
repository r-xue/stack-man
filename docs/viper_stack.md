# Viper Environment Stack

The `viper/` directory contains a modular environment for the Viper radio astronomy processing stack (including `xradio` and `astroviper`). It leverages `pixi` for rapid and reproducible dependency resolution.

## Local Setup & Usage

To resolve the lockfile and download the dependencies:

```bash
cd viper/
pixi install
```

### Running the Shell

You can drop into the isolated Viper environment by running:

```bash
pixi shell
```

From here, tools like `ipython`, `xradio`, and `astroviper` (along with standard dependencies like Python 3.12) are fully available and completely isolated from your host system.

## Apptainer (HPC) Setup

Similar to the CASA stack, you can securely containerize this environment using the automated build script to run it on HPC clusters:

```bash
./scripts/build-all.sh
```

This will produce a `viper.sif` Apptainer image that encapsulates the environment statelessly.

## Docker (Cloud/Local) Setup

Alongside Apptainer, a `Dockerfile` is provided for standard OCI containerization. 

### Pulling from GHCR

The GitHub Actions CI/CD pipeline automatically pushes the Viper environment to the GitHub Container Registry on tagged releases:

```bash
docker pull ghcr.io/r-xue/stack-man/viper:latest
```

### Building Locally

You can manually build the Viper Docker container from the directory:

```bash
cd viper/
docker build -t viper-env .
```
