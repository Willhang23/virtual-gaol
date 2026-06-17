#!/bin/bash
# ===================================================
#                  V-Gaol Uninstaller
# ===================================================
set -euo pipefail

TARGET_BIN_DIR="$(dirname $(which vgaol))"
TARGET_SHARE_DIR="$(dirname "$(dirname "$0")")"

# Load modules
. "$TARGET_SHARE_DIR/lib/log_functions.sh"

echo "====================================================="
echo "                  Uninstalling V-Gaol                 "
echo "====================================================="

# 1. Remove the Docker sidecar image
if docker images -q vgaol-sidecar:latest > /dev/null 2>&1; then
    log_info "Removing Docker image: vgaol-sidecar:latest..."
    # Force removal in case a stopped/stale container is lingering
    docker rmi -f vgaol-sidecar:latest > /dev/null 2>&1 || true
    log_succ "Docker image successfully purged."
else
    log_info "Docker image vgaol-sidecar:latest already absent."
fi

# 2. Sever execution path hooks
if [ -L "$TARGET_BIN_DIR/vgaol" ] || [ -f "$TARGET_BIN_DIR/vgaol" ]; then
    log_info "Removing global executable symlink from $TARGET_BIN_DIR..."
    rm -f "$TARGET_BIN_DIR/vgaol"
else
    log_info "Global bin execution link already absent."
fi

# 3. Obliterate shared cache footprints
if [ -d "$TARGET_SHARE_DIR" ]; then
    log_info "Purging shared core data structures from $TARGET_SHARE_DIR..."
    rm -rf "$TARGET_SHARE_DIR"
fi

log_succ "V-Gaol framework successfully uninstalled from your machine context."
