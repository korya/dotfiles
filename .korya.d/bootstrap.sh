#!/bin/bash
#
# bootstrap.sh — set up a fresh macOS machine end to end.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/korya/dotfiles/master/.korya.d/bootstrap.sh)
#
# Steps, in order:
#   1. Xcode Command Line Tools (provides a real git)
#   2. Install the dotfiles into $HOME       (.korya.d/install-dotfiles.sh)
#   3. Homebrew
#   4. Everything from the Brewfile          (.korya.d/Brewfile)
#   5. macOS UI defaults + Dock cleanup      (.korya.d/macos.sh)
#   6. Editor plugins (vim-plug, LazyVim)
#
# Idempotent: each step checks before acting, so re-running is safe.
#
set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/korya/dotfiles/master/.korya.d"

# Run a .korya.d/ script, preferring the local copy (present once the dotfiles
# are installed) and falling back to fetching it over the network.
run_korya_script() {
  local name="$1"; shift
  if [ -f "$HOME/.korya.d/$name" ]; then
    bash "$HOME/.korya.d/$name" "$@"
  else
    bash <(curl -fsSL "$RAW_BASE/$name") "$@"
  fi
}

step() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }

# --- 1. Xcode Command Line Tools ---------------------------------------------
step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  echo "Already installed."
else
  echo "Triggering install — accept the dialog that appears, then wait…"
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
  echo "Installed."
fi

# --- 2. Dotfiles -------------------------------------------------------------
step "Dotfiles"
run_korya_script install-dotfiles.sh

# --- 3. Homebrew -------------------------------------------------------------
step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Put brew on PATH for the rest of this script.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# --- 4. Brewfile -------------------------------------------------------------
step "Packages (brew bundle)"
brew bundle --file "$HOME/.korya.d/Brewfile"

# --- 5. macOS defaults -------------------------------------------------------
step "macOS defaults"
run_korya_script macos.sh

# --- 6. Editor plugins -------------------------------------------------------
step "Editor plugins"
if command -v vim >/dev/null 2>&1; then
  vim +PlugInstall +qall || echo "vim plugin install hiccup — run ':PlugInstall' by hand." >&2
fi
if command -v nvim >/dev/null 2>&1; then
  nvim --headless "+Lazy! sync" +qa || echo "nvim plugin sync hiccup — open nvim to finish." >&2
fi

# --- 7. SSH key --------------------------------------------------------------
step "SSH key"
if [ -f "$HOME/.ssh/id_ed25519" ]; then
  echo "Key already exists."
else
  echo "Generating an ed25519 key (you'll be asked for a passphrase)…"
  ssh-keygen -o -a 256 -t ed25519 -C "${USER}@$(hostname -s)" -f "$HOME/.ssh/id_ed25519"
fi

# --- Done --------------------------------------------------------------------
cat <<'EOF'

All scripted steps done. A few things still need a human:
  • Restart the shell (or `exec zsh`) to load the new environment.
  • System permissions: grant Docker and Tailscale access when prompted.
  • Add Russian/Hebrew input sources, set Caps Lock -> Escape (Settings > Keyboard).
  • Upload your SSH key to GitHub:
      gh auth login
      gh ssh-key add ~/.ssh/id_ed25519.pub -t "$(hostname -s)"
EOF
