if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export FZF_DEFAULT_OPTS="--ansi"
export FZF_DEFAULT_COMMAND="fdfind --type file --color=always --follow --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
export FZF_ALT_C_COMMAND="fdfind --type directory --color=always --follow --hidden --exclude .git"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
export FZF_CTRL_R_OPTS="--preview 'echo {}'"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# export default kubernetes namespace
export EDITOR=vim
export SRC_DIR="${HOME}/src"
export PATH="${PATH}:${HOME}/bin:${KREW_ROOT:-$HOME/.krew}/bin"

export GOPATH="${HOME}/go"
export PATH="${GOPATH}/bin:${PATH}"
export NAMESPACE="cian"

source ~/.bash_aliases

complete -F __start_kubectl k

POWERLINEGO=$(command -v powerline-go)

function _update_ps1() {
    PS1="$($POWERLINEGO -newline -error $? -colorize-hostname -mode patched -jobs $(jobs -p | wc -l))"
}

if [ "$TERM" != "linux" ] && [ -f "${POWERLINEGO}" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

complete -C '/usr/bin/aws_completer' aws
