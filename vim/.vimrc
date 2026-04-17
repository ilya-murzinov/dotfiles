" --- Leader & basics ---
let mapleader = " "
nmap <space> <Leader>
set timeoutlen=500
set conceallevel=2
set concealcursor=n

syntax on
filetype plugin indent on

" --- Display ---
set number
set relativenumber
set scrolloff=8
set nowrap
set colorcolumn=80
set termguicolors
" set guicursor=  " Allow mode-based cursor shapes (block normal, line insert)
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
set noautoread
set noswapfile
set nobackup
set undofile
set undodir=~/.vim/undodir
if !isdirectory(expand("~/.vim/undodir"))
  call mkdir(expand("~/.vim/undodir"), "p")
endif

" Auto-cd to project root on buffer switch (vim-rooter handles this)
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_cd_cmd = 'lcd'
silent! Rooter
augroup checktime_track_file
  autocmd!
  autocmd FocusGained,BufEnter * if expand('%') != '' | checktime | endif
augroup END

" Reload changed files automatically while preserving undo history.
" noautoread means vim fires FileChangedShell instead of silently reloading;
" we set v:fcs_choice='reload' to auto-confirm, and save/restore the undo tree.
let s:undo_tmp = ''
function! s:SaveUndoAndReload() abort
  let s:undo_tmp = tempname()
  silent! execute 'wundo! ' . s:undo_tmp
  let v:fcs_choice = 'reload'
endfunction
function! s:RestoreUndo() abort
  if s:undo_tmp != '' && filereadable(s:undo_tmp)
    silent! execute 'rundo ' . s:undo_tmp
    call delete(s:undo_tmp)
    let s:undo_tmp = ''
  endif
endfunction
augroup preserve_undo_on_reload
  autocmd!
  autocmd FileChangedShell * call s:SaveUndoAndReload()
  autocmd FileChangedShellPost * call s:RestoreUndo()
augroup END

" --- Autosave ---
augroup autosave
  autocmd!
  autocmd InsertLeave,TextChanged,FocusLost * if expand('%') != '' && &buftype == '' && !&readonly && &modifiable | silent! write | endif
augroup END

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
nnoremap <leader>m :set mouse=<C-r>=&mouse == '' ? 'a' : ''<CR><CR>

" --- Performance (long lines) ---
set synmaxcol=2000

" --- Colors ---
call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'moll/vim-bbye'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
Plug 'lambdalisue/fern.vim'
Plug 'LumaKernel/fern-mapping-fzf.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'mbbill/undotree'
Plug 'airblade/vim-rooter'
call plug#end()

" --- Mappings: git (fugitive + gitgutter) ---
nnoremap <leader>gd :GitGutterPreviewHunk<CR>
nnoremap <leader>gu :GitGutterUndoHunk<CR>
nnoremap <leader>gdn :GitGutterNextHunk<CR>
nnoremap <leader>gdp :GitGutterPrevHunk<CR>
nnoremap <leader>gp :pclose<CR>
nnoremap <leader>ga :Git blame --date=short --abbrev=6<CR>
nnoremap <leader>gc :Git<CR>
augroup fugitive_maps
  autocmd!
  autocmd FileType fugitive nnoremap <buffer><silent> <leader>gp :Git push<CR>
augroup END

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
nnoremap <leader>v :vsplit<CR>

" --- Mappings: movement ---
nnoremap <PageDown> <C-d>
nnoremap <PageUp> <C-u>
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" --- Mappings: registers & edit ---
nnoremap x "_x
nnoremap <leader>a "a
nnoremap <leader>s "s
nnoremap <leader>d "d
nnoremap <leader>r :reg "" "a "s "d<CR>
nnoremap <S-u> <C-r>

" --- Mappings: search & replace ---
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" --- Mappings: fzf & file ---
nnoremap <leader>ff :GFiles<CR>
nnoremap <leader>fr :History<CR>
function! s:GlobalSearch() abort
  if executable('rg')
    call feedkeys(':Rg ', 'n')
  elseif executable('ag')
    call feedkeys(':Ag ', 'n')
  else
    echoerr 'Space sg needs ripgrep or ag. Install: brew install ripgrep'
  endif
