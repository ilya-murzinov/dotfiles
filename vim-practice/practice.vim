" vim-practice/practice.vim
" Open with:  vim -S practice.vim
"       or:   :source path/to/practice.vim

if exists('g:vim_practice_loaded') | finish | endif
let g:vim_practice_loaded = 1

let s:root            = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:challenges_dir  = s:root . '/challenges'
let s:tmp             = s:root . '/.tmp'
let s:current_target  = ''
let s:current_optimal = 0
let s:current_name    = ''

" ─── internal helpers ────────────────────────────────────────────────────────

function! s:challenges() abort
  return sort(filter(glob(s:challenges_dir . '/*', 1, 1), 'isdirectory(v:val)'))
endfunction

function! s:meta(dir, key) abort
  let info = a:dir . '/info.txt'
  if !filereadable(info) | return '' | endif
  for line in readfile(info)
    if line =~# '^' . a:key . ':'
      return trim(substitute(line, '^' . a:key . ':\s*', '', ''))
    endif
  endfor
  return ''
endfunction

function! s:hl(msg, group) abort
  execute 'echohl ' . a:group | echo a:msg | echohl None
endfunction

" ─── :VimList ────────────────────────────────────────────────────────────────

function! s:list() abort
  echo ''
  call s:hl('  Vim Practice — Challenges', 'Title')
  echo '  ' . repeat('─', 58)
  let i = 1
  for dir in s:challenges()
    let desc = s:meta(dir, 'DESCRIPTION')
    let opt  = s:meta(dir, 'OPTIMAL')
    echo printf('  %2d.  %-46s %s keys', i, desc, opt)
    let i += 1
  endfor
  echo ''
endfunction

" ─── :VimChallenge {n} ───────────────────────────────────────────────────────

function! s:load(n) abort
  let all = s:challenges()
  let idx = a:n - 1
  if idx < 0 || idx >= len(all)
    call s:hl('  No challenge ' . a:n . ' — use :VimList', 'ErrorMsg')
    return
  endif

  let dir    = all[idx]
  let start  = dir . '/start.txt'
  let target = dir . '/target.txt'

  if !filereadable(start) || !filereadable(target)
    call s:hl('  Missing start.txt or target.txt in ' . dir, 'ErrorMsg')
    return
  endif

  let s:current_target  = target
  let s:current_optimal = str2nr(s:meta(dir, 'OPTIMAL'))
  let s:current_name    = fnamemodify(dir, ':t')

  " Fresh working copy
  call mkdir(s:tmp, 'p')
  let work = s:tmp . '/working.txt'
  call writefile(readfile(start), work)

  " Clear register q so previous runs don't contaminate the count
  call setreg('q', '')

  " Layout: working buffer (top) / target read-only (bottom)
  execute 'tabnew ' . fnameescape(work)
  setlocal noswapfile
  execute 'rightbelow split ' . fnameescape(target)
  setlocal readonly nomodifiable noswapfile bufhidden=hide
  setlocal statusline=\ TARGET\ (read\ only)
  wincmd p  " go back to working buffer — wincmd p is direction-agnostic

  " Build statusline as a plain string; %{s:var} doesn't work in statusline scope
  let &l:statusline = ' ' . s:current_name
        \ . '  |  optimal: ' . s:current_optimal . ' keys'
        \ . '  |  qq…q  then  :VimCheck'

  echo ''
  call s:hl('  Loaded: ' . s:current_name, 'Title')
  call s:hl('  1) qq   to start recording', 'Comment')
  call s:hl('  2) make your edits', 'Comment')
  call s:hl('  3) q    to stop recording', 'Comment')
  call s:hl('  4) :VimCheck to see results', 'Comment')
  echo ''
endfunction

" ─── :VimCheck ───────────────────────────────────────────────────────────────

function! s:check() abort
  if s:current_target ==# ''
    call s:hl('  No challenge loaded — use :VimChallenge {n}', 'WarningMsg')
    return
  endif

  " Keystroke count: each character in the register = one keystroke.
  " Special keys (Esc, Ctrl-V, etc.) are stored as single bytes, so
  " strlen() gives an exact count — no approximation.
  let keys = strlen(getreg('q'))

  " Compare live buffer content directly to target — no write needed
  let got     = getline(1, '$')
  let target  = readfile(s:current_target)
  let correct = (got ==# target)

  echo ''
  call s:hl('  ─── Results: ' . s:current_name . ' ───', 'Title')
  echo ''

  if correct
    call s:hl('  Correctness : PASS ✓', 'DiffAdd')
  else
    call s:hl('  Correctness : FAIL ✗', 'ErrorMsg')
    echo '  Expected:'
    for line in target | echo '    ' . line | endfor
    echo '  Got:'
    for line in got | echo '    ' . line | endfor
  endif

  echo ''
  echo printf('  Your keys   : %d', keys)
  echo printf('  Optimal     : %d', s:current_optimal)

  if keys == 0
    call s:hl('  ⚠ register q is empty — did you record with qq … q?', 'WarningMsg')
  elseif keys <= s:current_optimal
    call s:hl('  Rating      : OPTIMAL OR BETTER ✓', 'DiffAdd')
  elseif keys * 2 <= s:current_optimal * 3
    call s:hl('  Rating      : GOOD', 'WarningMsg')
  else
    call s:hl('  Rating      : NEEDS WORK', 'ErrorMsg')
  endif

  echo ''
  echo '  Keys typed  : ' . getreg('q')
  echo ''

  let ans = input('  Show solutions? [y/N] ')
  if ans =~? '^y'
    echo ''
    for line in readfile(fnamemodify(s:current_target, ':h') . '/info.txt')
      if line =~# '^SOLUTION\|^NOTE'
        call s:hl('  ' . line, 'Comment')
      endif
    endfor
    echo ''
  endif
endfunction

" ─── :VimReset ───────────────────────────────────────────────────────────────
" Reload the start file without changing challenge — useful for retrying.

function! s:reset() abort
  if s:current_target ==# ''
    call s:hl('  No challenge loaded', 'WarningMsg')
    return
  endif
  let dir   = fnamemodify(s:current_target, ':h')
  let start = dir . '/start.txt'
  let work  = s:tmp . '/working.txt'
  call writefile(readfile(start), work)
  call setreg('q', '')
  edit!
  call s:hl('  Reset to start state. Register q cleared.', 'Comment')
endfunction

" ─── keymaps ────────────────────────────────────────────────────────────────

nnoremap <Space>v  :VimChallenge<Space>
nnoremap <Space>vc :VimCheck<CR>
nnoremap <Space>vl :VimList<CR>
nnoremap <Space>vr :VimReset<CR>

" ─── commands ────────────────────────────────────────────────────────────────

command!          VimList      call s:list()
command! -nargs=1 VimChallenge call s:load(<args>)
command!          VimCheck     call s:check()
command!          VimReset     call s:reset()

" Show list on load
call s:list()
call s:hl('  :VimChallenge {n}   :VimList   :VimCheck   :VimReset', 'Comment')
echo ''
