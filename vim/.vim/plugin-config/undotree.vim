let g:undotree_WindowLayout = 3
let g:undotree_SplitWidth = 40
let g:undotree_SetFocusWhenToggle = 1

if has('persistent_undo')
  let s:undodir = expand('~/.vim/undodir')
  if !isdirectory(s:undodir)
    call mkdir(s:undodir, 'p')
  endif
  let &undodir = s:undodir
  set undofile
endif

nnoremap <leader>u :UndotreeToggle<CR>
