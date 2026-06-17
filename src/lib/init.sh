#!/bin/bash

cmd_init() {
    if [ ! -d "$STUBS_DIR" ]; then
        log_err "Missing template cache source directory at expected layout path: '$STUBS_DIR'"
    fi

    if [ -d "$VGAOL_DIR" ]; then
        log_err "An './vgaol' workspace directory already exists here."
    else
        mkdir -p "$VGAOL_DIR"
    fi
    
    log_info "Deploying configuration infrastructure templates from: $STUBS_DIR"
    cp "$STUBS_DIR/Dockerfile.app" "$VGAOL_DIR/"
    cp "$STUBS_DIR/docker-compose.yml" "$VGAOL_DIR/"
    cp "$STUBS_DIR/.env.example" "$VGAOL_DIR/.env"
    
    mkdir -p "$VGAOL_DIR/config"
    mkdir -p "$VGAOL_DIR/logs"

    # Initialize raw configuration caches for our validation loops
    touch "$VGAOL_DIR/config/vgaol-domains.txt"
    touch "$VGAOL_DIR/config/vgaol-ips.txt"

    log_succ "Workspace successfully initialized for this repository under context: '$PROJECT_NAME'."
    # ==============================================================================
    # GITIGNORE COMPLIANCE REMINDER
    # ==============================================================================
    echo -e "\n\033[1;33m⚠️  Git Compliance Recommendation:\033[0m"
    echo "    To prevent committing local security state, domain trackers, and active audit"
    echo "    logs to your source control, please ensure your cell folder is excluded."
    echo ""
    echo "    You can achieve this using either approach:"
    echo "    1. Append to this repository's local file:"
    echo "       echo \"vgaol/\" >> .gitignore"
    echo "    2. Alternatively, add it to your machine's global configurations:"
    echo "       echo \"vgaol/\" >> ~/.gitignore_global"
    echo ""
}

cmd_init_help() {
    echo -e "\033[1;34mCommand: init\033[0m"
    printf "  %-20s %s\n" "Summary:" "Scaffolds a fortified local isolation cell configuration environment."
    echo -e "  Usage:               \033[1mvgaol init\033[0m"
    echo ""
    echo "  Description:"
    echo "    Deploys core containment infrastructure files into your active workspace."
    echo "    By default, it creates an './vgaol' directory, but this destination path"
    echo "    can be fully customized by exporting your own '\$VGAOL_DIR' environment variable."
    echo ""
    echo "  Provisioned Cell Artifacts:"
    echo "    \$VGAOL_DIR/                  Root folder of your sandbox cell configuration"
    echo "    ├── Dockerfile.app           Target hardened application container profile"
    echo "    ├── docker-compose.yml       Orchestration layout running your network defenses"
    echo "    ├── .env                     Local environment configuration variables"
    echo "    ├── config/"
    echo "    │   ├── vgaol-domains.txt    Active firewall network domain whitelist database"
    echo "    │   └── vgaol-ips.txt        Active firewall network IP address database"
    echo "    └── logs/                    Standard output directory for isolation audit streams"
    echo ""
}
