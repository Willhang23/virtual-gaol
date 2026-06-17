#!/bin/bash
# ==============================================================================
# V-Gaol Network Orchestration Layer - Stack Ignition
# ==============================================================================

cmd_up() {
    # Hydrate environment
    ensure_workspace

    log_info "Starting environment context via project tag: $PROJECT_NAME"
    log_info "Targeting user project root path: $PROJECT_ROOT"
    log_info "Utilizing application compose profile: $USER_COMPOSE"

    log_info "Synchronizing network configurations and initializing containers..."

    # Drive multi-file compose alignment securely anchored to the host workspace root
    docker compose \
        --project-directory "$PROJECT_ROOT" \
        -f "$BASE_COMPOSE" \
        -f "$USER_COMPOSE" \
        up -d --build

    log_succ "V-Gaol networking stack is live."
}

cmd_up_help() {
	echo -e "\033[1;34mCommand: up\033[0m"
    printf "  %-20s %s\n" "Summary:" "Builds and spins up the isolated firewall network sidecar stack."
    echo -e "  Usage:               \033[1mvgaol up\033[0m"
    echo ""
    echo "  Description:"
    echo "    Validates your active cell environment workspace, compiles net-gating rules,"
    echo "    and launches your sidecar network architecture in detached mode."
    echo ""
    echo "  User-Configurable Execution Environments:"
    echo "    • \$VGAOL_DIR          Customizes the cell workspace location (Defaults to: ./vgaol)"
    echo "    • \$PROJECT_COMPOSE    User-controlled application stack override (Defaults to: \$VGAOL_DIR/docker-compose.yml)"
    echo ""
    echo "  Active Execution Anchors:"
    echo "    • Project Name Tag:    \$PROJECT_NAME"
    echo "    • Target Context Path: \$PROJECT_ROOT"
    echo ""
    echo -e "  \033[1;33m⚠️  Important Reminder:\033[0m"
    echo "    You can maintain a '.env' file inside your \$VGAOL_DIR to securely persist"
    echo "    your customized variables. However, if you are using a non-default path,"
    echo "    you must always 'export \$VGAOL_DIR' in your current terminal session"
    echo "    before running any vgaol command."
    echo ""
}
