# dotfiles

Personal config for macOS and Ubuntu: zsh, tmux, neovim (LazyVim), ghostty, git, oh-my-posh.

## Install

    git clone <repo> ~/.dotfiles && ~/.dotfiles/install.sh

`install.sh` is idempotent. It installs packages (Brewfile on macOS, apt and release downloads on Linux),
installs asdf runtimes pinned in `asdf/.tool-versions`, and symlinks configs. An existing file at a link
target is moved to `<target>.bak`.

## Layout

| Path | Linked to |
| --- | --- |
| `zsh/.zshrc` | `~/.zshrc` |
| `tmux/` | `~/.tmux`, `~/.tmux.conf` |
| `nvim/` | `~/.config/nvim` |
| `ghostty/` | `~/.config/ghostty` |
| `git/config`, `git/ignore` | `~/.config/git/` |
| `lazygit/config.yml` | lazygit config dir (`lazygit --print-config-dir`) |
| `asdf/.tool-versions` | `~/.tool-versions` |

## Local-only config (not tracked)

- `zsh/private/.env.zsh`: API keys and work config. Created empty by `install.sh`.
- `~/.gitconfig`: identity and machine-specific settings. It overrides `git/config`.

## Updating

- Bump a runtime: edit `asdf/.tool-versions`, then run `install.sh`.
- Find packages installed but not in the Brewfile: `brew bundle cleanup --file=Brewfile`.
- CI (`.github/workflows/ci.yml`) runs shellcheck, `zsh -n` and `stylua --check`.
