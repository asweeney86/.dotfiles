-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local python_host = vim.fn.expand("~/.dotfiles/nvim/python/.venv/bin/python")
if vim.fn.executable(python_host) == 1 then
  vim.g.python3_host_prog = python_host
end

require("config.lazy")
