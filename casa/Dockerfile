# ==============================================================================
# STAGE 1: Build
# ==============================================================================
FROM ghcr.io/prefix-dev/pixi:latest AS build

ARG PIXI_ENV=default
WORKDIR /opt/casa

# Copy manifests
COPY pixi.toml pixi.lock ./

# Install git (required for fetching git dependencies like the pipeline)
RUN apt-get update && apt-get install -y git

# Install the requested environment
RUN pixi install --locked --environment ${PIXI_ENV}

# ==============================================================================
# STAGE 2: Final
# ==============================================================================
FROM ubuntu:24.04 AS final

ARG PIXI_ENV=default
ENV PIXI_ENV=${PIXI_ENV}

# Set environment variables
ENV PATH="/opt/casa/.pixi/envs/${PIXI_ENV}/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin" \
    HOME="/root" \
    PIXI_PROJECT_DIR="/opt/casa" \
    PYTHONPATH="/opt/casa/.pixi/envs/${PIXI_ENV}/lib/python3.12/site-packages:${PYTHONPATH}" \
    PIXI_CACHE_DIR="/tmp/.pixi_cache" \
    RATTLER_CACHE_DIR="/tmp/.rattler_cache" \
    UV_CACHE_DIR="/tmp/.uv_cache" \
    XDG_CACHE_HOME="/tmp/.cache" \
    XDG_CONFIG_HOME="/tmp/.config" \
    XDG_DATA_HOME="/tmp/.local/share" \
    XDG_STATE_HOME="/tmp/.local/state" \
    MPLCONFIGDIR="/tmp/.matplotlib"

# Install bare minimum runtime dependencies (CASA GUI/X11 needs)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates xvfb libfuse2 fuse libxcb-cursor0 libglib2.0-0t64 libfontconfig1 libfreetype6 \
        libsm6 libxext6 libxml2-utils libxrender1 imagemagick poppler-utils && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure CASA rundata path
RUN mkdir -p /root/.casa /casarundata && \
    chmod 777 /casarundata && \
    echo "import os\n\
rundata_path = os.environ.get('CASA_RUNDATA', '/casarundata')\n\
measurespath = rundata_path\n\
datapath = [rundata_path]\n\
measures_auto_update = False\n\
data_auto_update = False\n\
cachedir = '/tmp/.casa'\n\
logfile = '/tmp/casa.log'\n\
iplogfile = '/tmp/ipython.log'" > /root/.casa/config.py

# Copy the environment from the build stage
COPY --from=build /opt/casa/.pixi/envs/${PIXI_ENV} /opt/casa/.pixi/envs/${PIXI_ENV}
COPY --from=build /opt/casa/pixi.toml /opt/casa/pixi.toml
COPY --from=build /usr/local/bin/pixi /usr/local/bin/pixi

WORKDIR /opt/casa

# Default command matches Apptainer's exec behavior
ENTRYPOINT ["sh", "-c", "exec pixi run --as-is -e ${PIXI_ENV} \"$@\"", "--"]
