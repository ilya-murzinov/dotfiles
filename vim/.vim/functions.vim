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
  let current = s:GetTzOffset()
  let input = input('UTC offset (e.g. +2, -5) [current: ' . (current >= 0 ? '+' : '') . current . ']: ')
  if input == ''
    return
  endif
  call writefile([string(str2nr(input))], s:tz_offset_file)
  echo "\nTimezone offset saved: UTC" . (str2nr(input) >= 0 ? '+' : '') . str2nr(input)
endfunction
