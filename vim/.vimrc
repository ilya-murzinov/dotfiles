" --- Leader & basics ---
let mapleader = " "
nmap <space> <Leader>
set timeoutlen=500

syntax on
filetype plugin indent on

" --- Display ---
set number
set relativenumber
set scrolloff=8
set nowrap
set colorcolumn=80
set termguicolors
set guicursor=
set noshowmatch
set cmdheight=2
set shortmess+=c
set updatetime=50

" --- Search ---
set nohlsearch
set incsearch
set smartcase
set ignorecase

" --- Buffers & files ---
set hidden
set noswapfile
set nobackup
set undofile
set undodir=~/.vim/undodir
if !isdirectory(expand("~/.vim/undodir"))
  call mkdir(expand("~/.vim/undodir"), "p")
endif

" --- Indent & tabs ---
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent

" --- UX ---
set noerrorbells
set backspace=indent,eol,start
if has('clipboard')
  set clipboard=unnamed
endif

" --- Performance (long lines) ---
set synmaxcol=2000

" --- Colors ---
call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'moll/vim-bbye'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install', 'for': ['markdown'] }
call plug#end()

" Netrw: open files in the window that was active before (sidebar on left)
let g:netrw_browse_split = 4
let g:netrw_banner = 0
let g:netrw_winsize = 30
let g:netrw_altv = 1
let g:netrw_hide = 0
" Don't hide parent dir (..) — only hide common junk
let g:netrw_list_hide = '^\.swp$,^\.git$,\.DS_Store$'

set background=dark
try
  colorscheme catppuccin_mocha
catch
  colorscheme desert
endtry
highlight ColorColumn ctermbg=0 guibg=#4a4a4a

" --- Wildmenu & splits ---
set wildmode=longest,list,full
set splitbelow
set splitright

" --- Mappings: movement ---
nnoremap <PageDown> <C-d>
nnoremap <PageUp> <C-u>
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" --- Mappings: registers & edit ---
nnoremap x "_x
nnoremap d "_d
nnoremap dd "_dd
vnoremap d "_d
nnoremap <leader>a "a
nnoremap <leader>s "s
nnoremap <leader>d "d
nnoremap <leader><leader>r :reg "" "a "s "d<CR>
nnoremap <S-u> <C-r>

" --- Mappings: search & replace ---
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" --- Mappings: fzf & file ---
nnoremap <leader>ff :GFiles<CR>
nnoremap <leader>fr :History<CR>

" --- Markdown preview: open in new browser window (same workspace on macOS) ---
function! MkdpOpenInNewWindow(url) abort
  call system('open -na "Google Chrome" --args --new-window ' . shellescape(a:url))
endfunction
let g:mkdp_browserfunc = 'MkdpOpenInNewWindow'

" --- Mappings: markdown preview ---
nnoremap <leader>mp :MarkdownPreview<CR>
nnoremap <leader>ms :MarkdownPreviewStop<CR>

" --- Mappings: Netrw (file browser) ---
nnoremap <leader>pv :leftabove vertical 30 split<CR>:Explore<CR>
nnoremap <leader>pe :Explore<CR>
nnoremap <leader>ps :Sexplore<CR>
nnoremap <leader>ph :Explore ~<CR>

" --- Mappings: buffers ---
nnoremap <leader>w :Bdelete<CR>
nnoremap <leader><leader>qq :call ConfirmCloseAllBuffersAndQuit()<CR>
function! ConfirmCloseAllBuffersAndQuit() abort
  if confirm('Close all buffers and exit Vim?', "&Yes\n&No", 2) == 1
    silent! execute '1,' . bufnr('$') . 'bdelete'
    quit
  endif
endfunction

" --- Mappings: macros & misc ---
nnoremap <leader>q @q
nnoremap <leader>n /,<CR>lr<CR>
nnoremap <leader>sq :%s/.*/'&',/<CR>

" --- Visual mode ---
xnoremap <Tab> >gv
xnoremap <S-Tab> <gv
