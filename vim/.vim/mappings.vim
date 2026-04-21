" Splits
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>s :split<CR>

" Window navigation
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" Page scroll
nnoremap <PageDown> <C-d>
nnoremap <PageUp> <C-u>

" Registers & edit
nnoremap x "_x
nnoremap <leader>a "a
nnoremap <leader>s "s
nnoremap <leader>d "d
nnoremap <leader>r :reg "" "a "s "d<CR>
nnoremap <S-u> <C-r>

" Search & replace visual selection
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" Tabs
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tx :tabclose<CR>
nnoremap <leader>th :tabprevious<CR>
nnoremap <leader>tl :tabnext<CR>

" Buffers & quit
nnoremap <leader>w :w<CR>
nnoremap <leader>qq :q<CR>

" Macros & misc
nnoremap q <Nop>
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

" Commentary
nmap <leader>/ gcc

" Format
nnoremap <leader>ft msHmtgggqG`tzt`s
xnoremap <leader>ft gq

" Visual mode indent
xnoremap <Tab> >gv
xnoremap <S-Tab> <gv
xnoremap d d
