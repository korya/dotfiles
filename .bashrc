test -z "$PLNTR_PROFILE_LOADED" && test -f "/Users/korya/dev/plntr/ansible/plntr_profile" && . "/Users/korya/dev/plntr/ansible/plntr_profile"
# /etc/bash/bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Include bashrc in non-onteractive shells as well
export BASH_ENV="$HOME/.bashrc"

export BASH_D="$HOME/.bash.d"

# Load required modules for non-interactive shell (numbered <100)
ls "$BASH_D"/init/S0[0-9][0-9]-*.sh >/dev/null 2>&1 && \
for m in "$BASH_D"/init/S0[0-9][0-9]-*.sh; do
    [ -f "$m" ] && . "$m"
done

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

# global settings
if [ -x /usr/bin/gvim ]; then
    VIM=/usr/bin/gvim
elif [ -x /usr/bin/vim ]; then
    VIM=/usr/bin/vim
fi
NON_FORKING_EDITOR_PROGS="$NON_FORKING_EDITOR_PROGS:svn:cvs:git:crontab"

# Load required modules for interactive shell (numbered >=100)
ls "$BASH_D"/init/S[1-9][0-9][0-9]-*.sh >/dev/null 2>&1 && \
for m in "$BASH_D"/init/S[1-9][0-9][0-9]-*.sh; do
    [ -f "$m" ] && . "$m"
done || echo 1

export CDPATH=".:~"
export HISTSIZE=100000
export HISTIGNORE="&:ls:sl:sl *:history:[bf]g:exit"
export PATH="$HOME/bin:$PATH"
export EDITOR="/usr/bin/vim"
#[ -n "$VIM" ] && export VISUAL="$VIM"
export HGUSER="Kochelorov Dmitriy <korey4ik@gmail.com>"

shopt -s cdable_vars
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s histappend
shopt -s huponexit

if [ "X$JUNGO" == "X" ]; then
    alias g="$HOME"/bin/my-g
fi

# Try to keep environment pollution down, EPA loves us.
unset JUNGO GVIM NON_FORKING_EDITOR_PROGS

# Enable auto-title for GNU screen(1)
if [ "${TERM}" == screen ]; then
    trap "${HOME}"'/.bash.d/screen-title.sh "$BASH_COMMAND"' DEBUG
fi

# SSH tunnel
# ssh -R 2222:localhost:22 thedude@blackbox.example.com
# ssh thedude@blackbox.example.com

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
