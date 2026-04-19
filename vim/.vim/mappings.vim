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

" Date & time
let s:tz_offset_file = expand('~/.vim/tz_offset')

function! s:GetTzOffset()
  if filereadable(s:tz_offset_file)
    return str2nr(trim(readfile(s:tz_offset_file)[0]))
  endif
  return 0
endfunction

function! InsertDateTime()
  let offset = s:GetTzOffset()
  let saved_tz = $TZ
  let $TZ = 'UTC'
  let result = strftime('%Y-%m-%d %H:%M', localtime() + offset * 3600)
  let $TZ = saved_tz
  put =result
endfunction

function! SetTzOffset()
  let current = s:GetTzOffset()
  let input = input('UTC offset (e.g. +2, -5) [current: ' . (current >= 0 ? '+' : '') . current . ']: ')
  if input == ''
    return
  endif
  call writefile([string(str2nr(input))], s:tz_offset_file)
  echo "\nTimezone offset saved: UTC" . (str2nr(input) >= 0 ? '+' : '') . str2nr(input)
endfunction

nnoremap <leader>dt :call InsertDateTime()<CR>o
nnoremap <leader>dst :call SetTzOffset()<CR>

" Commentary
nmap <leader>/ gcc

" Format
nnoremap <leader>ft msHmtgggqG`tzt`s
xnoremap <leader>ft gq

" Visual mode indent
xnoremap <Tab> >gv
xnoremap <S-Tab> <gv
xnoremap d d
