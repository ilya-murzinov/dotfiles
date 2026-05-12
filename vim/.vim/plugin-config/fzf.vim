function! s:GlobalSearch() abort
  if executable('rg')
    call feedkeys(':Rg ', 'n')
  elseif executable('ag')
    call feedkeys(':Ag ', 'n')
  else
    echoerr 'Space sg needs ripgrep or ag. Install: brew install ripgrep'
  endif
endfunction

function! s:RgVisualFixed() abort
  if !executable('rg')
    echoerr 'Space sg (visual) needs ripgrep. Install: brew install ripgrep'
    return
  endif
  let query = substitute(@h, '\n\+$', '', '')
  let cmd =
    \ 'rg --column --line-number --no-heading --color=always --smart-case '
    \ . '--fixed-strings -- ' . (exists('*fzf#shellescape') ? fzf#shellescape(query) : shellescape(query))
  call fzf#vim#grep(cmd, fzf#vim#with_preview(), 0)
endfunction

nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fr :History<CR>
nnoremap <leader>sg :call <SID>GlobalSearch()<CR>
vnoremap <leader>sg "hy:call <SID>RgVisualFixed()<CR>
nnoremap <leader>sw :Rg <C-r><C-w><CR>
