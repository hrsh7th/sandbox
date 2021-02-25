let s:include = ['compe']
let s:exclude = []

for [s:name, s:path] in items({
\   'candle': expand('~/Develop/VimPlugins/vim-candle'),
\   'vsnip': expand('~/Develop/VimPlugins/vim-vsnip'),
\   'lamp': expand('~/Develop/VimPlugins/vim-lamp'),
\   'compe': expand('~/Develop/VimPlugins/nvim-compe'),
\   'lsp': expand('~/Develop/VimPlugins/vim-lsp')
\ })
  if !empty(s:include) && index(s:include, s:name) == -1
    continue
  endif
  if !empty(s:exclude) && index(s:exclude, s:name) != -1
    continue
  endif
  try
    execute printf('cd %s', s:path)
    execute printf('Vitalize --name=%s .', s:name)
  catch /.*/
    echomsg string({ 'exception': v:exception, 'throwpoint': v:throwpoint })
  endtry
endfor
