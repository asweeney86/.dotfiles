# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Repo root, resolved through the ~/.zshrc symlink so the clone can live anywhere
DOTFILES="${${(%):-%x}:A:h:h}"

ZSH_THEME=""  # prompt is handled by oh-my-posh

ZVM_VI_ESCAPE_BINDKEY=jj
# Prefer git-installed fzf (supports `fzf --zsh`) over the old apt one in /usr/bin
[[ -d $HOME/.fzf/bin ]] && PATH="$HOME/.fzf/bin:${PATH//:$HOME\/.fzf\/bin/}"
#export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
#export FZF_BASE="/opt/homebrew/opt/fzf"

# Trimmed plugins for speed
plugins=(zsh-vi-mode fzf git docker)
ZSH_DISABLE_COMPFIX=true  # Skip compaudit for faster startup
source $ZSH/oh-my-zsh.sh

# fzf >= 0.48 supports `fzf --zsh`; fall back to Debian/Ubuntu packaged scripts for older apt versions
if fzf --zsh &>/dev/null; then
  zvm_after_init_commands+=('eval "$(fzf --zsh)"')
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  zvm_after_init_commands+=('source /usr/share/doc/fzf/examples/key-bindings.zsh; source /usr/share/doc/fzf/examples/completion.zsh')
fi

# User configuration

# Keep $PATH free of duplicates (zsh ties the `path` array to $PATH; -U drops repeats, first wins)
typeset -U path PATH

export EDITOR=nvim

HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

export PATH="${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/local/bin:$PATH"
export PATH="${HOMEBREW_PREFIX}/opt/openjdk/bin:$PATH"



# Make a picture a square
squarize() {
    pic=$1
    convert $pic -trim $pic
    width=$(identify -format "%w" $pic)
    height=$(identify -format "%h" $pic)
    new_dim=$((width > height ? width + 10 : height + 10))
    convert $pic -gravity center -extent "${new_dim}x${new_dim}" $pic
}

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config $DOTFILES/sweeney.omp.json)"
fi


# Kubectl (cached completion for speed)
if command -v kubectl &>/dev/null; then
    fpath=(~/.zsh/completions $fpath)
    [[ -f ~/.zsh/completions/_kubectl ]] && source ~/.zsh/completions/_kubectl
    alias k="kubectl"
    complete -F __start_kubectl k
fi
if [[ -f "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh" ]]; then
    source "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh"
    PROMPT='$(kube_ps1)'$PROMPT
    KUBE_PS1_SYMBOL_DEFAULT="ﴱ "
    kubeoff
fi


# Cache slow `<tool> completion` output and regenerate it weekly
_cached_completion() {
    local name=$1; shift
    local f="$HOME/.zsh/completions/cache/$name.zsh"
    if [[ ! -s $f || -n $f(#qN.mw+1) ]]; then
        mkdir -p "${f:h}"
        "$@" >| "$f" 2>/dev/null
    fi
    [[ -s $f ]] && source "$f"
}

if command -v helm &>/dev/null; then
    _cached_completion helm helm completion zsh
fi


# macOS-only DNS toggles
if [[ "$OSTYPE" == darwin* ]]; then
    alias adsON="networksetup -setdnsservers Wi-Fi 1.1.1.1"
    alias adsOFF="networksetup -setdnsservers Wi-Fi Empty"
    alias adsStatus="networksetup -getdnsservers Wi-Fi"
fi



include () {
    [[ -f "$1" ]] && source "$1"
}

include "$HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
include "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"

# asdf — source the right init script per OS, then add shims to PATH
if [[ "$(uname)" == "Darwin" ]]; then
    include "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh"
else
    include "$HOME/.asdf/asdf.sh"
fi
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# NPM completion (must be after asdf shims are in PATH)
if command -v npm &>/dev/null; then
    _cached_completion npm npm completion
fi

export BAT_THEME="Catppuccin-mocha"

export PATH="${HOMEBREW_PREFIX}/opt/llvm/bin:$PATH"
export PATH="${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# SDKMAN (lazy-loaded for speed - only loads when you use sdk/java/gradle/mvn)
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unset -f sdk java gradle mvn
  [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
  sdk "$@"
}
java() { sdk; java "$@"; }
gradle() { sdk; gradle "$@"; }
mvn() { sdk; mvn "$@"; }


alias brewup="brew update && brew upgrade -y && brew cleanup"
alias vim='nvim'

b64d() { echo -n "$1" | base64 --decode  }
# Copy stdin to the system clipboard (macOS / Wayland / X11)
_clip() {
    if command -v pbcopy &>/dev/null; then pbcopy
    elif command -v wl-copy &>/dev/null; then wl-copy
    elif command -v xclip &>/dev/null; then xclip -selection clipboard
    else cat >/dev/null
    fi
}
b64e() { echo -n "$1" | base64 | tee /dev/tty | _clip  }

fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" $fpath)

# Private env vars, API keys, and work-specific config (not tracked by git)
include "$DOTFILES/zsh/private/.env.zsh"

# Fall back to xterm-256color if the current TERM has no terminfo entry (e.g. xterm-ghostty on remote hosts)
if [[ -n "$TERM" ]] && ! infocmp "$TERM" &>/dev/null; then
  export TERM=xterm-256color
fi
