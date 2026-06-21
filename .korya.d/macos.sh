#!/bin/bash
#
# macos.sh — apply my preferred macOS UI defaults.
# Idempotent: safe to re-run. Run with `bash ~/.korya.d/macos.sh`.
# Run with DEBUG=1 to trace every command.
#
set -euo pipefail

# --- logging ---
log()  { printf '\033[0;34m▸\033[0m %s\n' "$*"; }
ok()   { printf '\033[0;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m! %s\033[0m\n' "$*" >&2; }
[ -n "${DEBUG:-}" ] && set -x

# --- Trackpad ---
log "Trackpad: enabling tap-to-click..."
# Enable "Tap to click" (current host + global so it sticks before login too).
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# --- Dock ---
log "Dock: moving left, magnification on, auto-hide on..."
# Move the Dock to the left — frees up the precious center of the screen.
defaults write com.apple.dock orientation -string "left"
# Enable magnification at a mid-level size (tweak largesize to taste).
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 64
# Auto-hide the Dock — out of sight until needed.
defaults write com.apple.dock autohide -bool true

# --- Desktops (Spaces) ---
log "Spaces: disabling most-recent-use reordering..."
# Stop macOS from reordering Spaces by most-recent-use (keeps ^1/^2 stable).
defaults write com.apple.dock mru-spaces -bool false

# --- Dock contents ---
# Wipe the stock app shortcuts and keep only what I use. Finder stays pinned by
# the system, so it doesn't need adding. (Launchpad.app was removed in macOS 26.)
if command -v dockutil >/dev/null 2>&1; then
  log "Dock: clearing stock apps, keeping Safari + Notes..."
  dockutil --no-restart --remove all >/dev/null
  for app in /Applications/Safari.app /System/Applications/Notes.app; do
    if [ -e "$app" ]; then
      dockutil --no-restart --add "$app" >/dev/null
      log "  added: $app"
    fi
  done
else
  warn "dockutil not found — skipping Dock cleanup (install via the Brewfile)."
fi

# --- Apply changes ---
log "Restarting Dock to apply changes..."
killall Dock

ok "macOS defaults applied. Some settings may need a logout to fully apply."
