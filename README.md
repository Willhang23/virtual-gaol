# V-Gaol
> Victoria/Virtual Gaol - a tool to monitor and control network connection in software development

## Install

Prerequisite:  
- \*-nix OS with bash
- Docker

You can override these variables.  
- `VGAOL_SHARE_DIR`: the directory of the package installed, default: `$HOME/.local/share/vgaol/`
- `VGAOL_BIN_DIR`: the directory of the command installed, default: `$HOME/.bin/`

Then run:
```sh
bash ./src/scripts/install.sh
```

### Build the sidecar image
Sometimes you just want to build or rebuild the vgaol sidecar. You can run:
```sh
# cd to vgaol root directory
VGAOL_ROOT_PATH=$PWD/src bash ./src/lib/build.sh
```

## Uninstall

To uninstall, run:
```sh
$VGAOL_SHARE_DIR/scripts/uninstall.sh
```

## Usage
Run the following command to check the help menu:
```sh
vgaol help
```
