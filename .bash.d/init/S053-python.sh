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
