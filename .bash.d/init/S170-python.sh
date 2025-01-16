if which uv >/dev/null 2>&1; then
  if [[ -n "${BASH_VERSION}" ]]; then
    eval "$(uv generate-shell-completion bash)"
  else
    eval "$(uv generate-shell-completion zsh)"
  fi
fi
