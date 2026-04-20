function! ReloadConfig()
  for s:f in split(glob('~/.vim/plugin-config/*.vim'), '\n')
    execute 'source ' . s:f
  endfor
  source ~/.vim/functions.vim
  source ~/.vim/mappings.vim
  source ~/.vim/autocmds.vim
endfunction
