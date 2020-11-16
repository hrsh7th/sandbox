local Class = require'lux.common.class'

local Core = Class()

function Core.init(this)
  this.workspace = require'lux.core.workspace'.new()
  this.diagnostics = require'lux.core.diagnostics'.new()
  this.languages = require'lux.core.languages'.new()

  this.workspace:on('text_document_did_open', function(text_document)
    this:on_text_document_did_open(text_document)
  end)
end

function Core:on_text_document_did_open(text_document)
  self.languages:check_activate(text_document)
end

return Core

