#!/bin/bash
# Build all Apptainer images in the stack-man repository

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

for stack_dir in "$REPO_ROOT"/*/; do
    if [ -d "$stack_dir" ] && [ -f "$stack_dir/Apptainer.def" ]; then
        stack_name=$(basename "$stack_dir")
        echo "========================================"
        echo "Building $stack_name..."
        echo "========================================"
        cd "$stack_dir"
        
        # Ensure pixi.lock exists before building
        if [ ! -f "pixi.lock" ]; then
            echo "Warning: pixi.lock not found in $stack_dir."
            echo "Generating pixi.lock with 'pixi install' locally..."
            if command -v pixi &> /dev/null; then
                pixi install
            else
                echo "Error: 'pixi' command not found and 'pixi.lock' is missing."
                echo "Please install pixi or generate pixi.lock manually."
                exit 1
            fi
        fi
        # Determine Pixi environments (fallback to 'default' if parsing fails or pixi missing)
        envs="default"
        if command -v pixi &> /dev/null && [ -f "pixi.toml" ]; then
            parsed_envs=$(pixi project environment list 2>/dev/null | grep '^- ' | awk '{print $2}' | sed 's/://')
            if [ -n "$parsed_envs" ]; then
                envs="$parsed_envs"
            fi
        fi

        for env in $envs; do
            if [ "$env" = "default" ]; then
                image_name="${stack_name}.sif"
            else
                # Clean up redundant stack names in the environment string (e.g. casa-casa674 -> casa-674)
                short_env="${env#$stack_name}"
                short_env="${short_env#-}" # strip leading hyphen if any
                image_name="${stack_name}-${short_env}.sif"
            fi
            
            echo "-> Building environment: $env (Output: $image_name)"
            
            # Remove old image for a clean build
            rm -f "$image_name"
            
            # Build the container with the specific Pixi environment
            apptainer build --fakeroot --build-arg PIXI_ENV="$env" "$image_name" Apptainer.def
            
            echo "Successfully built $image_name in $stack_dir"
        done
    fi
done

echo "All builds completed."
