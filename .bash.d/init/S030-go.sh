# go-vim plugin uses vim's `system()` that creates a subshell
# which reruns the rc file. As a consequence, an inherited value
# of GOPATH is overridden by a default one.
if [ -z "$GOPATH" ]; then
  export GOPATH="$HOME/dev/golang"
  export PATH="$PATH:$GOPATH/bin:/usr/local/opt/go/libexec/bin"
fi
