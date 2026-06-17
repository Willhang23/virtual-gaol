#!/bin/bash
# ==============================================================================
# V-Gaol Network Orchestration Layer - Validated Multi-Service Execution Engine
# ==============================================================================

cmd_exec() {
    # Hydrate environment and locate $USER_PROJECT_ROOT / $COMPOSE_PROJECT_NAME / $PROJECT_COMPOSE
    ensure_workspace

    # Ensure there is at least one argument provided (which should be the service name)
    if [ $# -lt 1 ]; then
        log_err "Missing parameters.\nUsage: vgaol exec <service-name> [options] <command> [arguments...]\n\nExamples:\n  vgaol exec target-app -it bash\n  vgaol exec vgaol-sidecar ipset list"
    fi

    local target_service="$1"

    # 🔍 Extract all valid services registered under the current active compose context
    local valid_services
    valid_services=$(docker compose \
        --project-directory "$PROJECT_ROOT" \
        -f "$BASE_COMPOSE" \
        -f "$USER_COMPOSE" \
        config --services 2>/dev/null)

    # Validate whether the provided argument matches any of the registered services
    if ! echo "$valid_services" | grep -Fqx "$target_service"; then
        log_err "Invalid service name: '$target_service'.\n\nValid services in your current stack are:\n$(echo "$valid_services" | sed 's/^/  - /')"
    fi

    # Shift off the validated service name so that "$@" contains strictly the command/options payload
    shift

    # Double check that the user didn't just type 'vgaol exec target-app' without an actual command string
    if [ $# -le 0 ]; then
        log_err "Missing command payload.\nUsage: vgaol exec $target_service <command> [arguments...]\nExample: vgaol exec $target_service bash"
    fi

    log_info "Executing runtime command inside container space: [$target_service]..."

    # Pass control, leading options, and commands smoothly to the verified service container
    docker compose \
        --project-directory "$PROJECT_ROOT" \
        -f "$BASE_COMPOSE" \
        -f "$USER_COMPOSE" \
        exec "$target_service" "$@"
}

cmd_exec_help() {
    echo -e "\033[1;34mCommand: exec\033[0m"
    printf "  %-20s %s\n" "Summary:" "Runs a command inside a specific validated container service."
    echo -e "  Usage:               \033[1mvgaol exec <service-name> [options] <command> [arguments...]\033[0m"
    echo ""
    echo "  Description:"
    echo "    Validates your cell environment workspace, dynamically parses your active container"
    echo "    stack to confirm the targeted service exists, and attaches securely to pass commands"
    echo "    directly into that service's isolated prison perimeter."
    echo ""
    echo "  Active Execution Anchors:"
    echo "    • Project Name Tag:    \$PROJECT_NAME"
    echo "    • Target Context Path: \$PROJECT_ROOT"
    echo "    • App Stack Config:    \$PROJECT_COMPOSE"
    echo ""
    echo "  Examples:"
    echo -e "    • Attach to bash inside an app container:     \033[1mvgaol exec target-app -it bash\033[0m"
    echo -e "    • Dump active firewall ipsets on the sidecar:  \033[1mvgaol exec vgaol-sidecar ipset list\033[0m"
    echo ""
}
