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
#   7. SSH key
#
# Idempotent: each step checks before acting, so re-running is safe.
# Run with DEBUG=1 to trace every command.
#
set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/korya/dotfiles/master/.korya.d"

# --- logging ---
step() { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$1"; }
log()  { printf '\033[0;34m  ▸\033[0m %s\n' "$*"; }
ok()   { printf '\033[0;32m  ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m  ! %s\033[0m\n' "$*" >&2; }
[ -n "${DEBUG:-}" ] && set -x

log "Starting bootstrap on $(hostname -s) at $(date '+%Y-%m-%d %H:%M:%S')"
[ -n "${DEBUG:-}" ] && log "DEBUG on — tracing every command."

# Run a .korya.d/ script, preferring the local copy (present once the dotfiles
# are installed) and falling back to fetching it over the network.
run_korya_script() {
  local name="$1"; shift
  if [ -f "$HOME/.korya.d/$name" ]; then
    log "Running local ~/.korya.d/$name"
    bash "$HOME/.korya.d/$name" "$@"
  else
    log "Fetching and running $name from $RAW_BASE"
    bash <(curl -fsSL "$RAW_BASE/$name") "$@"
  fi
}

# --- 1. Xcode Command Line Tools ---------------------------------------------
step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  ok "Already installed ($(xcode-select -p))."
else
  log "Triggering install — accept the dialog that appears, then wait..."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do
    log "Waiting for Command Line Tools to finish installing..."
    sleep 5
  done
  ok "Installed."
fi

# --- 2. Dotfiles -------------------------------------------------------------
step "Dotfiles"
run_korya_script install-dotfiles.sh

# --- 3. Homebrew -------------------------------------------------------------
step "Homebrew"
if command -v brew >/dev/null 2>&1; then
  ok "Already installed ($(command -v brew))."
else
  log "Installing Homebrew (this can take a few minutes)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "Homebrew installed."
fi
# Put brew on PATH for the rest of this script.
if [ -x /opt/homebrew/bin/brew ]; then
  log "Loading brew shellenv from /opt/homebrew (Apple Silicon)."
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  log "Loading brew shellenv from /usr/local (Intel)."
  eval "$(/usr/local/bin/brew shellenv)"
else
  warn "Could not locate the brew binary on the expected paths."
fi

# --- 4. Brewfile -------------------------------------------------------------
step "Packages (brew bundle)"
brewfile="$HOME/.korya.d/Brewfile"
log "Installing from $brewfile ($(grep -cE '^(brew|cask|mas) ' "$brewfile" 2>/dev/null || echo '?') entries)..."
brew bundle --file "$brewfile"
ok "Packages installed."

# --- 5. macOS defaults -------------------------------------------------------
step "macOS defaults"
run_korya_script macos.sh

# --- 6. Editor plugins -------------------------------------------------------
step "Editor plugins"
if command -v vim >/dev/null 2>&1; then
  log "Installing vim-plug plugins (headless)..."
  # --sync so install finishes before quit; qall! + </dev/null so a stray
  # startup prompt can never block the bootstrap.
  vim +'PlugInstall --sync' +qall! </dev/null && ok "vim plugins installed." \
    || warn "vim plugin install hiccup — run ':PlugInstall' by hand."
fi
if command -v nvim >/dev/null 2>&1; then
  log "Syncing LazyVim plugins (headless)..."
  nvim --headless "+Lazy! sync" +qa </dev/null && ok "nvim plugins synced." \
    || warn "nvim plugin sync hiccup — open nvim to finish."
fi

# --- 7. SSH key --------------------------------------------------------------
step "SSH key"
if [ -f "$HOME/.ssh/id_ed25519" ]; then
  ok "Key already exists ($HOME/.ssh/id_ed25519)."
else
  log "Generating an ed25519 key (you'll be asked for a passphrase)..."
  ssh-keygen -o -a 256 -t ed25519 -C "${USER}@$(hostname -s)" -f "$HOME/.ssh/id_ed25519"
  ok "Key generated."
fi

# --- Done --------------------------------------------------------------------
step "Done"
cat <<'EOF'
All scripted steps done. A few things still need a human:
  • Restart the shell (or `exec zsh`) to load the new environment.
  • System permissions: grant Docker and Tailscale access when prompted.
  • Add Russian/Hebrew input sources, set Caps Lock -> Escape (Settings > Keyboard).
  • Upload your SSH key to GitHub:
      gh auth login
      gh ssh-key add ~/.ssh/id_ed25519.pub -t "$(hostname -s)"
EOF
