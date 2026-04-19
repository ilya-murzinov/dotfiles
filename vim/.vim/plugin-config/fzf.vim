function! s:GlobalSearch() abort
  if executable('rg')
    call feedkeys(':Rg ', 'n')
  elseif executable('ag')
    call feedkeys(':Ag ', 'n')
  else
    echoerr 'Space sg needs ripgrep or ag. Install: brew install ripgrep'
  endif
endfunction

nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fr :History<CR>
nnoremap <leader>sg :call <SID>GlobalSearch()<CR>
vnoremap <leader>sg "hy:Rg <C-r>h<CR>
nnoremap <leader>sw :Rg <C-r><C-w><CR>
