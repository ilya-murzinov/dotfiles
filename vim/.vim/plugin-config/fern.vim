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

nnoremap <leader>pv :Fern . -drawer -width=30 -reveal=%<CR>
nnoremap <leader>pe :Fern . -reveal=%<CR>
nnoremap <leader>ps :Fern . -reveal=%<CR>
nnoremap <leader>ph :Fern ~ -reveal=%<CR>
