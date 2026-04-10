-- Neovim configuration - Sources ~/.vimrc for shared config, lazy.nvim for nvim-only plugins

-- Set leader before anything else
vim.g.mapleader = " "

-- Add vim paths so nvim can find plug.vim and vim-plug plugins
vim.opt.runtimepath:prepend(vim.fn.expand("~/.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/.vim/after"))

-- Source your vimrc - vim-plug handles all shared plugins
vim.cmd("source ~/.vimrc")

-- Bootstrap lazy.nvim for nvim-specific plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load nvim-only plugins via lazy.nvim
require("plugins")
