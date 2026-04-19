" Leader & basics
let mapleader = " "
nmap <space> <Leader>
set timeoutlen=500
set conceallevel=2
set concealcursor=n

syntax on
filetype plugin indent on

" Display
set number
set numberwidth=4
set scrolloff=8
set nowrap
set colorcolumn=80
set noshowmatch
set cmdheight=2
set shortmess+=c
set updatetime=50

" Search
set nohlsearch
set incsearch
set smartcase
set ignorecase

" Buffers & files
set hidden
set noautoread
set noswapfile
set nobackup

" Indent & tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent

" UX
set noerrorbells
set backspace=indent,eol,start
if has('clipboard')
  set clipboard=unnamed
endif

" Performance
set synmaxcol=2000

" Wildmenu & splits
set wildmode=longest,list,full
set splitbelow
set splitright

set background=dark
