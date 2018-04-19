alias d='docker '
alias ds='docker ps'
alias di='docker images'
alias drma='docker rm -f $(docker ps -qa)'
alias drti='docker run -ti --rm'
# alias dig='drti planitar/dev-base dig'
alias ddig='drti planitar/dev-base dig @172.17.42.1'
alias dping='drti planitar/base ping'

d_ip() {
  docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$1"
}

d_port() {
  docker inspect -f "{{ (index (index .NetworkSettings.Ports \"$2/tcp\") 0).HostPort }}" "$1" || echo 0
}

d_ex() {
  docker exec -ti $1 /bin/bash
}
