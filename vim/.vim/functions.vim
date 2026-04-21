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

let s:obsidian_tags_cache = []

function! s:CollectObsidianTags()
  if !empty(s:obsidian_tags_cache)
    return s:obsidian_tags_cache
  endif
  let tags = {}
  for f in glob('**/*.md', 0, 1)
    let in_fm = 0
    let fm_done = 0
    for line in readfile(f)
      if !fm_done
        if line == '---'
          if !in_fm | let in_fm = 1 | else | let fm_done = 1 | endif
          continue
        endif
        if in_fm
          let m = matchlist(line, '^\s*-\s*\(\S.\{-}\)\s*$')
          if !empty(m) && m[1] !~ '^\[' | let tags[m[1]] = 1 | endif
          if line =~# '^tags:\s*\['
            for t in split(substitute(line, '^tags:\s*\[\(.*\)\].*', '\1', ''), ',\s*')
              let t = trim(t)
              if t != '' | let tags[t] = 1 | endif
            endfor
          endif
        endif
      endif
      let pos = 0
      while 1
        let [m, s, e] = matchstrpos(line, '#[a-zA-Z][a-zA-Z0-9_/\-]*', pos)
        if s < 0 | break | endif
        let tags[m[1:]] = 1
        let pos = e
      endwhile
    endfor
  endfor
  let s:obsidian_tags_cache = sort(keys(tags))
  return s:obsidian_tags_cache
endfunction

function! ObsidianTagComplete(ArgLead, CmdLine, CursorPos)
  return filter(copy(s:CollectObsidianTags()), {_, v -> v =~# '^' . a:ArgLead})
endfunction

function! AddObsidianTag()
  let tag = input('Tag: ', '', 'customlist,ObsidianTagComplete')
  if tag == ''
    return
  endif
  let tag = substitute(tag, '^#', '', '')

  if getline(1) != '---'
    call append(0, ['---', 'tags:', '  - ' . tag, '---'])
    return
  endif

  let end_fm = -1
  for i in range(2, line('$'))
    if getline(i) == '---'
      let end_fm = i
      break
    endif
  endfor

  if end_fm == -1
    echohl WarningMsg | echo "\nCould not find end of frontmatter" | echohl None
    return
  endif

  let tags_line = -1
  for i in range(2, end_fm - 1)
    if getline(i) =~# '^tags:'
      let tags_line = i
      break
    endif
  endfor

  if tags_line == -1
    call append(end_fm - 1, ['tags:', '  - ' . tag])
    return
  endif

  let tags_content = getline(tags_line)
  if tags_content =~# '^tags:\s*\['
    call setline(tags_line, substitute(tags_content, '\]', ', ' . tag . ']', ''))
  elseif tags_content =~# '^tags:\s*$'
    let last_tag_line = tags_line
    for i in range(tags_line + 1, end_fm - 1)
      if getline(i) =~# '^\s*-\s'
        let last_tag_line = i
      else
        break
      endif
    endfor
    call append(last_tag_line, '  - ' . tag)
  else
    let existing = substitute(tags_content, '^tags:\s*', '', '')
    call setline(tags_line, 'tags:')
    call append(tags_line, ['  - ' . existing, '  - ' . tag])
  endif
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
