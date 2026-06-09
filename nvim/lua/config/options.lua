-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 8

vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.termguicolors = true
vim.opt.colorcolumn = "80"

vim.g.loaded_perl_provider = 0

-- Point providers at asdf-managed runtimes so nvim isn't misled by system
-- binaries (e.g. /usr/bin/node v22, /opt/nflx/python3) that lack the neovim package.
vim.g.python3_host_prog = vim.fn.expand("~/.asdf/shims/python3")
vim.g.ruby_host_prog = vim.fn.expand("~/.asdf/shims/ruby")

-- Ensure tools installed via asdf and cargo are visible to Mason and other
-- external-process launchers, regardless of how nvim was started.
local extra_paths = {
  vim.fn.expand("~/.asdf/bin"),
  vim.fn.expand("~/.asdf/shims"),
  vim.fn.expand("~/.cargo/bin"),
  vim.fn.expand("~/.local/bin"),
}
for _, p in ipairs(extra_paths) do
  if vim.fn.isdirectory(p) == 1 and not vim.env.PATH:find(p, 1, true) then
    vim.env.PATH = p .. ":" .. vim.env.PATH
  end
end
