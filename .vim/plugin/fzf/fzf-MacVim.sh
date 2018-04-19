#!/bin/bash

SCRIPT="$(realpath $0)"
FZF_DIR="$(dirname "$SCRIPT")"

osascript -l JavaScript "${FZF_DIR}/fzf-MacVim.scpt" "$1" $PWD
