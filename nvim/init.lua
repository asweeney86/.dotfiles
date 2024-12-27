-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.python3_host_prog = "/Users/andrewsweeney/.dotfiles/nvim/python/.venv/bin/python"
vim.g.python_host_prog = "/Users/andrewsweeney/.dotfiles/nvim/python/.venv/bin/python"

require("config.lazy")
