local LSP = require'lux.lsp'
local Class = require'lux.common.class'

local ServerCapabilities = Class()

function ServerCapabilities.init(this, capabilities)
  this.capabilities = capabilities
  this.registrations = {}
end

function ServerCapabilities.register(self, id, method, register_options)
  self.registrations[id] = {
    method = method;
    register_options = register_options;
  }
end

function ServerCapabilities.unregister(self, id, _)
  self.registrations[id] = nil
end

function ServerCapabilities.is_text_document_sync_incremental(self)
  if not self.capabilities.textDocumentSync then
    return false
  end
  if self.capabilities.textDocumentSync == LSP.TextDocumentSyncKind.Incremental then
    return true
  end
  if self.capabilities.textDocumentSync.change == LSP.TextDocumentSyncKind.Incremental then
    return true
  end
  return false
end

return ServerCapabilities

