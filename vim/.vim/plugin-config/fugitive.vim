" On failure, offer force-with-lease.
function! s:GitPushUpstreamOrOfferForce() abort
  let root = FugitiveWorkTree()
  if empty(root)
    echohl ErrorMsg | echo 'Not in a Git repository' | echohl None
    return
  endif
  let save_cwd = getcwd()
  try
    execute 'lcd' fnameescape(root)
    let out = system('git push --set-upstream origin HEAD 2>&1')
  finally
    execute 'lcd' fnameescape(save_cwd)
  endtry
  redraw
  if v:shell_error == 0
    echom trim(out)
    return
  endif
  echohl WarningMsg
  echo out
  echohl None
  if confirm('Push failed. Force push with --force-with-lease?', "&Yes\n&No", 2) == 1
    execute 'Git push --force-with-lease'
  endif
endfunction

nnoremap <leader>gd :GitGutterPreviewHunk<CR>
nnoremap <leader>gu :GitGutterUndoHunk<CR>
nnoremap <leader>gdn :GitGutterNextHunk<CR>
nnoremap <leader>gdp :GitGutterPrevHunk<CR>
nnoremap <leader>ga :Git blame --date=short --abbrev=6<CR>
nnoremap <leader>gc :Git<CR>

nnoremap <leader>gl  :Gclog -100<CR>
nnoremap <leader>gf  :Git pull --rebase<CR>

augroup fugitive_maps
  autocmd!
  autocmd FileType fugitive nnoremap <buffer><silent> <leader>gp :call <SID>GitPushUpstreamOrOfferForce()<CR>
  autocmd FileType fugitive nnoremap <buffer><silent> <leader>sa  :Git add -A<CR>
  autocmd FileType fugitive nnoremap <buffer><silent> <leader>gb  :Git switch<space>
  autocmd FileType fugitive nnoremap <buffer><silent> <leader>gbn :Git switch -c<space>
augroup END
