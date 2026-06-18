#!/bin/bash
# ==============================================================================
# V-Gaol Firewall Execution Engine - Isolated Layer
# ==============================================================================
set -euo pipefail # Enhanced safety constraints to intercept runtime errors

# Import shared structures
. /usr/local/share/vgaol/log_functions.sh
. /usr/local/share/vgaol/validation_functions.sh

# Define unified log file location matching your updated logs.sh configuration
LOG_DIR="/var/log/ulog"
VGAOL_LOG="$LOG_DIR/vgaol.log"

mkdir -p "$LOG_DIR"
touch "$VGAOL_LOG"

if [ -f /etc/ulogd.conf ]; then
    log_info "[V-Gaol Sidecar] Binding ulogd2 pipeline to unified target path..."
    # Update the file key under the [emu1] configuration block
    sed -i "s|^file=.*|file=\"$VGAOL_LOG\"|g" /etc/ulogd.conf
fi

# ==============================================================================
# LOG ROTATION PROVISIONING ENGINE
# ==============================================================================
log_info "[V-Gaol Sidecar] Injecting logrotate policy boundaries..."
cat << 'EOF' > /etc/logrotate.d/vgaol
/var/log/ulog/vgaol.log {
    size 50M
    rotate 5
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
EOF

# Spawn the logrotate background polling daemon loop (checks file sizes hourly)
log_info "[V-Gaol Sidecar] Launching background log maintenance worker loop..."
while true; do
    logrotate /etc/logrotate.d/vgaol 2>/dev/null || true
    sleep 3600
done &

# ==============================================================================
# AUDITING DAEMON IGNITION
# ==============================================================================
log_info "[V-Gaol Sidecar] Starting user-space logging daemon (ulogd2)..."
# Ensure ulogd is explicitly instructed via its internal profile mapping to target $VGAOL_LOG
ulogd -d

log_info "[V-Gaol Firewall] Initializing dynamic kernel sets..."
# Create the live ipset memory frame
ipset create VGAOL_WHITELIST hash:ip hashsize 1024 maxelem 65536 timeout 300 counters -exist

log_info "[V-Gaol Firewall] Cleaning up filter table rules..."
iptables -F
iptables -X

log_info "[V-Gaol Firewall] Activating local DNS redirection mechanisms..."
# Create a NAT rule to redirect internal Docker resolver queries to local dnsmasq
iptables -t nat -A OUTPUT -p udp -d 127.0.0.11 --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A OUTPUT -p tcp -d 127.0.0.11 --dport 53 -j REDIRECT --to-ports 53

# 1. Setup Default Policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# 2. Create the Custom Auditing Chain (NFLOG for ulogd2)
iptables -N VGAOL_AUDIT_DROP
iptables -A VGAOL_AUDIT_DROP -j NFLOG --nflog-prefix "[VGAOL_VIOLATION]"
iptables -A VGAOL_AUDIT_DROP -j DROP

# 3. Core Operational Infrastructure Rules
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -I OUTPUT 1 -o lo -j ACCEPT
iptables -I INPUT 2 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -I OUTPUT 2 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Dynamic Match Layer against live memory set nodes
iptables -I OUTPUT 3 -m set --match-set VGAOL_WHITELIST dst -j ACCEPT
iptables -I INPUT 3 -m set --match-set VGAOL_WHITELIST src -j ACCEPT

# 4. Whitelist Configuration (The Guardrails)
TRUSTED_DNS="1.1.1.1"
iptables -A OUTPUT -p udp -d "$TRUSTED_DNS" --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp -d "$TRUSTED_DNS" --dport 53 -j ACCEPT

# Explicitly permit both UDP and TCP channels for internal Docker engine loops
iptables -A OUTPUT -p udp -d 127.0.0.11 -j ACCEPT
iptables -A INPUT  -p udp -s 127.0.0.11 -j ACCEPT
iptables -A OUTPUT -p tcp -d 127.0.0.11 -j ACCEPT
iptables -A INPUT  -p tcp -s 127.0.0.11 -j ACCEPT

# 5. Trap and Audit Standard Local Mismatches
iptables -A OUTPUT -j VGAOL_AUDIT_DROP
iptables -A INPUT -j VGAOL_AUDIT_DROP

log_succ "[V-Gaol Firewall] Policies applied successfully."

log_info "[V-Gaol Sidecar] Mounting persistent storage files..."
PERSIST_DIR="/etc/vgaol"
PERSIST_FILE="$PERSIST_DIR/vgaol.conf"
mkdir -p "$PERSIST_DIR"
touch "$PERSIST_FILE"

# Ensure target configuration file path is fresh and clean
TARGET_DOMAINS_CONF="/etc/dnsmasq.d/vgaol-domains.conf"
rm -f "$TARGET_DOMAINS_CONF"
touch "$TARGET_DOMAINS_CONF"

# ==============================================================================
# 100% Persistence Rule Loader Engine - Domains (dnsmasq)
# ==============================================================================
log_info "[V-Gaol Sidecar] Validating and compiling domains from host cache..."
/usr/local/share/vgaol/load_dnsmasq_config.sh "$PERSIST_FILE" "$TARGET_DOMAINS_CONF"

# ==============================================================================
# 100% Persistence Rule Loader Engine - IPs (ipset)
# ==============================================================================
if [ -f "$PERSIST_FILE" ]; then
    log_info "[V-Gaol Sidecar] Re-hydrating static IPs from host cache..."

    while IFS= read -r raw_line || [ -n "$raw_line" ]; do
        clean_line="${raw_line%%#*}"
        ip=$(echo "$clean_line" | tr -d "\r" | xargs) || true

        if [[ -z "$ip" ]]; then
            continue
        fi

        if validate_ip "$ip"; then
            log_info "[V-Gaol Sidecar] Restoring valid static IP rule: $ip"
            ipset add VGAOL_WHITELIST "$ip" timeout 0 -exist || log_warn "[V-Gaol Sidecar] Failed to sync address to kernel: $ip"
        fi

    done < "$PERSIST_FILE"
fi

echo "server=1.1.1.1" >> /etc/dnsmasq.conf

if ! grep -qE "^conf-dir=/etc/dnsmasq.d" /etc/dnsmasq.conf; then
    echo "conf-dir=/etc/dnsmasq.d" >> /etc/dnsmasq.conf
fi

# ==============================================================================
# INTERCEPTOR DAEMON IGNITION
# ==============================================================================
/usr/local/share/vgaol/restart_dnsmasq.sh 1

log_succ "[V-Gaol Sidecar] Guardian initialization complete. Passing control to CMD..."
exec "$@"
