function! MkdpOpenInNewWindow(url) abort
  call system('open -na "Google Chrome" --args --new-window ' . shellescape(a:url))
endfunction
let g:mkdp_browserfunc = 'MkdpOpenInNewWindow'

nnoremap <leader>mp :MarkdownPreview<CR>
nnoremap <leader>ms :MarkdownPreviewStop<CR>
