source ~/.vim/core.vim
source ~/.vim/plugins.vim

for s:f in sort(split(glob('~/.vim/plugin-config/*.vim'), '\n'))
  execute 'source ' . s:f
endfor

source ~/.vim/mappings.vim
source ~/.vim/autocmds.vim
