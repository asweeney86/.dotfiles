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

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install nodejs via asdf
echo "Installing nodejs"
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest

echo "Installing python"
asdf plugin-add python

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
