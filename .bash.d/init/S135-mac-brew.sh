# Add user's bin/ to PATH

# Homebrew configuration: update PATH, MANPATH and bash completion
test -x /opt/homebrew/bin/brew && eval "$(/opt/homebrew/bin/brew shellenv)"

if [ -n "${HOMEBREW_PREFIX}" ]; then
  # Add GNU utils to PATH (prefer over default utils)
  for p in coreutils ed findutils gawk gnu-indent gnu-sed gnu-tar gnu-which grep make; do
    export PATH="${HOMEBREW_PREFIX}/opt/${p}/libexec/gnubin:${PATH}"
    export MANPATH="${HOMEBREW_PREFIX}/opt/${p}/libexec/gnuman:${MANPATH}"
  done
  
  # Add GNU curl to PATH
  export PATH="$(brew --prefix curl)/bin:/usr/local/bin:${PATH}"
  export MANPATH="$(brew --prefix curl)/share/man:${MANPATH}"

  # Add GOPATH-based install location to PATH
  export PATH="${PATH}:${GOPATH:-${HOME}/go}/bin"

  if [ -n "${HOMEBREW_PREFIX}" ]; then
  # Add autocomplete
  for f in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
    [[ -f "${f}" ]] && source "${f}"
  done
  if [[ -f "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  fi
fi
fi

# vim: ft=sh sw=2 et :
