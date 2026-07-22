#!/usr/bin/env bash
set -e

REPO="r-xue/stack-man"
API_URL="https://api.github.com/repos/$REPO/releases"

echo "Fetching release data from GitHub API ($REPO)..."
# We use Python to safely parse the JSON since `jq` might not be installed on all hosts.
RELEASES_JSON=$(curl -s "$API_URL")

download_sif() {
    # Default to casa.sif, but allow the user to specify a different container name
    TARGET_SIF="${2:-casa.sif}"
    echo "Resolving latest $TARGET_SIF container release..."
    
    SIF_URL=$(echo "$RELEASES_JSON" | python3 -c "
import sys, json
try:
    releases = json.load(sys.stdin)
    # Find the newest release starting with 'v'
    for r in releases:
        if r['tag_name'].startswith('v'):
            for a in r['assets']:
                if a['name'] == '$TARGET_SIF':
                    print(a['browser_download_url'])
                    sys.exit(0)
except Exception as e:
    pass
")
    if [ -z "$SIF_URL" ]; then
        echo "Error: Could not find a $TARGET_SIF release."
        exit 1
    fi
    echo "Downloading: $SIF_URL"
    wget -q --show-progress -O "$TARGET_SIF" "$SIF_URL"
}

download_data() {
    echo "Resolving latest casarundata release..."
    DATA_URL=$(echo "$RELEASES_JSON" | python3 -c "
import sys, json
try:
    releases = json.load(sys.stdin)
    # Find the newest release starting with 'casarundata-'
    for r in releases:
        if r['tag_name'].startswith('casarundata-'):
            for a in r['assets']:
                if a['name'].startswith('casarundata-') and a['name'].endswith('.tar.gz'):
                    print(a['browser_download_url'])
                    sys.exit(0)
except Exception as e:
    pass
")
    if [ -z "$DATA_URL" ]; then
        echo "Error: Could not find a casarundata tarball release."
        exit 1
    fi
    
    # Extract the actual filename from the URL so it saves correctly
    FILENAME=$(basename "$DATA_URL")
    
    echo "Downloading: $DATA_URL"
    wget -q --show-progress -O "$FILENAME" "$DATA_URL"
}

case "$1" in
    sif)
        download_sif "$1" "$2"
        ;;
    data)
        download_data
        ;;
    all)
        download_sif "$1" "$2"
        download_data
        ;;
    *)
        echo "Usage: $0 {sif|data|all} [filename]"
        echo "  sif [filename]  : Downloads a specific container (defaults to casa.sif)"
        echo "                    (e.g., ./download-latest.sh sif casa-674-py312.sif)"
        echo "  data            : Downloads the latest casarundata tarball"
        echo "  all [filename]  : Downloads both"
        exit 1
        ;;
esac

echo "Download(s) complete!"
