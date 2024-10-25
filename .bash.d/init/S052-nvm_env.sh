export NVM_DIR="$HOME/.nvm"

if [ -n "${HOMEBREW_PREFIX}" ]; then
  # Load nvm
  [ -s "${HOMEBREW_PREFIX}/opt/nvm/nvm.sh" ] && \. "${HOMEBREW_PREFIX}/opt/nvm/nvm.sh"
  # Load bash completion
  if [[ -n "${BASH_VERSION}" ]]; then
    [ -s "${HOMEBREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && \. "${HOMEBREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"
  fi
fi
