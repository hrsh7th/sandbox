if exists('g:loaded_lux')
  finish
endif

for s:h in [{
\   'kind': 'Error',
\   'guifg': 'Red',
\ }, {
\   'kind': 'Warning',
\   'guifg': 'Orange',
\ }, {
\   'kind': 'Information',
\   'guifg': 'LightYellow',
\ }, {
\   'kind': 'Hint',
\   'guifg': 'LightGray',
\ }]
  execute printf('highlight! default LuxDiagnostic%s gui=undercurl cterm=undercurl guisp=%s', s:h.kind, s:h.guifg)
endfor

" lua require'lux'.init()

