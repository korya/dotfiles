# # XXX detect the best vim binary: vim, gvim, mvim or nvim
# VIM=vim
# 
# # Force using of `$VIM -f' as VISUAL for programs that need it.
# for i in svn cvs git crontab; do
#     [ -z "$i" ] && continue
# 
#     prev_alias="$(alias "$i" 2>/dev/null | sed -e "s/^[^=]*='//" -e "s/'$//")"
#     alias $i='VISUAL='"${VIM:-vim}"'\ -f '"${prev_alias:-$i}"
# done
# 
# # reduce pollution
# unset i prev_alias
