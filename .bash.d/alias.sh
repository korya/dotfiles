## Common aliases

alias ll='ls -l'
alias llh='ls -lh'
alias lla='ls -la'
alias t2='TERM=xterm ssh so4i2014@stud.technion.ac.il'
alias cx='chmod a+x'
alias lor_fortune='fortune /usr/share/games/fortunes/lor'
alias SL='sl -e'
alias l='sl -e'
alias sls='sl'
alias bs='xset dpms force suspend'
alias bse='bs && exit'
alias rt='PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin rt'
alias Ъ='/bin/true'
alias cs='cscope -Rbq'
alias wi='wicd-client'
alias nt='wget -O- www.ru'
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
