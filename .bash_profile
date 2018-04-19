KORYA_LOGIN_SHELL=1
KORYA_REMOTE_SHELL=
KORYA_BASHRC="$HOME/.bashrc"

# UPDATE: ne rabotaet v urxvt + v tty
# if ! who mom likes | awk '{print $5}' | grep '^(:' >/dev/null; then
#     KORYA_REMOTE_SHELL=1
# fi

if [ "X$SSH_CLIENT" != X ]; then
    KORYA_REMOTE_SHELL=1
fi

if [ -f "$KORYA_BASHRC" ]; then
    . "$KORYA_BASHRC"
fi

# Cleaning the environment
unset KORYA_LOGIN_SHELL KORYA_BASHRC KORYA_REMOTE_SHELL

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# added by Anaconda2 4.2.0 installer
# export PATH="/Users/korya/anaconda/bin:$PATH"

# export PATH="$HOME/.cargo/bin:$PATH"
