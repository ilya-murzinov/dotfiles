-- Neovim configuration - Sources ~/.vimrc for shared config, lazy.nvim for nvim-only plugins

-- Set leader before anything else
vim.g.mapleader = " "

-- Add vim paths so nvim can find plug.vim and vim-plug plugins
vim.opt.runtimepath:prepend(vim.fn.expand("~/.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/.vim/after"))

-- Source your vimrc - vim-plug handles all shared plugins
vim.cmd("source ~/.vimrc")

-- Override undodir to avoid E824 conflicts with Vim (different undo file formats)
local undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undodir = undodir
vim.opt.undofile = true
if not vim.loop.fs_stat(undodir) then
  vim.fn.mkdir(undodir, "p")
end

-- Bootstrap lazy.nvim for blink.cmp (needs version-pinned pre-built Rust binaries)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Don't let lazy.nvim reset runtimepath — it wipes vim-plug plugin dirs
require("lazy").setup(require("plugins"), {
  performance = { rtp = { reset = false } },
})

-- Configure vim-plug-installed lua plugins
require("setup")
