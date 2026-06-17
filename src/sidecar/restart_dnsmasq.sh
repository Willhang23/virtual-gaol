#!/bin/bash
set -euo pipefail # Enhanced safety constraints to intercept runtime errors

. /usr/local/share/vgaol/log_functions.sh

LOG_DIR="/var/log/ulog"
VGAOL_LOG="$LOG_DIR/vgaol.log"

# Check if the variable is NOT empty
if [ "$1" != "1" ]; then
    DNSMASQ_PID=$(pidof dnsmasq)
    log_info "Found dnsmasq at PID $DNSMASQ_PID. Sending SIGHUP..."
    kill -9 "$DNSMASQ_PID"
    sleep 1
fi

log_info "[V-Gaol Sidecar] Booting reactive DNS interceptor (dnsmasq)..."

# Start dnsmasq with explicit options to track lookups cleanly into the unified log file
dnsmasq \
    --user=root \
    --keep-in-foreground \
    --interface=lo \
    --bind-interfaces \
    --log-queries \
    --log-facility="$VGAOL_LOG" &
DNSMASQ_PID=$!

# Quick health check confirmation loop
sleep 0.5
if ! kill -0 $DNSMASQ_PID 2>/dev/null; then
    log_err "[V-Gaol Sidecar] Critical crash caught: dnsmasq could not start safely."
    exit 1
fi
