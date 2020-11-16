local Lux = require'lux'
local Promise = require'lux.common.promise'
local URI = require'lux.core.text_document.uri'
local Folder = require'lux.core.workspace.folder'
local Server = require'lux.lsp.server'

local Class = require'lux.common.class'

local Languages = Class()

function Languages.init(this)
  this.servers = {}
end

--- register
function Languages:register(server)
  table.insert(self.servers, server)
end

--- check_activate
function Languages:check_activate(text_document)
  for _, server in pairs(self.servers) do
    if server:accept(text_document) then
      if server.status == Server.STATUS.NONE then
        self:activate(server, text_document)
      end
    end
  end
end

--- activate
function Languages:activate(server, text_document)
  local root_dir = server.get_root_dir(text_document)

  Promise.resolve():next(function()
    if root_dir then
      Lux.core.workspace:add_folder(Folder.new({
        name = root_dir;
        uri = URI.encode(root_dir);
      }))
    end
  end):next(function()
    server:on('notification:textDocument/publishDiagnostics', function(response)
      Lux.core.diagnostics:publish({
        source = 'aiueo';
        uri = response.uri;
        diagnostics = response.diagnostics;
      })
    end)
  end):next(function()
    server:on('request:client/registerCapability', function(id, request)
      for _, registration in ipairs(request.registrations) do
        server.capabilities:register(registration.id, registration.method, registration.registerOptions)
      end
      server:response(id, nil)
    end)
    server:on('request:client/unregisterCapability', function(id, request)
      for _, unregistration in ipairs(request.unregistrations) do
        server.capabilities:unregister(unregistration.id, unregistration.method)
      end
      server:response(id, nil)
    end)
  end):next(function()
    return server:start({
      root_dir = server.get_root_dir(text_document);
      folders = Lux.core.workspace:get_folders();
    })
  end):next(function()
    return server:notify('workspace/didChangeConfiuration', {
      settings = Lux.core.workspace:get_config();
    })
  end):next(function()
    Lux.core.workspace:on('text_document_did_open:before', function(text_document)
      if server:accept(text_document) then
        server:notify('textDocument/didOpen', {
          textDocument = {
            uri = text_document:uri();
            version = text_document.version;
            languageId = text_document:language_id();
            text = table.concat(text_document:get_lines(), '\n');
          };
        })
      end
    end)

    Lux.core.workspace:on('text_document_did_change:before', function(text_document, diff)
      if server:accept(text_document) then
        if server.capabilities:is_text_document_sync_incremental() then
          server:notify('textDocument/didChange', {
            textDocument = {
              uri = text_document:uri();
              version = text_document.version;
            };
            contentChanges = { diff:to_lsp() };
          })
        else
          server:notify('textDocument/didChange', {
            textDocument = {
              uri = text_document:uri();
              version = text_document.version;
            };
            contentChanges = { { text = table.concat(text_document:get_lines(), '\n') } };
          })
        end
      end
    end)

    Lux.core.workspace:on('text_document_did_close:before', function(text_document)
      if server:accept(text_document) then
        server:notify('textDocument/didClose', {
          textDocument = {
            uri = text_document:uri();
          };
        })
      end
    end)

    for _, text_document_ in pairs(Lux.core.workspace.text_documents) do
      if server:accept(text_document_) then
        server:notify('textDocument/didOpen', {
          textDocument = {
            uri = text_document_:uri();
            languageId = text_document_:language_id();
            text = table.concat(text_document_:get_lines(), '\n');
          };
        })
      end
    end
  end)
end

return Languages

