let s:git_dirty_cache = {}

function! StatusGitBranch()
  return exists('*FugitiveHead') ? FugitiveHead() : ''
endfunction

function! StatusGitDirty()
  let root = exists('*FugitiveWorkTree') ? FugitiveWorkTree() : ''
  return root != '' ? get(s:git_dirty_cache, root, '') : ''
endfunction

function! s:UpdateGitDirty()
  let root = exists('*FugitiveWorkTree') ? FugitiveWorkTree() : ''
  if root == ''
    return
  endif
  let output = system('git -C ' . shellescape(root) . ' status --porcelain 2>/dev/null')
  let s:git_dirty_cache[root] = output != '' ? '  +' : '  ='
  redrawstatus!
endfunction

augroup git_dirty_status
  autocmd!
  autocmd BufEnter,BufWritePost,FocusGained,ShellCmdPost * call s:UpdateGitDirty()
augroup END

function! StatusRootDir()
  if exists('*FugitiveWorkTree') && FugitiveWorkTree() != ''
    return fnamemodify(FugitiveWorkTree(), ':t')
  endif
  return fnamemodify(getcwd(), ':t')
endfunction

let s:tz_offset_file = expand('~/.vim/tz_offset')

function! s:GetTzOffset()
  if filereadable(s:tz_offset_file)
    return str2nr(trim(readfile(s:tz_offset_file)[0]))
  endif
  return 0
endfunction

function! InsertDate()
  if !filereadable(s:tz_offset_file)
    echohl WarningMsg | echo 'No timezone offset set. Use <leader>dst to set one.' | echohl None
    return
  endif
  let offset = s:GetTzOffset()
  let saved_tz = $TZ
  let $TZ = 'UTC'
  let result = strftime('%Y-%m-%d', localtime() + offset * 3600)
  let $TZ = saved_tz
  execute "normal! a" . result . "\<Esc>"
endfunction

function! InsertDateTime()
  if !filereadable(s:tz_offset_file)
    echohl WarningMsg | echo 'No timezone offset set. Use <leader>dst to set one.' | echohl None
    return
  endif
  let offset = s:GetTzOffset()
  let saved_tz = $TZ
  let $TZ = 'UTC'
  let result = strftime('%Y-%m-%d %H:%M', localtime() + offset * 3600)
  let $TZ = saved_tz
  put =result
endfunction

function! SetTzOffset()
  let input = input('Current hour (0-23): ')
  if input == ''
    return
  endif
  let local_hour = str2nr(input)
  let saved_tz = $TZ
  let $TZ = 'UTC'
  let utc_hour = str2nr(strftime('%H'))
  let $TZ = saved_tz
  let offset = local_hour - utc_hour
  if offset > 12
    let offset = offset - 24
  elseif offset < -12
    let offset = offset + 24
  endif
  call writefile([string(offset)], s:tz_offset_file)
  echo "\nOffset set: UTC" . (offset >= 0 ? '+' : '') . offset
endfunction
