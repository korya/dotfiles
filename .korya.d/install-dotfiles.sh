#!/bin/bash
#
# install-dotfiles.sh — turn $HOME into the dotfiles git repo, without the
# manual merge-conflict dance.
#
# macOS seeds a fresh account with its own .zshrc, .zprofile, etc. A naive
# `git pull` into $HOME then refuses to overwrite those untracked files. So we
# move every file the repo tracks out of the way (into a timestamped backup)
# and only then check the branch out clean.
#
# On a machine that already has the dotfiles, this refuses to touch them.
#
# Run with DEBUG=1 to trace every command.
#
set -euo pipefail

REPO="${DOTFILES_REPO:-https://github.com/korya/dotfiles}"
BRANCH="${DOTFILES_BRANCH:-master}"

# --- logging ---
log()  { printf '\033[0;34m▸\033[0m %s\n' "$*"; }
ok()   { printf '\033[0;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m! %s\033[0m\n' "$*" >&2; }
[ -n "${DEBUG:-}" ] && set -x

# Normalize a git URL (https or ssh, with/without .git) to "owner/repo".
slug() { printf '%s\n' "$1" | sed -E 's#\.git$##; s#^.*[/:]([^/]+/[^/]+)$#\1#'; }

log "Installing $(slug "$REPO") (branch: $BRANCH) into \$HOME ($HOME)"
cd "$HOME"

# --- Already a git repo? Don't touch it. ---
# This installer is for a *fresh* machine. On a machine that already has the
# dotfiles checked out into $HOME — possibly on a personal branch with local
# changes — silently switching branches or hard-resetting would be destructive.
# So we refuse and let the user update on their own terms.
if [ -d "$HOME/.git" ]; then
  log "\$HOME is already a git repo — inspecting its origin..."
  existing="$(git remote get-url origin 2>/dev/null || true)"
  if [ -n "$existing" ] && [ "$(slug "$existing")" = "$(slug "$REPO")" ]; then
    ok "Already a checkout of $(slug "$REPO") — nothing to do."
    log "To update, manage it yourself, e.g.: git -C \"\$HOME\" pull"
    exit 0
  fi
  warn "Refusing: \$HOME is a git repo for a different origin (${existing:-none})."
  warn "Move it aside or install manually if that's intentional."
  exit 1
fi

# --- Fresh install. ---
log "Initializing git in \$HOME and wiring up the remote..."
[ -d .git ] || git init -q
git remote add origin "$REPO" 2>/dev/null || git remote set-url origin "$REPO"

log "Fetching origin/$BRANCH..."
git fetch -q origin "$BRANCH"

# Move aside any pre-existing files the checkout would clobber.
log "Backing up any pre-existing tracked files..."
backup="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
n=0
while IFS= read -r f; do
  [ -e "$HOME/$f" ] || continue
  mkdir -p "$backup/$(dirname "$f")"
  mv "$HOME/$f" "$backup/$f"
  log "  backed up: $f"
  n=$((n + 1))
done < <(git ls-tree -r --name-only "origin/$BRANCH")
if [ "$n" -gt 0 ]; then
  log "Moved $n pre-existing file(s) to $backup"
else
  log "No pre-existing files to back up."
fi

# Adopt the branch (safe now — nothing left to conflict with).
log "Checking out $BRANCH into \$HOME..."
git checkout -B "$BRANCH" "origin/$BRANCH" >/dev/null 2>&1
git branch --set-upstream-to="origin/$BRANCH" "$BRANCH" >/dev/null 2>&1 || true

ok "Dotfiles installed."
# NB: keep this an `if`, not `[ … ] && log` — the latter exits 1 when n=0
# (the normal fresh-machine case), which aborts the set -e bootstrap caller.
if [ "$n" -gt 0 ]; then
  log "Your previous files are preserved in: $backup"
fi
exit 0
