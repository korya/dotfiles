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
# Idempotent: re-running just fast-forwards the already-initialized repo.
#
set -euo pipefail

REPO="${DOTFILES_REPO:-https://github.com/korya/dotfiles}"
BRANCH="${DOTFILES_BRANCH:-master}"

cd "$HOME"

# --- Already set up? Just update and bail. ---
if [ -d "$HOME/.git" ] && git rev-parse --verify -q HEAD >/dev/null 2>&1; then
  echo "Dotfiles repo already initialized — fast-forwarding."
  git fetch -q origin "$BRANCH"
  git checkout -q "$BRANCH"
  git pull -q --ff-only origin "$BRANCH" \
    || echo "Could not fast-forward; resolve manually with 'git status'." >&2
  exit 0
fi

# --- Fresh install. ---
[ -d .git ] || git init -q
git remote add origin "$REPO" 2>/dev/null || git remote set-url origin "$REPO"
git fetch -q origin "$BRANCH"

# Move aside any pre-existing files the checkout would clobber.
backup="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
while IFS= read -r f; do
  [ -e "$HOME/$f" ] || continue
  mkdir -p "$backup/$(dirname "$f")"
  mv "$HOME/$f" "$backup/$f"
done < <(git ls-tree -r --name-only "origin/$BRANCH")

# Adopt the branch (safe now — nothing left to conflict with).
git checkout -B "$BRANCH" "origin/$BRANCH"
git branch --set-upstream-to="origin/$BRANCH" "$BRANCH" >/dev/null 2>&1 || true

if [ -d "$backup" ]; then
  echo "Done. Pre-existing files backed up to: $backup"
else
  echo "Done."
fi
