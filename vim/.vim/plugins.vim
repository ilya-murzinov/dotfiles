call plug#begin('~/.vim/plugged')
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
call plug#end()
