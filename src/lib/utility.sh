#!/bin/bash
# ==============================================================================
# V-Gaol Network Orchestration Layer - Internal System Utilities
# ==============================================================================

ensure_workspace() {
    # Ensure SRC_ROOT cannot be overridden maliciously
    local TRUE_SRC_ROOT="$SRC_ROOT"

    if [ ! -d "$VGAOL_DIR" ]; then
        log_err "V-Gaol directory not initialized in this project. Run 'vgaol init' here first."
    fi

    # Handle environmental hydration safely
    if [ -f "$VGAOL_DIR/.env" ]; then
        # Match only lines that have real characters and do not start with a comment symbol
        if grep -q '^[[:space:]]*[^#[:space:]]' "$VGAOL_DIR/.env"; then
            export $(grep -v '^#' "$VGAOL_DIR/.env" | xargs)
        fi
    fi

    export SRC_ROOT="$TRUE_SRC_ROOT"
    export STUBS_DIR="$STUBS_DIR"
    export PROJECT_ROOT="$PROJECT_ROOT"
    export PROJECT_NAME="$PROJECT_NAME"
    export VGAOL_DIR="$VGAOL_DIR"
    export BASE_COMPOSE="$SRC_ROOT/sidecar/docker-compose.yml"
    export USER_COMPOSE="${PROJECT_COMPOSE:-$VGAOL_DIR/docker-compose.yml}"

    # Verify both compose profiles are intact before allowing any orchestration command to execute
    if [ ! -f "$BASE_COMPOSE" ]; then
        log_err "Critical framework component missing at: $BASE_COMPOSE"
    fi
    if [ ! -f "$USER_COMPOSE" ]; then
        log_err "Target application compose configuration missing at: $USER_COMPOSE"
    fi
}
