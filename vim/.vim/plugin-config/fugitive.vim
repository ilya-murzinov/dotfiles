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
