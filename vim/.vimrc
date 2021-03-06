let mapleader = " "
nmap <space> <Leader>

syntax on

set guicursor=
set noshowmatch
set relativenumber
set nohlsearch
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set termguicolors
set scrolloff=8

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=50

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey

call plug#begin('~/.vim/plugged')

Plug 'mbbill/undotree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'gruvbox-community/gruvbox'
Plug 'arcticicestudio/nord-vim'
Plug 'udalov/kotlin-vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

call plug#end()

let g:gruvbox_contrast_dark = 'soft'
colorscheme gruvbox
set background=dark

set wildmode=longest,list,full
set splitbelow splitright

nnoremap x "_x
nnoremap <leader>a "a
nnoremap <leader>s "s
nnoremap <leader>d "d
nnoremap <leader><leader>r :reg "" "a "s "d<CR>

nnoremap <leader>ff :GFiles<CR>

nnoremap <Leader>n /,<CR>lr<CR>
 
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

nmap <C-v> "*P
vmap <C-c> "*y
imap <C-v> <C-R>*

nnoremap <leader>pv :wincmd v<bar> :wincmd r<bar> :Ex<bar> :vertical resize 30<CR>
