# ==============================================================================
# STAGE 1: Build
# ==============================================================================
FROM ghcr.io/prefix-dev/pixi:latest AS build

ARG PIXI_ENV=default
WORKDIR /opt/viper

# Install git for any potential git dependencies
RUN apt-get update && apt-get install -y git

# Copy manifests
COPY pixi.toml pixi.lock ./

# Install the requested environment
RUN pixi install --locked --environment ${PIXI_ENV}

# ==============================================================================
# STAGE 2: Final
# ==============================================================================
FROM ubuntu:24.04 AS final

ARG PIXI_ENV=default
ENV PIXI_ENV=${PIXI_ENV}

# Set environment variables
ENV PATH="/opt/viper/.pixi/envs/${PIXI_ENV}/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin" \
    HOME="/root" \
    PIXI_PROJECT_DIR="/opt/viper" \
    PIXI_CACHE_DIR="/tmp/.pixi_cache" \
    RATTLER_CACHE_DIR="/tmp/.rattler_cache" \
    UV_CACHE_DIR="/tmp/.uv_cache" \
    XDG_CACHE_HOME="/tmp/.cache" \
    XDG_CONFIG_HOME="/tmp/.config" \
    XDG_DATA_HOME="/tmp/.local/share" \
    XDG_STATE_HOME="/tmp/.local/state"

# Install bare minimum runtime dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the environment from the build stage
COPY --from=build /opt/viper/.pixi/envs/${PIXI_ENV} /opt/viper/.pixi/envs/${PIXI_ENV}
COPY --from=build /opt/viper/pixi.toml /opt/viper/pixi.toml
COPY --from=build /usr/local/bin/pixi /usr/local/bin/pixi

WORKDIR /opt/viper

# Default command matches Apptainer's exec behavior
ENTRYPOINT ["sh", "-c", "exec pixi run --as-is -e ${PIXI_ENV} \"$@\"", "--"]
