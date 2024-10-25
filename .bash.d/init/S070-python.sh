# vim: ft=sh :

python_user_prefix=''
if command -v python >/dev/null 2>&1; then
  python_user_prefix="$(python -m site --user-base)"
elif command -v python3 >/dev/null 2>&1; then
  python_user_prefix="$(python3 -m site --user-base)"
fi
if [[ -n "${python_user_prefix}" ]]; then
  export PATH="${PATH}:${python_user_prefix}/bin"
fi
unset python_user_prefix

# pipx
if [[ -x "$(which pipx 2>/dev/null)" ]]; then
  eval "$(register-python-argcomplete pipx)"
fi

# conda
if [[ -x "$(which conda 2>/dev/null)" ]]; then
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$("${HOMEBREW_PREFIX}/Caskroom/miniconda/base/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "${HOMEBREW_PREFIX}/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
      . "${HOMEBREW_PREFIX}/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
      export PATH="${HOMEBREW_PREFIX}/Caskroom/miniconda/base/bin:$PATH"
    fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<
fi
