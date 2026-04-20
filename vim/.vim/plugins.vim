call plug#begin('~/.vim/plugged')
" Shared (vim + nvim)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
Plug 'lambdalisue/fern.vim'
Plug 'LumaKernel/fern-mapping-fzf.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'mbbill/undotree'
Plug 'airblade/vim-rooter'
Plug 'tpope/vim-commentary'

" Nvim-only (lua plugins — configured in nvim/lua/setup.lua)
if has('nvim')
  Plug 'nvim-lua/plenary.nvim'
  Plug 'folke/which-key.nvim'
  Plug 'ThePrimeagen/vim-be-good', { 'on': 'VimBeGood' }
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'ibhagwan/fzf-lua'
  Plug 'obsidian-nvim/obsidian.nvim'
  Plug 'sindrets/diffview.nvim'
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
endif
call plug#end()
