# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

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

plugins=(zsh-vi-mode fzf git docker docker-compose asdf colored-man-pages)
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

export PATH="/usr/local/bin:$PATH"
export PATH=$HOME/local/bin:$PATH
export PATH="${PATH}:${HOME}/.krew/bin"
export PATH="/Users/asweeney/dev/scope3/scripts/:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"


# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

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


# Jira helper functions
# source ~/local/bin/jira.sh

# Kubectl
source <(kubectl completion zsh)
alias k="kubectl"
#alias k="kubecolor"
complete -F __start_kubectl k
source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
PROMPT='$(kube_ps1)'$PROMPT
KUBE_PS1_SYMBOL_DEFAULT="ﴱ "
kubeoff


# The next line updates PATH for Netlify's Git Credential Helper.
#source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
if [ -z helm ]; then
    source <(helm completion zsh)
fi

# NPM completeion
source <(npm completion)

# Manually set arch
export TFENV_ARCH=arm64


# Make Docker work on M1
#export DOCKER_BUILDKIT=1 # Buildkit is required for multi platform builds
#export COMPOSE_DOCKER_CLI_BUILD=1  # CLI instead of docker-compose python wrapper
#export DOCKER_DEFAULT_PLATFORM=linux/arm64 # Set default build platform instead of sepcifying in dockerfile

alias adsON="networksetup -setdnsservers Wi-Fi 1.1.1.1"
alias adsOFF="networksetup -setdnsservers Wi-Fi Empty"
alias adsStatus="networksetup -getdnsservers Wi-Fi"

# check if .zcompdump exists if so remove and reinit compinit
if [ -f ~/.zcompdump ]; then
  rm -f "$HOME/.zcompdump"
  compinit
fi

#if command -v pyenv 1>/dev/null 2>&1; then
#  eval "$(pyenv init -)"
#fi

#if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

#export JIRA_API_TOKEN=''
#alias jira_me="jira issue list -a$(jira me) -s~Done"
#alias jira_nobody="jira issue list -ax --created week"
alias icat="kitty +kitten icat"

if [ -z github-copilot-cli ]; then
    eval "$(github-copilot-cli alias -- "$0")"
fi

include () {
    [[ -f "$1" ]] && source "$1"
}


include "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
include "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
include "$(brew --prefix asdf)/libexec/asdf.sh"

export BAT_THEME="Catppuccin-mocha"

export PATH="$(brew --prefix llvm)/bin/:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


alias brewup="brew update && brew upgrade && brew cleanup"
alias vim='nvim'

b64d() { echo -n "$1" | base64 --decode  }
b64e() { echo -n "$1" | base64 | tee /dev/tty | pbcopy  }

fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(fzf --zsh)"
