let s:no_conflict_marker = '_____$$$$$_____$$$$$_____traverser_____$$$$$_____$$$$$_____'
let s:all = '\_.*'
let s:any = '\_.\{-}'
let s:tagname = '/\?\w\{1,}'
let s:blank = '\_[:blank:]*'

let s:Traverser = {
      \ 'text': '',
      \ 'text_current': '',
      \ 'text_traversed': '',
      \ 'regexes': []
      \ }

function! s:Traverser.new(text, regexes, line_offset)
  return extend(deepcopy(s:Traverser), {
        \ 'text': a:text,
        \ 'text_current': a:text,
        \ 'text_traversed': '',
        \ 'line_offset': a:line_offset - 1,
        \ 'regexes': a:regexes
        \ })
endfunction

function! s:Traverser.next()
  let s:match = substitute(self.text_current, self.regex(), '\=submatch(1) . s:no_conflict_marker . submatch(2) . s:no_conflict_marker . submatch(3) . s:no_conflict_marker . submatch(4)', 'g')
  let s:submatches = split(s:match, s:no_conflict_marker)
  if len(s:submatches) != 4
    return
  endif

  let [s:text_before, s:text_match_before, s:text_match_target, s:text_match_after] = s:submatches
  let self.text_traversed = self.text_traversed . s:text_before
  let s:current_traversed = split(self.text_traversed, "\n", v:true)
  let self.text_traversed = self.text_traversed . s:text_match_before . s:text_match_target . s:text_match_after
  let self.text_current = strpart(self.text_current, strlen(s:match) - strlen(s:no_conflict_marker) * 3)

  return {
        \ 'line': self.line_offset + len(s:current_traversed),
        \ 'col': strlen(s:current_traversed[-1]) + 1,
        \ 'match': s:text_match_before . s:text_match_target . s:text_match_after,
        \ 'match_target': s:text_match_target
        \ }
endfunction

function! s:Traverser.regex()
  let s:regexes = []
  for s:d in self.regexes
    call add(s:regexes, '\(' . join(s:d['before'], '') . '\)\(' . join(s:d['target'], '') . '\)\(' . join(s:d['after'], '') . '\)')
  endfor
  return '^\(' . s:any . '\)\%(' . join(s:regexes, '\|') . '\)\(' . s:all . '\)$'
endfunction

function! s:matchaddpos(group, matches)
  if exists('b:h')
    call matchdelete(b:h)
  endif

  let s:matchposes = []
  for s:match in a:matches
    let s:lines = split(s:match['match'], "\n")
    let s:i = 0
    for s:line in s:lines
      let [s:_, s:__, s:col_offset] = matchstrpos(s:line, '[^[:blank:]]')
      call add(s:matchposes, [s:match['line'] + s:i, (s:i == 0 ? s:match['col'] : s:col_offset), strlen(s:line)])
      let s:i = s:i + 1
    endfor
  endfor
  let b:h = matchaddpos(a:group, s:matchposes, 1000)
endfunction

let s:text = join([
      \ 'aaaa',
      \ '  <div',
      \ '    onClick={onClick}',
      \ '    className="hoge"',
      \ '  >',
      \ '    あああ<span className="hoge">',
      \ '      {text}',
      \ '    </span>',
      \ '  </div>',
      \ ], "\n")

let s:regexes = [{
      \   'before': ['<', s:blank],
      \   'target': [s:tagname],
      \   'after' : [s:any, '>']
      \ }, {
      \   'before': ['<', s:blank],
      \   'target': [s:tagname],
      \   'after' : [s:blank, '>']
      \ }]

"
" use-case.
"

let s:traverser = s:Traverser.new(join(getline(71, 84), "\n"), s:regexes, 71)

let s:matches = []
let s:next = s:traverser.next()
while type(s:next) == v:t_dict
  call add(s:matches, s:next)
  let s:next = s:traverser.next()
endwhile
"
" highlights.
"
call s:matchaddpos('Error', s:matches)

