# /etc/bash/bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

export EDITOR="vim"
#[ -n "$VIM" ] && export VISUAL="$VIM"

export BASH_D="$HOME/.bash.d"

# Load required modules for non-interactive shell (numbered <100)
ls "$BASH_D"/init/S0[0-9][0-9]-*.sh >/dev/null 2>&1 && \
for m in "$BASH_D"/init/S0[0-9][0-9]-*.sh; do
  if [[ -f "$m" ]]; then
    source "$m"
  fi
done

# Test for an interactive shell. There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
  # Shell is non-interactive. Be done now!
  return
fi

# Load required modules for interactive shell (numbered >=100)
ls "$BASH_D"/init/S[1-9][0-9][0-9]-*.sh >/dev/null 2>&1 && \
for m in "$BASH_D"/init/S[1-9][0-9][0-9]-*.sh; do
  if [[ -f "$m" ]]; then
    source "$m" || echo "[E] Failed loading ${m}"
  fi
done

export CDPATH=".:~"
export HISTSIZE=100000
export HISTIGNORE="&:ls:sl:sl *:history:[bf]g:exit"
export PATH="$HOME/bin:$PATH"

shopt -s cdable_vars
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s histappend
shopt -s huponexit

# Try to keep environment pollution down, EPA loves us.
unset BASH_D

# Enable auto-title for GNU screen(1)
if [ "${TERM}" == screen ]; then
  trap "${HOME}"'/.bash.d/screen-title.sh "$BASH_COMMAND"' DEBUG
fi

# set PATH so it includes user's private bin if it exists
test -d "$HOME/bin" && export PATH="$HOME/bin:$PATH"
test -d /usr/local/opt/qt/bin && export PATH="/usr/local/opt/qt/bin:$PATH"
test -d /usr/local/opt/openjdk/bin && export PATH="/usr/local/opt/openjdk/bin:$PATH"

# SSH tunnel
# ssh -R 2222:localhost:22 thedude@blackbox.example.com
# ssh thedude@blackbox.example.com

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
test -f ~/.plntr.d/bashrc && source ~/.plntr.d/bashrc

# Created by `pipx` on 2023-11-28 15:23:57
export PATH="$PATH:/Users/dmitri/.local/bin"
