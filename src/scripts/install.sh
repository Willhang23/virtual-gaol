#!/bin/bash
# ===================================================
#                   V-Gaol Installer
# ===================================================
set -euo pipefail

# Target paths relative to this script running from within src/scripts/
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
SRC_ROOT=$(dirname "$SCRIPT_DIR") # Steps up out of bin to src/

# Load modules
. "$SRC_ROOT/lib/log_functions.sh"

# System deployment targets
VGAOL_BIN_DIR="${VGAOL_BIN_DIR:-$HOME/.bin}"
VGAOL_SHARE_DIR="${VGAOL_SHARE_DIR:-$HOME/.local/share/vgaol}"

echo "===================================================="
echo "                  Installing V-Gaol                  "
echo "===================================================="

if [ ! -f "$SCRIPT_DIR/vgaol.sh" ] || [ ! -f "$SCRIPT_DIR/uninstall.sh" ]; then
    log_err "Missing core executable or uninstaller components inside '$SCRIPT_DIR'."
fi

# 1. Clean and allocate system directory targets
log_info "Provisioning system runtime paths..."
mkdir -p "$VGAOL_BIN_DIR"
rm -rf "$VGAOL_SHARE_DIR"
mkdir -p "$VGAOL_SHARE_DIR"

# 2. Copy the CONTENT of src directly into the target share directory
log_info "Mirroring source architecture content directly into share destination..."
cp -r "$SRC_ROOT"/. "$VGAOL_SHARE_DIR/"

# 3. Create the user execution symlink pointing directly to the new share structure
log_info "Binding runtime binary execution hooks..."
rm -f "$VGAOL_BIN_DIR/vgaol"
ln -s "$VGAOL_SHARE_DIR/scripts/vgaol.sh" "$VGAOL_BIN_DIR/vgaol"

# 4. Enforce strict permissions across scripts in their new home
chmod +x "$VGAOL_SHARE_DIR/scripts/vgaol.sh"
chmod +x "$VGAOL_SHARE_DIR/scripts/uninstall.sh"

# Call the build compilation module directly
log_info "Invoking image generation build engine..."
bash "$VGAOL_SHARE_DIR/lib/build.sh"

log_succ "Installation completed successfully!"
echo "Run 'vgaol help' to explore operational parameters."
