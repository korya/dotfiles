#!/bin/sh

# The script runs gvimdiff for 'svn diff' command
# Add to ~/.subversion/config:
#  diff-cmd = ABSOLUTE-PATH-TO-THE-SCRIPT

DIFF='gvimdiff'
DIFFOPT='-f'
OLD="$6"
NEW="$7"

eval "$DIFF $DIFFOPT $OLD $NEW"
