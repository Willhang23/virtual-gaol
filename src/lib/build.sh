#!/usr/bin/env bash

set -euo pipefail

# 1. Determine base path with fallback
TARGET_ROOT="${VGAOL_ROOT_PATH:-$HOME/.local/share/vgaol}"

# Load modules
. "$TARGET_ROOT/lib/log_functions.sh"

log_info "Resolving V-Gaol build execution path..."
log_info "Target Root: $TARGET_ROOT"

# 2. Context Safety Verification
if [ ! -d "$TARGET_ROOT" ]; then
    log_err "Source directory context missing at: $TARGET_ROOT\nPlease ensure source files are fully populated before running build."
fi

# 3. Change into context directory to execute Docker build safely
cd "$TARGET_ROOT"

# Verify necessary asset existence explicitly before driving build engine
REQUIRED_ASSETS=(
    "lib/validation_functions.sh"
    "lib/log_functions.sh"
    "sidecar/Dockerfile.sidecar"
    "sidecar/entrypoint.sh"
    "sidecar/load_dnsmasq_config.sh"
)

for asset in "${REQUIRED_ASSETS[@]}"; do
    if [ ! -f "$asset" ]; then
        log_err "Missing critical build asset component: $TARGET_ROOT/$asset"
    fi
done

log_info "Initiating build compilation for image: vgaol-sidecar..."

# 4. Trigger forced, clean context build
docker build \
    --no-cache \
    -t vgaol-sidecar:latest \
    -f sidecar/Dockerfile.sidecar .

log_succ "Image 'vgaol-sidecar:latest' built and ready."
