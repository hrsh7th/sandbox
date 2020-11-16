local Class = require'lux.common.class'
local Emitter = require'lux.common.emitter'
local Autocmd = require'lux.vim.autocmd'
local TextDocument = require'lux.core.text_document'

local Workspace = Class(Emitter)

function Workspace.init(this)
  Workspace.super.init(this)

  this.config = {
    Lua = {
      diagnostics = {
        enable = true;
      };
    };
  }
  this.folders = {}
  this.text_documents = {}

  -- on_text_document_did_open
  Autocmd:on('BufEnter', function(...) this:on_text_document_did_open(...) end)
  Autocmd:on('BufRead', function(...) this:on_text_document_did_open(...) end)
  Autocmd:on('FileType', function(...) this:on_text_document_did_open(...) end)

  -- on_text_document_did_close
  Autocmd:on('BufUnload', function(...) this:on_text_document_did_close(...) end)
  Autocmd:on('BufDelete', function(...) this:on_text_document_did_close(...) end)
  Autocmd:on('BufWipeout', function(...) this:on_text_document_did_close(...) end)
end

--- get_config
function Workspace:get_config()
  return self.config
end

--- get_folders
function Workspace:get_folders()
  return self.folders
end

--- add_folder
function Workspace:add_folder(folder)
  for _, folder_ in pairs(self.folders) do
    if folder_.uri == folder.uri then
      return
    end
  end
  table.insert(self.folders, folder)
  self:emit('did_change_folders', {
    added = { folder };
    removed = {};
  })
end

--- remove_folder
function Workspace:remove_folder(folder)
  for i, folder_ in pairs(self.folders) do
    if folder_.uri == folder.uri then
      table.remove(self.folders, i)
      self:emit('did_change_folders', {
        added = {};
        removed = { folder };
      })
      break
    end
  end
end

function Workspace:get_text_documents()
  return self.text_documents
end

--- get_text_document
function Workspace:get_text_document(bufname)
  return self.text_documents[bufname]
end

--- on_text_document_did_open
function Workspace:on_text_document_did_open(context)
  if self.text_documents[context.bufname] then
    return
  end
  self.text_documents[context.bufname] = TextDocument.new(context)
  vim.api.nvim_buf_attach(context.bufnr, true, { on_bytes = function(...) self:on_text_document_did_change(context, ...) end })
  self:emit('text_document_did_open', self.text_documents[context.bufname])
end

--- on_text_document_did_change
function Workspace:on_text_document_did_change(context, ...)
  if not self.text_documents[context.bufname] or not vim.api.nvim_buf_is_loaded(context.bufnr) then
    return true
  end

  local diff = self.text_documents[context.bufname]:sync(...)
  self:emit('text_document_did_change', self.text_documents[context.bufname], diff)
end

--- on_text_document_did_close
function Workspace:on_text_document_did_close(context)
  if not self.text_documents[context.bufname] then
    return
  end
  self:emit('text_document_did_close', self.text_documents[context.bufname])
  self.text_documents[context.bufname] = nil
end

return Workspace

