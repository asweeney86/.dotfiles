#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

pushd "$SCRIPT_DIR"

OS="$(uname -s)"

# ── Package installation ──────────────────────────────────────────────────────

if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
        echo "Please install brew: https://brew.sh"
        exit 1
    fi
    echo "📦 Installing brew packages"
    brew bundle install --file=Brewfile
    export PATH="$HOME/.asdf/shims:$PATH"

elif [[ "$OS" == "Linux" ]]; then
    echo "📦 Installing apt packages"
    sudo apt-get update -y
    sudo apt-get install -y \
        bat \
        build-essential \
        clang-format \
        cmake \
        cpanminus \
        curl \
        fd-find \
        fzf \
        git \
        git-extras \
        git-lfs \
        gpg \
        htop \
        httpie \
        imagemagick \
        jq \
        libbz2-dev \
        libffi-dev \
        liblzma-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libclang-dev \
        libyaml-dev \
        libmsgpack-dev \
        llvm \
        luarocks \
        nmap \
        php \
        ripgrep \
        shellcheck \
        tmux \
        tree \
        unzip \
        urlview \
        watch \
        watchman \
        wget \
        wrk \
        zlib1g-dev \
        zsh

    # neovim — Ubuntu 22.04 apt only has 0.6.1; install/upgrade from GitHub releases
    NVIM_LATEST=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest \
        | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
    NVIM_CURRENT=$(nvim --version 2>/dev/null | awk 'NR==1{print $2}' | tr -d 'v')
    if [[ "$NVIM_CURRENT" != "$NVIM_LATEST" ]]; then
        echo "📦 Installing neovim v${NVIM_LATEST} from GitHub releases (current: ${NVIM_CURRENT:-none})"
        ARCH="$(uname -m)"
        case "$ARCH" in
            x86_64)        NVIM_ARCH="x86_64" ;;
            aarch64|arm64) NVIM_ARCH="arm64" ;;
            *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        curl -fsSLo /tmp/nvim-linux.tar.gz \
            "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"
        sudo tar xzf /tmp/nvim-linux.tar.gz -C /usr/local --strip-components=1
        rm /tmp/nvim-linux.tar.gz
    else
        echo "  neovim v${NVIM_CURRENT} is up to date"
    fi

    if ! command -v asdf &>/dev/null; then
        echo "📦 Installing asdf"
        ARCH="$(uname -m)"
        case "$ARCH" in
            x86_64)        ASDF_ARCH="amd64" ;;
            aarch64|arm64) ASDF_ARCH="arm64" ;;
            *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        ASDF_TAG=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
            https://github.com/asdf-vm/asdf/releases/latest | sed 's|.*/tag/||')
        curl -fsSL "https://github.com/asdf-vm/asdf/releases/download/${ASDF_TAG}/asdf-${ASDF_TAG}-linux-${ASDF_ARCH}.tar.gz" \
            | sudo tar xz -C /usr/local/bin
    fi
    export PATH="$HOME/.asdf/shims:$PATH"

    # lazygit
    if ! command -v lazygit &>/dev/null; then
        echo "📦 Installing lazygit"
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
            | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
        ARCH="$(uname -m)"
        case "$ARCH" in
            x86_64)        LG_ARCH="x86_64" ;;
            aarch64|arm64) LG_ARCH="arm64" ;;
            *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        curl -Lo /tmp/lazygit.tar.gz \
            "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit /usr/local/bin/lazygit
    fi

    # oh-my-posh
    if ! command -v oh-my-posh &>/dev/null; then
        echo "📦 Installing oh-my-posh"
        mkdir -p "$HOME/.local/bin"
        curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
    fi

    # rust / cargo (needed for xsv and other cargo-installed tools)
    if ! command -v cargo &>/dev/null; then
        echo "📦 Installing rust"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        # shellcheck disable=SC1091
        . "$HOME/.cargo/env"
    fi

    # xsv
    if ! command -v xsv &>/dev/null; then
        echo "📦 Installing xsv"
        cargo install xsv
    fi

    # fd — apt ships 8.3.1 but Snacks.picker requires >=8.4; install latest via cargo
    if ! command -v fd &>/dev/null || \
        [[ "$(fd --version 2>/dev/null | awk '{split($2,a,"."); print a[1]*1000+a[2]}')" -lt 8004 ]]; then
        echo "📦 Installing fd via cargo"
        cargo install fd-find
    fi
    # Shadow apt's old fdfind with the cargo-built fd so nvim/Snacks.picker picks it up
    sudo ln -sf "$HOME/.cargo/bin/fd" /usr/local/bin/fdfind

    # tree-sitter-cli — must be built via cargo, not npm; the npm prebuilt binary
    # requires GLIBC 2.39 but Ubuntu 22.04 ships 2.35, causing all parser builds to fail
    if ! command -v tree-sitter &>/dev/null; then
        echo "📦 Installing tree-sitter-cli via cargo"
        cargo install tree-sitter-cli
    fi

    # neovim node provider — install against the system node that nvim resolves
    # (not the asdf-managed one, which may not be in nvim's PATH)
    SYSTEM_NPM="$(command -v npm || true)"
    if [[ -n "$SYSTEM_NPM" ]]; then
        echo "📦 Installing neovim npm package"
        sudo "$SYSTEM_NPM" install -g neovim
    fi

    # awscli v2
    if ! command -v aws &>/dev/null; then
        echo "📦 Installing awscli"
        ARCH="$(uname -m)"
        case "$ARCH" in
            x86_64)        AWS_ARCH="x86_64" ;;
            aarch64|arm64) AWS_ARCH="aarch64" ;;
            *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o /tmp/awscliv2.zip
        unzip -q /tmp/awscliv2.zip -d /tmp
        sudo /tmp/aws/install
        rm -rf /tmp/aws /tmp/awscliv2.zip
    fi

    # go — use asdf so it's version-managed
    if ! command -v go &>/dev/null; then
        echo "📦 Installing go via asdf"
        asdf plugin add golang https://github.com/asdf-community/asdf-golang.git || true
        asdf install golang latest
        asdf set --home golang latest
    fi

