local Lux = require'lux'
local Highlight = require'lux.vim.highlight'
local Class = require'lux.common.class'

local View = Class()

function View.init(this)
  Lux.core.diagnostics:on('publish', function()
    this:on_diagnostics_publish()
  end)
end

function View:on_diagnostics_publish()
  for _, text_document in pairs(Lux.core.workspace:get_text_documents()) do
    Highlight:del(text_document.bufnr, 'diagnostics')
    for _, diagnostic in ipairs(Lux.core.diagnostics:find(text_document)) do
      if diagnostic.severity == 1 then
        Highlight:set(text_document.bufnr, 'diagnostics', diagnostic.range, 'LuxDiagnosticError')
      elseif diagnostic.severity == 2 then
        Highlight:set(text_document.bufnr, 'diagnostics', diagnostic.range, 'LuxDiagnosticWarning')
      elseif diagnostic.severity == 3 then
        Highlight:set(text_document.bufnr, 'diagnostics', diagnostic.range, 'LuxDiagnosticInformation')
      elseif diagnostic.severity == 4 then
        Highlight:set(text_document.bufnr, 'diagnostics', diagnostic.range, 'LuxDiagnosticHint')
      end
    end
  end
end

return View

