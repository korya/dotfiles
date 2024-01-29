#!/bin/bash

PREFIX="${HOME}"
HOST=10.71.3.36
USER=dmitri
SVN_REPO="http://korya-dotfiles.googlecode.com/svn/trunk/"

# Migration mode:
#  FULL - migrate everything
#  ESSENTIAL - migrate only essential files
MIGRATION=FULL

grant_access_to_remote()
{
    local SSH_DIR="${HOME}/.ssh"
    local IDENTITY="${SSH_DIR}/id_rsa"

    [ -d "$SSH_DIR" ] || mkdir -p "$SSH_DIR"
    [ -f "$IDENTITY" ] || ssh-keygen -t rsa -f "$IDENTITY" -N ""

    ssh-copy-id -i "${IDENTITY}.pub" $USER@$HOST
}

log()
{
    echo "$@" >&2
}

err()
{
   log "$@"; exit 1
}

verify_prerequisites()
{
    REQUIRED_BINS="svn ssh rsync ssh-keygen ssh-copy-id"

    # XXX verify that all prerequisites are in PATH
}

tmp="$(mktemp -d /tmp/dmitri-dots-XXX)"
trap 'rm -rf '"$tmp"' 2>/dev/null' 0 1 2 15

verify_prerequisites

(
    cd "$tmp"

    grant_access_to_remote

    svn checkout "$SVN_REPO" .

    SYNC_DIRS=".bash.d bin .vim project rg/wiki rg/patch.d .bash_history"
    [ "$MIGRATION" == "FULL" ] &&
	{ SYNC_DIRS="$SYNC_DIRS .icedove .mozilla kde-exported-settings"; }

    for d in $SYNC_DIRS; do
	rsync -avz $USER@$HOST:~/"$d" .
    done
)

# Replace file if it exists already
# XXX Reimplement with tar
mkdir -p "$PREFIX"
for i in $(ls -a "$tmp" | grep -vE '^(\.|\.\.)$'); do
    log "install: $tmp/$i -> $PREFIX/$i"
    mv -bf "$tmp"/"$i" "$PREFIX"
done
