#!/bin/bash
# ==============================================================================
# V-Gaol Network Orchestration Layer - Stack Deconstruction
# ==============================================================================

cmd_down() {
    # Hydrate environment
    ensure_workspace

    log_info "Stopping environment context via project tag: $PROJECT_NAME"
    log_info "Targeting user project root path: $PROJECT_ROOT"
    log_info "Utilizing application compose profile: $USER_COMPOSE"

    log_info "Tearing down networking stack and flushing live memory configurations..."

    # Drop multi-file compose targets cleanly anchored to the host workspace root
    docker compose \
        --project-directory "$PROJECT_ROOT" \
        -f "$BASE_COMPOSE" \
        -f "$USER_COMPOSE" \
        down

    log_succ "V-Gaol networking stack dropped."
}

cmd_down_help() {
    echo -e "\033[1;34mCommand: down\033[0m"
    printf "  %-20s %s\n" "Summary:" "Safely stops and destroys the isolated container stack."
    echo -e "  Usage:               \033[1mvgaol down\033[0m"
    echo ""
    echo "  Description:"
    echo "    Validates your active cell environment workspace, safely tears down the sidecar"
    echo "    network orchestration layout, and flushes live isolation memory configurations."
    echo "    This releases the Victoria Gaol prison sandbox and restores normal routing."
    echo ""
    echo "  Active Execution Anchors:"
    echo "    • Project Name Tag:    \$PROJECT_NAME"
    echo "    • Target Context Path: \$PROJECT_ROOT"
    echo "    • App Stack Config:    \$PROJECT_COMPOSE"
    echo ""
}
