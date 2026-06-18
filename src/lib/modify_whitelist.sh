#!/bin/bash
# ==============================================================================
# V-Gaol Network Orchestration Layer - Access Parameter Modifier
# ==============================================================================

cmd_modify_whitelist() {
    ensure_workspace
    local action="$1"
    shift
    local targets=("$@")

    if [ ${#targets[@]} -eq 0 ]; then
        log_err "Provide at least one IP or Domain. Usage: vgaol $action <target1> <target2>..."
    fi

    # Resolve the running container name based on your PROJECT_NAME variable
    local sidecar_container="vgaol-${PROJECT_NAME}-sidecar"
    if [ "$(docker inspect -f '{{.State.Running}}' "$sidecar_container" 2>/dev/null)" != "true" ]; then
        log_err "Sidecar container ($sidecar_container) is not currently running. Start it with 'vgaol up'."
    fi

    local config_file="/etc/vgaol/vgaol.conf"

    local changed=0
    local domains_changed=0

    for target in "${targets[@]}"; do
        if validate_ip "$target"; then
            changed=1

            if [[ "$action" == "add" ]]; then
                log_info "Injecting explicit static IP into active kernel set: $target"
                # Add directly to the running case-sensitive netfilter memory set
                docker exec "$sidecar_container" ipset add VGAOL_WHITELIST "$target" timeout 0 -exist 2>/dev/null || true
                # Commit to persistent file store for cluster re-hydrations
                docker exec "$sidecar_container" sh -c "grep -qFx '$target' $config_file || echo '$target' >> $config_file"

            elif [[ "$action" == "remove" ]]; then
                log_info "Removing explicit static IP from active kernel set: $target"
                # Revoke access immediately from live network memory maps
                docker exec "$sidecar_container" ipset del VGAOL_WHITELIST "$target" 2>/dev/null || true
                # Strip clean matching elements out of persistence records
                docker exec "$sidecar_container" sh -c "sed -i '/^$target\$/d' $config_file"
            fi

        elif validate_domain "$target"; then
            changed=1
            domains_changed=1

            # Target the central plain-text domain tracker database updated in your entrypoint workflow
            if [[ "$action" == "add" ]]; then
                log_info "Registering domain tracker to persistent index: '$target'"
                # Append raw domain string to text cache file if not already tracked
                docker exec "$sidecar_container" sh -c "grep -qFx '$target' $config_file || echo '$target' >> $config_file"

            elif [[ "$action" == "remove" ]]; then
                log_info "Deregistering domain tracker from persistent index: '$target'"
                # Delete exact line matching domain context safely
                docker exec "$sidecar_container" sh -c "sed -i '/^$target\$/d' $config_file"
            fi

        else
            log_warn "Provided argument(s) are invalid."
        fi
    done

    if [[ "$domains_changed" == "1" ]]; then
        # Since dnsmasq compiles rules out of the text storage asset at boot, we need to rebuild
        # vgaol-domains.conf dynamically when a rule shifts before reloading the process daemon.
        log_info "Regenerating active resolver configuration map boundaries..."
        docker exec "$sidecar_container" sh -c "/usr/local/share/vgaol/load_dnsmasq_config.sh $config_file /etc/dnsmasq.d/vgaol-domains.conf"
        log_info "Flushing DNS interception engine daemon configurations..."
        docker exec "$sidecar_container" sh -c "/usr/local/share/vgaol/restart_dnsmasq.sh 0"
    fi

    if [[ "$changed" == "1" ]]; then
        log_succ "Persistent routing parameters synchronized across environments successfully."
    fi
}

cmd_modify_whitelist_help() {
    # ==============================================================================
    # ALLOW COMMAND HELP PANEL
    # ==============================================================================
    echo -e "\033[1;34mCommand: allow\033[0m"
    printf "  %-20s %s\n" "Summary:" "Dynamically whitelists space-separated IPv4 addresses or domains."
    echo -e "  Usage:               \033[1mvgaol allow <target1> [target2...]\033[0m"
    echo ""
    echo "  Description:"
    echo "    Validates your cell environment workspace, confirms your isolation firewall"
    echo "    sidecar container is active, and streams specified network parameters straight"
    echo "    into your live kernel netfilter configurations and domain whitelist registers."
    echo ""
    echo "  Examples:"
    echo -e "    • Authorize an upstream package mirror IP:   \033[1mvgaol allow 192.30.255.113\033[0m"
    echo -e "    • Authorize multiple web access api hooks:    \033[1mvgaol allow api.github.com registry.npmjs.org\033[0m"
    echo ""

    # ==============================================================================
    # DENY COMMAND HELP PANEL
    # ==============================================================================
    echo -e "\033[1;34mCommand: deny\033[0m"
    printf "  %-20s %s\n" "Summary:" "Instantly revokes network access parameters for specified targets."
    echo -e "  Usage:               \033[1mvgaol deny <target1> [target2...]\033[0m"
    echo ""
    echo "  Description:"
    echo "    Purges specified routing entries cleanly out of persistent cell tracking caches."
    echo "    If an IP is targeted, it drops immediately from kernel memory maps."
    echo "    If a domain is targeted, internal DNS interception routing maps are compiled"
    echo "    on the fly and hot-reloaded to restore zero-trust barriers seamlessly."
    echo ""
    echo "  Examples:"
    echo -e "    • Immediately isolate a compromised IP node:  \033[1mvgaol deny 192.30.255.113\033[0m"
    echo -e "    • Sever a tracking or telemetry endpoint domain: \033[1mvgaol deny telemetry.malicious-api.net\033[0m"
    echo ""
}
