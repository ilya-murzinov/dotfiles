" Reload changed files automatically while preserving undo history.
" noautoread means vim fires FileChangedShell instead of silently reloading;
" we set v:fcs_choice='reload' to auto-confirm, and save/restore the undo tree.
let s:undo_tmp = ''
function! s:SaveUndoAndReload() abort
  let s:undo_tmp = tempname()
  silent! execute 'wundo! ' . s:undo_tmp
  let v:fcs_choice = 'reload'
endfunction
function! s:RestoreUndo() abort
  if s:undo_tmp != '' && filereadable(s:undo_tmp)
    silent! execute 'rundo ' . s:undo_tmp
    call delete(s:undo_tmp)
    let s:undo_tmp = ''
  endif
endfunction
augroup preserve_undo_on_reload
  autocmd!
  autocmd FileChangedShell * call s:SaveUndoAndReload()
  autocmd FileChangedShellPost * call s:RestoreUndo()
augroup END

augroup checktime_track_file
  autocmd!
  autocmd FocusGained,BufEnter * if expand('%') != '' | checktime | endif
augroup END

augroup autosave
  autocmd!
  autocmd InsertLeave,TextChanged,FocusLost * if expand('%') != '' && &buftype == '' && !&readonly && &modifiable | silent! write | endif
augroup END
