#!/bin/bash
# Generate an automatic title for GNU screen(1)

# Executed command
cmd_line="$1"; shift

# Commands that are not displayed while executed
IGNORED_COMMANDS='bash history ls ps'

TITLE=

# Display rg branch
rg_branch_name=${PWD##${HOME}/rg/rg.}
rg_branch_name=${rg_branch_name%%/*}
if [ -n "$rg_branch_name" ]; then
    TITLE="${TITLE}${rg_branch_name}"
else
    TITLE="${TITLE}${PWD##*/}"
fi

# Remove all preceding variable declarations
set -- $cmd_line
while [ -n "$1" ]; do
    [[ ! "$1" == [a-zA-Z_]*=* ]] && [[ ! "$1" == -* ]] && break
    shift
done

if [ -n "$1" ] && ! grep -we "$1" >/dev/null <<< "$IGNORED_COMMANDS"; then
    TITLE="${TITLE}:${@}"
else
    TITLE="${TITLE}:"
fi

[ -n "$STATIC_TITLE" ] && TITLE="{${STATIC_TITLE}}${TITLE}"

if [ -n "${TITLE:33}" ]; then
    echo -ne "\ek${TITLE:0:30}...\e\\"
else
    echo -ne "\ek${TITLE}\e\\"
fi
