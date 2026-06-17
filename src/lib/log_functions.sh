#!/bin/bash

# ANSI Color Output Helpers
log_info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
log_succ()  { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
log_warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
log_err()   { echo -e "\033[1;31m[ERROR]\033[0m $*"; >&2; exit 1; }
