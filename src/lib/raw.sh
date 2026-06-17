#!/bin/bash

cmd_raw() {
    ensure_workspace

    docker compose \
        --project-directory "$PROJECT_ROOT" \
        -f "$BASE_COMPOSE" \
        -f "$USER_COMPOSE" \
        "$@"
}

cmd_raw_help() {
    echo -e "\033[1;34mCommand: raw\033[0m"
    printf "  %-20s %s\n" "Summary:" "Runs a raw docker compose command within the namespaced project cell."
    echo -e "  Usage:               \033[1mvgaol raw <docker-compose-command> [arguments...]\033[0m"
    echo ""
    echo "  Description:"
    echo "    Validates your active workspace and acts as a direct pass-through pipeline to the"
    echo "    underlying Docker Compose engine, safely pre-configured with your unified project anchors."
    echo "    This lets you issue native commands without breaking isolation constraints."
    echo ""
    echo "  Active Execution Anchors:"
    echo "    • Project Name Tag:    \$PROJECT_NAME"
    echo "    • Target Context Path: \$PROJECT_ROOT"
    echo "    • App Stack Config:    \$PROJECT_COMPOSE"
    echo ""
    echo "  Examples:"
    echo -e "    • Review your final compiled configurations:  \033[1mvgaol raw config\033[0m"
    echo -e "    • View execution resource consumption stats:  \033[1mvgaol raw top\033[0m"
    echo -e "    • Force reboot a specific cell component:     \033[1mvgaol raw restart target-app\033[0m"
    echo ""
}
