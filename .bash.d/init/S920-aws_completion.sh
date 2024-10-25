if [[ -z "${BASH_VERSION}" ]]; then
  return
fi

complete -C aws_completer aws
