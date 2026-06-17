#!/bin/bash
# ==============================================================================
# V-Gaol Network Orchestration Layer - Packet Audit Logging Engines
# ==============================================================================

# Helper to resolve the target log file context safely
get_active_host_log() {
    local log_name="$1"
    local target_log_file="$VGAOL_DIR/logs/$log_name"

    # Emit a system warning if the workspace directory contains more than one file
    local total_log_files
    total_log_files=$(find "$VGAOL_DIR/logs" -maxdepth 1 -type f 2>/dev/null | wc -l)
    if [ "$total_log_files" -gt 1 ]; then
        log_warn "Multiple log assets discovered in your workspace storage directory ($total_log_files files).\n  Currently reading targeted asset: '$log_name'" >&2
    fi

    if [ ! -f "$target_log_file" ]; then
        log_err "No active network log file discovered on the host at:\n  $target_log_file\n\nEnsure the container stack is active ('vgaol up') and writing telemetry streams."
    fi
    echo "$target_log_file"
}

cmd_logs() {
    # Hydrate environment and verify path configurations natively
    ensure_workspace

    # Default live tailing tracks the active, uncompressed log target
    local active_log
    active_log=$(get_active_host_log "vgaol.log")

    log_info "Streaming dynamic local log file: $active_log"
    tail -f "$active_log"
}

cmd_grep() {
    # Hydrate environment and verify path configurations natively
    ensure_workspace

    if [ $# -eq 0 ]; then
        log_err "Provide search criteria matching standard grep rules.\nUsage: vgaol grep [<file>] [options] <pattern>\n\nExamples:\n  vgaol grep \"[VGAOL_VIOLATION]\"\n  vgaol grep vgaol.log.1.gz -i \"172.16.0.5\""
    fi

    local target_file="vgaol.log"

    # Inspect the first argument. If it points to an existing file in the log dir, isolate it.
    if [ -f "$VGAOL_DIR/logs/$1" ]; then
        target_file="$1"
        shift # Shift parameter out so "$@" contains only standard zgrep patterns/options
    else
        # If $1 is not an existing file, we leave "$@" completely untouched.
        # It falls back to "vgaol.log" and $1 remains part of your search query parameters.
        log_info "Target file context implicit or not found. Falling back to active baseline: [vgaol.log]"
    fi

    local active_log
    active_log=$(get_active_host_log "$target_file")

    log_info "Querying host log layers via zgrep passthrough context: [$target_file]..."

    # zgrep streams both plain-text files and logrotate compressed archives (.gz) transparently
    zgrep --color=always "$@" "$active_log" || log_warn "No matches found."
}

cmd_logs_help() {
    # ==============================================================================
    # LOGS COMMAND HELP PANEL
    # ==============================================================================
    echo -e "\033[1;34mCommand: logs\033[0m"
    printf "  %-20s %s\n" "Summary:" "Streams live network sandbox packet logs and violation metrics."
    echo -e "  Usage:               \033[1mvgaol logs\033[0m"
    echo ""
    echo "  Description:"
    echo "    Validates your active cell environment workspace, resolves the primary"
    echo "    uncompressed network log destination asset, and establishes a live"
    echo "    tailing stream to capture security container events in real time."
    echo ""
    echo "  Active Execution Anchors:"
    echo "    • Target Context Path: \$PROJECT_ROOT"
    echo "    • Log Workspace Dir:   \$VGAOL_DIR/logs/vgaol.log"
    echo ""

    # ==============================================================================
    # GREP COMMAND HELP PANEL
    # ==============================================================================
    echo -e "\033[1;34mCommand: grep\033[0m"
    printf "  %-20s %s\n" "Summary:" "Searches through log records using advanced pattern match filters."
    echo -e "  Usage:               \033[1mvgaol grep [<log-file>] [zgrep-options] <pattern>\033[0m"
    echo ""
    echo "  Description:"
    echo "    Runs an optimized 'zgrep' pipeline across your isolated audit logs."
    echo "    It targets the active 'vgaol.log' automatically by default, but you can"
    echo "    explicitly point it at historical logrotate compressed archive files"
    echo "    (such as vgaol.log.1.gz) to review past zero-trust network data."
    echo ""
    echo "  Examples:"
    echo -e "    • Scan active logs for firewall drop blocks:  \033[1mvgaol grep \"[VGAOL_VIOLATION]\"\033[0m"
    echo -e "    • Case-insensitive search on a raw backup:    \033[1mvgaol grep vgaol.log.1.gz -i \"172.16.0.5\"\033[0m"
    echo ""
}
