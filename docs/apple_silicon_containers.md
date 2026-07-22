# Running on Apple Silicon via `container`

For macOS users on Apple silicon, you can run our containerized environments natively without installing Docker Desktop by using Apple's official, lightweight OCI runtime: [apple/container](https://github.com/apple/container).

This tool spins up Linux containers as highly optimized, lightweight virtual machines taking full advantage of the macOS Virtualization framework.

## 1. Installation

1. Download the latest signed installer from the [apple/container releases page](https://github.com/apple/container/releases).
2. Double click the `.pkg` file to install it.
3. Start the required background service (refer to the official repository for the latest daemon launch instructions, e.g. `container start` or via launchctl).

## 2. Pulling the Images

Because our CI/CD pipeline pushes standard OCI-compatible images to the GitHub Container Registry, Apple's `container` tool can natively pull them.

```bash
# Pull the CASA environment (forcing x86_64 architecture for Rosetta 2)
container pull --arch amd64 ghcr.io/r-xue/stack-man/casa:latest

# Pull the Viper environment
container pull --arch amd64 ghcr.io/r-xue/stack-man/viper:latest
```

## 3. Running the Environments

You can run the environment seamlessly just like a standard container CLI. **You must specify `--arch amd64`** so the runtime knows to engage Rosetta 2 rather than looking for a native ARM image:

```bash
# Drop into the Viper environment
container run -it --arch amd64 ghcr.io/r-xue/stack-man/viper:latest

# Drop into the CASA environment
container run -it --arch amd64 ghcr.io/r-xue/stack-man/casa:latest
```

> [!TIP]
> **Volume Mounting:** Just like Docker and Apptainer, you can bind-mount your local calibration data directories into the container using standard volume flags (e.g., `-v /path/to/host/casarundata:/casarundata`) so you don't have to rebuild the image when updating IERS tables.
