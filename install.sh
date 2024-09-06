#/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

pushd $SCRIPT_DIR

if [ -z brew ]; then
    echo "Please install brew"
    exit 1
fi

echo "📦 Installing brew packages"
brew bundle install --file=Brewfile

echo "Install oh-my-zsh"
if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "❌ Oh-my-zsh already exists. skipping setup"
fi

# install nodejs via asdf
echo "📦 Installing asdf nodejs"
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest

echo "📦 Installing asdf python"
asdf plugin-add python

echo "📦 Configuring tmux"
# check to see if tpm already exists
if [ ! -d ~/.tmux ]; then
    ln -s $SCRIPT_DIR/tmux ~/.tmux
else
    echo "❌ Tmux already exists. skipping setup"
fi

echo "📦 Installing tmux tpm"
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins

else
    echo "❌ Tpm already exists. skipping setup"
fi

echo "📦 Configuring neovim"
# chcek to see if neovim configu already exists
if [ ! -d ~/.config/nvim ]; then
    ln -s $SCRIPT_DIR/nvim ~/.config/nvim
else
    echo "❌ neovim config already exists. skipping setup"
fi

echo "👉 Being Lazy... kitty needs to be configured manually"

echo "🏁 Setup complete! 🏁"
