#!/bin/bash
#
# macos.sh — apply my preferred macOS UI defaults.
# Idempotent: safe to re-run. Run with `bash ~/.korya.d/macos.sh`.
#
set -euo pipefail

# --- Trackpad ---
# Enable "Tap to click" (current host + global so it sticks before login too).
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# --- Dock ---
# Move the Dock to the left — frees up the precious center of the screen.
defaults write com.apple.dock orientation -string "left"

# Enable magnification at a mid-level size (tweak largesize to taste).
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 64

# Auto-hide the Dock — out of sight until needed.
defaults write com.apple.dock autohide -bool true

# --- Desktops (Spaces) ---
# Stop macOS from reordering Spaces by most-recent-use (keeps ^1/^2 stable).
defaults write com.apple.dock mru-spaces -bool false

# --- Dock contents ---
# Wipe the stock app shortcuts and keep only what I use. Finder stays pinned by
# the system, so it doesn't need adding. (Launchpad.app was removed in macOS 26.)
if command -v dockutil >/dev/null 2>&1; then
  dockutil --no-restart --remove all >/dev/null
  for app in /Applications/Safari.app /System/Applications/Notes.app; do
    [ -e "$app" ] && dockutil --no-restart --add "$app" >/dev/null
  done
else
  echo "dockutil not found — skipping Dock cleanup (install via the Brewfile)." >&2
fi

# --- Apply changes ---
# Restart the Dock so all of the above takes effect immediately.
killall Dock

echo "macOS defaults applied. Some settings may need a logout to fully apply."
