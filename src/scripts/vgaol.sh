#!/bin/bash
# ==============================================================================
# Hardened Global V-Gaol Control Utility
# ==============================================================================
set -e

# Resolve absolute execution origin even if triggered through a system symlink layer
SRC_ROOT=$(dirname "$(dirname "$(readlink -f "$0")")")

# Map templates natively back to your clean, standard stubs folder tree structure
STUBS_DIR="$SRC_ROOT/stubs"

PROJECT_ROOT=$PWD
PROJECT_NAME=$(basename "$PROJECT_ROOT")
VGAOL_DIR="${VGAOL_DIR:-$PROJECT_ROOT/vgaol}"

. "$SRC_ROOT/lib/log_functions.sh"
. "$SRC_ROOT/lib/validation_functions.sh"
. "$SRC_ROOT/lib/utility.sh"
. "$SRC_ROOT/lib/init.sh"
. "$SRC_ROOT/lib/up.sh"
. "$SRC_ROOT/lib/down.sh"
. "$SRC_ROOT/lib/exec.sh"
. "$SRC_ROOT/lib/modify_whitelist.sh"
. "$SRC_ROOT/lib/logs.sh"
. "$SRC_ROOT/lib/raw.sh"

# ==============================================================================
# SUBCOMMANDS IMPLEMENTATION
# ==============================================================================

cmd_help() {
    {
        echo -e "\033[1;35mV-Gaol Sandbox CLI Platform Controller\033[0m"
        echo "Usage: vgaol <command> [arguments]"
        echo ""
        # ==============================================================================
        # NEW: COMMAND SECTION INDEX (AT THE VERY BEGINNING)
        # ==============================================================================
        echo "Available Subcommands:"
        printf "  %-20s %s\n" "init" "Scaffolds a fortified local isolation cell configuration environment."
        printf "  %-20s %s\n" "up" "Builds and spins up the isolated firewall network sidecar stack."
        printf "  %-20s %s\n" "down" "Safely stops and destroys the isolated container stack."
        printf "  %-20s %s\n" "exec" "Runs a command inside a specific validated container service."
        printf "  %-20s %s\n" "raw" "Runs a raw docker compose command within the namespaced project cell."
        printf "  %-20s %s\n" "allow" "Dynamically whitelists space-separated IPv4 addresses or domains."
        printf "  %-20s %s\n" "deny" "Instantly revokes network access parameters for specified targets."
        printf "  %-20s %s\n" "logs" "Streams live network sandbox packet logs and violation metrics."
        printf "  %-20s %s\n" "grep" "Searches through log records using advanced pattern match filters."
        echo ""
        echo "--------------------------------------------------------------------------------"
        echo "Detailed Command Documentation:"
        echo "--------------------------------------------------------------------------------"
        echo ""
        cmd_init_help
        cmd_up_help
        cmd_down_help
        cmd_exec_help
        cmd_raw_help
        cmd_modify_whitelist_help
        cmd_logs_help
        echo ""
    } | less -XRF
}

# ==============================================================================
# ROUTER METRICS / CLI DISPATCHER
# ==============================================================================
case "$1" in
    init)   cmd_init ;;
    up)     cmd_up ;;
    down)   cmd_down ;;
    exec)   shift; cmd_exec "$@" ;;
    raw)    shift; cmd_raw "$@" ;;
    allow)    shift; cmd_modify_whitelist "add" "$@" ;;
    deny) shift; cmd_modify_whitelist "remove" "$@" ;;
    logs)   cmd_logs ;;
    grep)   shift; cmd_grep "$@" ;;
    help|*) cmd_help ;;
esac
