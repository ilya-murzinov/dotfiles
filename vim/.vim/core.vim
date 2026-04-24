" Timezone bootstrap (needed for iSH/iOS where $TZ is not set)
if empty($TZ)
  if filereadable('/etc/timezone')
    let $TZ = trim(system('cat /etc/timezone'))
  else
    let s:_tz = trim(system('readlink /etc/localtime 2>/dev/null'))
    if s:_tz =~# 'zoneinfo/'
      let $TZ = substitute(s:_tz, '.*zoneinfo/', '', '')
    endif
  endif
endif

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
set relativenumber
set numberwidth=5
set scrolloff=8
set nowrap
set colorcolumn=80
set noshowmatch
set signcolumn=yes
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
set tabstop=2
set softtabstop=2
set shiftwidth=2
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

set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

set background=dark

set laststatus=2
set statusline=\ %{StatusGitBranch()}%{StatusGitDirty()}\ \|\ %<%f\ %m%=\ %{StatusRootDir().'\ '}
