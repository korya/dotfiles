if [[ -z "${BASH_VERSION}" ]]; then
  return
fi

# Change the window title of X terminals 
case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
	PROMPT_COMMAND='echo -ne "\033]2;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
	;;
    screen)
	PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
	;;
esac

# Whenever displaying the prompt, write the previous line to disk
export PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND}; }history -a"

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
# safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
# match_lhs=""
# [[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
# [[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
# [[ -z ${match_lhs}    ]] \
#     && type -P dircolors >/dev/null \
#     && match_lhs=$(dircolors --print-database)
# [[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
    # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
    if type -P dircolors >/dev/null ; then
	if [[ -f ~/.dir_colors ]] ; then
	    eval $(dircolors -b ~/.dir_colors)
	elif [[ -f /etc/DIR_COLORS ]] ; then
	    eval $(dircolors -b /etc/DIR_COLORS)
	fi
    fi

# Possible solution for checking whether we connected from a remote host is:
# if who mom likes | awk '{print $5}' | grep '^(:' >/dev/null
# it should work for telnet too.
# > `who mom likes' does not work with non-login shell.
    if [[ ${EUID} == 0 ]] ; then
	PS1='\[\033[31m\]\h\[\033[34m\] \W \$\[\033[00m\] '
    elif [ "X$SSH_CLIENT" != X ]; then
        PS1='\[\033[0;32m\]\u@\[\033[0;33m\]\h[SSH]\[\033[0;34m\] \W \$\[\033[00m\] '
    else
	PS1='\[\033[32m\]\u@\h\[\033[34m\] \W \$\[\033[00m\] '
    fi

    alias ls='ls --color=auto'
    alias grep='grep --colour=auto'
    alias egrep='egrep --colour=auto'
else
    if [[ ${EUID} == 0 ]] ; then
	# show root@ when we don't have colors
	PS1='\u@\h \W \$ '
    else
	PS1='\u@\h \w \$ '
    fi
fi

# Try to keep environment pollution down, EPA loves us.
unset safe_term match_lhs use_color
