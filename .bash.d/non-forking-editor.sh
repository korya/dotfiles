# Force using of `gvim -f' as VISUAL for programs that need it.
OIFS="$IFS"; IFS=:
for i in $NON_FORKING_EDITOR_PROGS; do
    [ -z "$i" ] && continue

    prev_alias="$(alias "$i" 2>/dev/null | sed 's/^alias .*='"'"'\(.*\)'"'"'$/\1/')"
    alias $i='VISUAL='"$VIM"'\ -f '"${prev_alias:-$i}"
done

IFS="$OIFS"

# reduce pollution
unset i prev_alias OIFS NON_FORKING_EDITOR_PROGS
