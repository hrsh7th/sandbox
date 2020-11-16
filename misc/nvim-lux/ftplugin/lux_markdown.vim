augroup lux_markdown
  autocmd!
  autocmd BufWinEnter * call s:update()
augroup END

"
" update
"
function! s:update()
  if &filetype !=# 'lux_markdown'
    return
  endif

  " initialize state.
  let b:lux_floatwin_state = get(b:, 'lux_floatwin_state', {
        \   'markdown_syntax': v:false,
        \   'fenced_language_syntaxes': {},
        \   'fenced_mark_syntaxes': {},
        \ })

  " include markdown syntax.
  if !b:lux_floatwin_state.markdown_syntax
    let b:lux_floatwin_state.markdown_syntax = v:true
    call s:apply('runtime! syntax/markdown.vim')
    call s:apply('syntax include @Markdown syntax/markdown.vim')
  endif

  for [l:mark, l:language] in items(s:get_language_map(s:find_marks(bufnr('%'))))
    let l:language_group = printf('@luxMarkdownFenced_%s', s:escape(l:language))

    " include syntax for language.
    if !has_key(b:lux_floatwin_state.fenced_language_syntaxes, l:language)
      let b:lux_floatwin_state.fenced_language_syntaxes[l:language] = v:true

      try
        if l:language ==# 'vim' && has('nvim')
          call s:apply('syntax include %s syntax/vim/generated.vim', l:language_group)
        else
          for l:syntax_path in s:find_syntax_path(l:language)
            call s:apply('syntax include %s %s', l:language_group, l:syntax_path)
          endfor
        endif
      catch /.*/
        call lux#log('[ERROR]', { 'exception': v:exception, 'throwpoint': v:throwpoint })
        continue
      endtry
    endif

    " add highlight and conceal for mark.
    if !has_key(b:lux_floatwin_state.fenced_mark_syntaxes, l:mark)
      let b:lux_floatwin_state.fenced_mark_syntaxes[l:mark] = v:true

      let l:escaped_mark = s:escape(l:mark)
      let l:mark_group = printf('luxMarkdownFencedMark_%s', l:escaped_mark)
      let l:mark_start_group = printf('luxMarkdownFencedMarkStart_%s', l:escaped_mark)
      let l:mark_end_group = printf('luxMarkdownFencedMarkEnd_%s', l:escaped_mark)
      let l:start_mark = printf('^\s*```\s*%s\s*', l:mark)
      let l:end_mark = '\s*```\s*$'
      call s:apply('syntax region %s matchgroup=%s start="%s" matchgroup=%s end="%s" containedin=@Markdown contains=%s keepend concealends',
            \   l:mark_group,
            \   l:mark_start_group,
            \   l:start_mark,
            \   l:mark_end_group,
            \   l:end_mark,
            \   l:language_group
            \ )
    endif
  endfor
endfunction

"
" find_marks
"
function! s:find_marks(bufnr) abort
  let l:marks = {}

  " find from buffer contents.
  let l:text = join(getbufvar(a:bufnr, 'lux_floatwin_lines', []), "\n")
  let l:pos = 0
  while 1
    let l:match = matchlist(l:text, '```\s*\(\w\+\)', l:pos, 1)
    if empty(l:match)
      break
    endif
    let l:marks[l:match[1]] = v:true
    let l:pos = matchend(l:text, '```\s*\(\w\+\)', l:pos, 1)
  endwhile

  return keys(l:marks)
endfunction

"
" get_language_map
"
function! s:get_language_map(marks) abort
  let l:language_map = {}

  for l:mark in a:marks

    " resolve from lux#config
    for [l:language, l:marks] in items(lux#config('view.floatwin.fenced_languages'))
      if index(l:marks, l:mark) >= 0
        let l:language_map[l:mark] = l:language
        break
      endif
    endfor

    " resolve from g:markdown_fenced_languages
    for l:config in get(g:, 'markdown_fenced_languages', [])
      " Supports `let g:markdown_fenced_languages = ['sh']`
      if l:config !~# '='
        if l:config ==# l:mark
          let l:language_map[l:mark] = l:mark
          break
        endif

      " Supports `let g:markdown_fenced_languages = ['bash=sh']`
      else
        let l:config = split(l:config, '=')
        if l:config[1] ==# l:mark
          let l:language_map[l:config[1]] = l:config[0]
          break
        endif
      endif
    endfor

    " add as-is if can't resolved.
    if !has_key(l:language_map, l:mark)
      let l:language_map[l:mark] = l:mark
    endif
  endfor

  return l:language_map
endfunction

"
" find_syntax_path
"
function! s:find_syntax_path(name) abort
  let l:syntax_paths = []
  for l:rtp in split(&runtimepath, ',')
    let l:syntax_path = printf('%s/syntax/%s.vim', l:rtp, a:name)
    if filereadable(l:syntax_path)
      call add(l:syntax_paths, l:syntax_path)
    endif
  endfor
  return l:syntax_paths
endfunction

"
" escape
"
function! s:escape(group)
  let l:group = a:group
  let l:group = substitute(l:group, '\.', '_', '')
  return l:group
endfunction

"
" apply
"
function! s:apply(cmd, ...) abort
  let b:current_syntax = ''
  unlet b:current_syntax

  let g:main_syntax = ''
  unlet g:main_syntax

  execute call('printf', [a:cmd] + a:000)
endfunction

