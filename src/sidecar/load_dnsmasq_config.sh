#!/bin/bash

# Import shared structures
. /usr/local/share/vgaol/log_functions.sh
. /usr/local/share/vgaol/validation_functions.sh

if [ -f "$1" ]; then

    # Flush file content
    if [ -f "$2" ]; then
        cat /dev/null > "$2"
    fi

    while IFS= read -r raw_line || [ -n "$raw_line" ]; do
        clean_line="${raw_line%%#*}"
        domain=$(echo "$clean_line" | tr -d "\r" | xargs) || true

        if [[ -z "$domain" ]]; then
            continue
        fi

        if validate_domain "$domain"; then
            log_info "[V-Gaol Sidecar] Whitelisting valid domain: $domain"
            echo "server=/$domain/#" >> "$2"
            echo "ipset=/$domain/VGAOL_WHITELIST" >> "$2"
        else
            log_warn "[V-Gaol Sidecar] Dropped malformed or invalid domain record: '$domain'"
        fi

    done < "$1"
fi

# Add fallback policy to block all unlisted domains and return 0.0.0.0
echo "address=/#/0.0.0.0" >> "$2"
