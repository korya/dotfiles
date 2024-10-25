if [[ -z "${BASH_VERSION}" ]]; then
  return
fi

# Bash shortcut C-o works as expected
/bin/stty discard undef
