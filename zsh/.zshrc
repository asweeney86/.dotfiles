# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#

ZVM_VI_ESCAPE_BINDKEY=jj
#export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
#export FZF_BASE="/opt/homebrew/opt/fzf"

# Trimmed plugins for speed (removed: docker-compose, asdf [loaded manually], colored-man-pages, colorize)
plugins=(zsh-vi-mode fzf git docker)
ZSH_DISABLE_COMPFIX=true  # Skip compaudit for faster startup
source $ZSH/oh-my-zsh.sh

zvm_after_init_commands+=('eval "$(fzf --zsh)"')

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export EDITOR=nvim

HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/local/bin:$PATH"
export PATH="${PATH}:${HOME}/.krew/bin"
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
    eval "$(oh-my-posh init zsh --config $HOME/.dotfiles/sweeney.omp.json)"
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


if command -v helm &>/dev/null; then
    source <(helm completion zsh)
fi


# Manually set arch
export TFENV_ARCH=arm64


alias adsON="networksetup -setdnsservers Wi-Fi 1.1.1.1"
alias adsOFF="networksetup -setdnsservers Wi-Fi Empty"
alias adsStatus="networksetup -getdnsservers Wi-Fi"


alias icat="kitty +kitten icat"

if command -v github-copilot-cli &>/dev/null; then
    eval "$(github-copilot-cli alias -- "$0")"
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
    eval "$(npm completion)"
fi

export BAT_THEME="Catppuccin-mocha"

export PATH="${HOMEBREW_PREFIX}/opt/llvm/bin:$PATH"
export PATH="${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# SDKMAN (lazy-loaded for speed - only loads when you use sdk/java/gradle/maven)
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unset -f sdk java gradle maven mvn
  [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
  sdk "$@"
}
java() { sdk; java "$@"; }
gradle() { sdk; gradle "$@"; }
maven() { sdk; maven "$@"; }
mvn() { sdk; mvn "$@"; }


alias brewup="brew update && brew upgrade && brew cleanup"
alias vim='nvim'

b64d() { echo -n "$1" | base64 --decode  }
b64e() { echo -n "$1" | base64 | tee /dev/tty | pbcopy  }

fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" $fpath)

# Private env vars, API keys, and work-specific config (not tracked by git)
include "$HOME/.dotfiles/zsh/private/.env.zsh"

# Fall back to xterm-256color if the current TERM has no terminfo entry (e.g. xterm-ghostty on remote hosts)
if [[ -n "$TERM" ]] && ! infocmp "$TERM" &>/dev/null; then
  export TERM=xterm-256color
fi
