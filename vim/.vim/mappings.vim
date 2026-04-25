" Commentary
nnoremap <M-/> :Commentary<CR>
xnoremap <M-/> :Commentary<CR>

" Splits
nnoremap <leader>wv :vsplit<CR>
nnoremap <leader>ws :split<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Navigation
nnoremap <leader>e :Ex<CR>
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzz
nnoremap N Nzz

" Registers & edit
nnoremap x "_x
vnoremap <leader>ya "ay
vnoremap <leader>ys "sy
vnoremap <leader>yd "dy
vnoremap <leader>yf "fy
nnoremap <leader>pa "ap
nnoremap <leader>ps "sp
nnoremap <leader>pd "dp
nnoremap <leader>pf "fp
nnoremap <leader>rs :reg "" "a "s "d<CR>

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