endfunction
nnoremap <leader>sg :call <SID>GlobalSearch()<CR>
vnoremap <leader>sg "hy:Rg <C-r>h<CR>
nnoremap <leader>sw :Rg <C-r><C-w><CR>

" --- Markdown preview: open in new browser window (same workspace on macOS) ---
function! MkdpOpenInNewWindow(url) abort
  call system('open -na "Google Chrome" --args --new-window ' . shellescape(a:url))
endfunction
let g:mkdp_browserfunc = 'MkdpOpenInNewWindow'

" --- Mappings: markdown preview ---
nnoremap <leader>mp :MarkdownPreview<CR>
nnoremap <leader>ms :MarkdownPreviewStop<CR>

" --- Fern (file explorer with fzf) ---
let g:fern#default_hidden = 1
let g:fern#scheme#file#show_absolute_path_on_root_label = 1
function! s:FernRevealCurrentFile() abort
  if &filetype ==# 'fern' || expand('%') ==# '' || !filereadable(expand('%:p'))
    return
  endif
  let path = expand('%:p')
  let from_win = win_getid()
  for w in range(1, winnr('$'))
    let b = winbufnr(w)
    if getbufvar(b, '&filetype') ==# 'fern'
      call win_gotoid(win_getid(w))
      try
        execute 'FernReveal ' . fnameescape(path)
      catch
      endtry
      call win_gotoid(from_win)
      break
    endif
  endfor
endfunction
augroup fern_custom
  autocmd!
  autocmd FileType fern setlocal norelativenumber | setlocal nonumber
  " Open file in right pane (e); Space+u = go to parent dir (leave)
  autocmd FileType fern nnoremap <buffer><silent> e <Plug>(fern-action-open:right)
  autocmd FileType fern nnoremap <buffer><silent> <leader>u <Plug>(fern-action-leave)
  " vim-tmux-navigator: unbind anything Fern/plugins put on C-h/j/k/l, then use navigator
  autocmd FileType fern silent! nunmap <buffer> <C-h>
  autocmd FileType fern silent! nunmap <buffer> <C-j>
  autocmd FileType fern silent! nunmap <buffer> <C-k>
  autocmd FileType fern silent! nunmap <buffer> <C-l>
  " Keep explorer focused on the current file when opening/switching buffers
  autocmd BufEnter * call s:FernRevealCurrentFile()
augroup END

" --- Mappings: Fern (file browser) ---
nnoremap <leader>pv :Fern . -drawer -width=30 -reveal=%<CR>
nnoremap <leader>pe :Fern . -reveal=%<CR>
nnoremap <leader>ps :Fern . -reveal=%<CR>
nnoremap <leader>ph :Fern ~ -reveal=%<CR>

" --- Mappings: tabs ---
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>th :tabprevious<CR>
nnoremap <leader>tl :tabnext<CR>

" --- Mappings: buffers ---
nnoremap <leader>w :w<CR>
nnoremap <leader><leader>w :Bdelete<CR>
nnoremap <leader>qq :q<CR>
function! ConfirmCloseAllBuffersAndQuit() abort
  if confirm('Close all buffers and exit Vim?', "&Yes\n&No", 2) == 1
    silent! execute '1,' . bufnr('$') . 'bdelete'
    quit
  endif
endfunction

" --- Mappings: macros & misc ---
nnoremap q <Nop>
nnoremap <leader>q @q
nnoremap <leader>n /,<CR>lr<CR>
nnoremap <leader>sq :%s/.*/'&',/<CR>
nnoremap <leader>u :UndotreeToggle<CR>

" --- Undotree ---
let g:undotree_WindowLayout = 3
let g:undotree_SplitWidth = 40
let g:undotree_SetFocusWhenToggle = 1

" --- Visual mode ---
xnoremap <Tab> >gv
xnoremap <S-Tab> <gv
xnoremap d d
