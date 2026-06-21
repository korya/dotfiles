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

# Normalize a git URL (https or ssh, with/without .git) to "owner/repo".
slug() { printf '%s\n' "$1" | sed -E 's#\.git$##; s#^.*[/:]([^/]+/[^/]+)$#\1#'; }

cd "$HOME"

# --- Already a git repo? Don't touch it. ---
# This installer is for a *fresh* machine. On a machine that already has the
# dotfiles checked out into $HOME — possibly on a personal branch with local
# changes — silently switching branches or hard-resetting would be destructive.
# So we refuse and let the user update on their own terms.
if [ -d "$HOME/.git" ]; then
  existing="$(git remote get-url origin 2>/dev/null || true)"
  if [ -n "$existing" ] && [ "$(slug "$existing")" = "$(slug "$REPO")" ]; then
    echo "\$HOME is already a checkout of $(slug "$REPO") — nothing to do."
    echo "To update, manage it yourself, e.g.: git -C \"\$HOME\" pull"
    exit 0
  fi
  echo "Refusing: \$HOME is already a git repo (origin: ${existing:-none})." >&2
  echo "Move it aside or install manually if that's intentional." >&2
  exit 1
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