else
    echo "Unsupported OS: $OS"
    exit 1
fi

# ── default shell ─────────────────────────────────────────────────────────────

ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    echo "🔧 Setting default shell to zsh"
    # Ensure zsh is in /etc/shells (required by chsh)
    if ! grep -qxF "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    sudo chsh -s "$ZSH_PATH" "$USER"
else
    echo "  zsh is already the default shell, skipping"
fi

# ── oh-my-zsh ─────────────────────────────────────────────────────────────────

echo "📦 Installing oh-my-zsh"
if [[ ! -d ~/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "  oh-my-zsh already exists, skipping"
fi

echo "📦 Installing zsh-vi-mode"
if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-vi-mode ]]; then
    git clone https://github.com/jeffreytse/zsh-vi-mode \
        ~/.oh-my-zsh/custom/plugins/zsh-vi-mode
else
    echo "  zsh-vi-mode already exists, skipping"
fi

echo "🔗 Linking .zshrc"
ln -sf "$SCRIPT_DIR/zsh/.zshrc" ~/.zshrc

# ── asdf language runtimes ────────────────────────────────────────────────────

echo "📦 Installing asdf nodejs"
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git 2>/dev/null || true
asdf install nodejs latest
asdf set --home nodejs latest
npm install -g neovim

if [[ "$OS" == "Linux" ]]; then
    if ! command -v diff-so-fancy &>/dev/null; then
        echo "📦 Installing diff-so-fancy"
        npm install -g diff-so-fancy
    fi
fi

echo "📦 Installing asdf python"
asdf plugin add python https://github.com/asdf-community/asdf-python.git 2>/dev/null || true
# Use latest stable 3.13.x — filter out free-threaded (t-suffix) builds
PYTHON_VERSION=$(asdf list all python | grep -E "^3\.13\.[0-9]+$" | tail -1)
asdf install python "$PYTHON_VERSION"
asdf set --home python "$PYTHON_VERSION"
pip install neovim

echo "📦 Installing asdf ruby"
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git 2>/dev/null || true
asdf install ruby latest
asdf set --home ruby latest
gem install neovim

echo "📦 Installing perl neovim bindings"
if [[ "$OS" == "Darwin" ]]; then
    "$(brew --prefix perl)/bin/cpanm" -n Neovim::Ext || echo "  Warning: Neovim::Ext install failed (optional)"
else
    cpanm -n Neovim::Ext || echo "  Warning: Neovim::Ext install failed (optional)"
fi

# ── tmux ──────────────────────────────────────────────────────────────────────

echo "📦 Configuring tmux"
if [[ ! -d ~/.tmux ]]; then
    ln -s "$SCRIPT_DIR/tmux" ~/.tmux
else
    echo "  ~/.tmux already exists, skipping"
fi

if [[ ! -f ~/.tmux.conf ]]; then
    ln -s "$SCRIPT_DIR/tmux/.tmux.conf" ~/.tmux.conf
else
    echo "  ~/.tmux.conf already exists, skipping"
fi

echo "📦 Installing tmux tpm"
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
        && ~/.tmux/plugins/tpm/bin/install_plugins
else
    echo "  tpm already exists, skipping"
fi

# ── neovim ────────────────────────────────────────────────────────────────────

echo "📦 Configuring neovim"
if [[ ! -d ~/.config/nvim ]]; then
    mkdir -p ~/.config
    ln -s "$SCRIPT_DIR/nvim" ~/.config/nvim
else
    echo "  ~/.config/nvim already exists, skipping"
fi

# ── kitty (macOS / GUI only) ──────────────────────────────────────────────────

if [[ "$OS" == "Darwin" ]]; then
    echo "📦 Configuring Kitty"
    if [[ ! -d ~/.config/kitty ]]; then
        ln -s "$SCRIPT_DIR/kitty" ~/.config/kitty
    else
        echo "  ~/.config/kitty already exists, skipping"
    fi
fi

echo "🏁 Setup complete!"
