" Commentary
nnoremap <M-/> :Commentary<CR>
xnoremap <M-/> :Commentary<CR>

" Splits
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>s :split<CR>

" Window navigation
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
nnoremap <leader>e :Ex<CR>

" Navigation
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzz
nnoremap N Nzz

" Registers & edit
nnoremap x "_x
nnoremap <leader>a "a
nnoremap <leader>s "s
nnoremap <leader>d "d
nnoremap <leader>r :reg "" "a "s "d<CR>

" Search & replace visual selection
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" Tabs
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tx :tabclose<CR>
nnoremap <leader>th :tabprevious<CR>
nnoremap <leader>tl :tabnext<CR>

" Macros & misc
nnoremap <leader>q @q
nnoremap <leader>n /,<CR>lr<CR>
nnoremap <leader>sq :%s/.*/'&',/<CR>

" Tags
nnoremap <leader>ta :call AddTag()<CR>
nnoremap <leader>ts :call ShowTags()<CR>

" Date & time
nnoremap <leader>dd :call InsertDate()<CR>
nnoremap <leader>dt :call InsertDateTime()<CR>o
nnoremap <leader>do :call SetTzOffset()<CR>

" Reload config
nnoremap <leader>rc :call ReloadConfig()<CR>

" Format
nnoremap <leader>ft msHmtgggqG`tzt`s
xnoremap <leader>ft gq

" Visual mode
xnoremap <leader>p "_dP
xnoremap <Tab> >gv
xnoremap <S-Tab> <gv
xnoremap > >gv
xnoremap < <gv
xnoremap <M-j> :move '>+1<CR>gv
xnoremap <M-k> :move '<-2<CR>gv
nnoremap <M-j> :move .+1<CR>
nnoremap <M-k> :move .-2<CR>
xnoremap d d
