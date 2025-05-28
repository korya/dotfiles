## Common aliases

alias ll='ls -l'
alias llh='ls -lh'
alias lla='ls -la'
alias t2='TERM=xterm ssh so4i2014@stud.technion.ac.il'
alias cx='chmod a+x'
alias SL='sl -e'
alias l='sl -e'
alias sls='sl'
alias Ъ='/bin/true'
# alias tklor='wish8.5 /usr/bin/tkLOR'

alias c1="awk '{print \$1}'"
alias c2="awk '{print \$2}'"
alias c3="awk '{print \$3}'"
alias c4="awk '{print \$4}'"
alias c5="awk '{print \$5}'"

# git aliases
alias gco='git checkout'
alias gss='git status -s'
alias gdt='git difftool'
git-reset-file() {
  git reset @~ "$@" && git commit --amend --no-edit
}

if which bat >/dev/null 2>&1; then
  alias cat=bat

  export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

  batdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
  }

  help() {
    "$@" --help 2>&1 | bat --plain --language=help -P
  }
  # w/ pager
  h() {
    "$@" --help 2>&1 | bat --plain --language=help
  }
fi
