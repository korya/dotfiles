KORYA_LOGIN_SHELL=1
KORYA_REMOTE_SHELL=

# UPDATE: ne rabotaet v urxvt + v tty
# if ! who mom likes | awk '{print $5}' | grep '^(:' >/dev/null; then
#     KORYA_REMOTE_SHELL=1
# fi

if [ "X$SSH_CLIENT" != X ]; then
    KORYA_REMOTE_SHELL=1
fi

test -f ~/.bashrc && source ~/.bashrc

# Cleaning the environment
unset KORYA_LOGIN_SHELL KORYA_REMOTE_SHELL

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"


# Created by `pipx` on 2023-11-28 15:23:57
export PATH="$PATH:/Users/dmitri/.local/bin"

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE='/opt/homebrew/bin/micromamba';
export MAMBA_ROOT_PREFIX='/Users/dmitri/micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
