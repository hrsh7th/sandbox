local Class = require'lux.common.class'
local URI = require'lux.core.text_document.uri'
local Emitter = require'lux.common.emitter'
local JSON_RPC = require'lux.lsp.server.json_rpc'
local ClientCapabilities = require'lux.lsp.client_capabilities'
local ServerCapabilities = require'lux.lsp.server_capabilities'

local Server = Class(Emitter)

Server.STATUS = {
  NONE = 'NONE';
  INITIALIZING = 'INITIALIZING';
  RUNNING = 'RUNNING';
  EXITING = 'EXITING';
  EXITED = 'EXITED';
};

--- init
--- @param params table
-- params.get_root_dir func<string> string
-- params.initialization_options table
-- params.channel lux.channel.Stdio
-- params.selectors table
function Server.init(this, params)
  Server.super.init(this)
  this.id = 0
  this.status = Server.STATUS.NONE
  this.get_root_dir = params.get_root_dir
  this.initialization_options = params.initialization_options
  this.channel = params.channel
  this.selectors = params.selectors

  this.rpc = JSON_RPC.new()
  this.rpc:on('request', function(message)
    this:emit('request', message)
    this:emit('request:' .. message.method, message.id, message.params)
  end)

  this.rpc:on('notification', function(message)
    this:emit('notification', message)
    this:emit('notification:' .. message.method, message.params)
  end)
end

function Server.accept(self, text_document)
  return text_document:match(self.selectors)
end

--- start
--- @param params table
-- params.root_dir
-- params.folders
-- params.trace
function Server.start(self, params)
  self.channel:stop()
  self.status = Server.STATUS.INITIALIZING
  self.channel:start(params.root_dir)

  self.rpc:attach(
    self.channel.in_pipe,
    self.channel.out_pipe,
    self.channel.err_pipe
  )

  return self:request('initialize', {
    processId = vim.fn.getpid();
    rootPath = params.root_dir;
    rootUri = URI.encode(params.root_dir);
    initializationOptions = self.initialization_options;
    capabilities = ClientCapabilities;
    trace = params.trace;
    workspaceFolders = params.folders;
  }):next(function(response)
    self:notify('initialized', {})
    self.status = Server.STATUS.RUNNING
    self.capabilities = ServerCapabilities.new(response.capabilities)
  end)
end

function Server.stop(self)
  self.channel:stop()
  self.status = Server.STATUS.EXITED
  self.rpc:detach()
end

function Server.request(self, method, params, ...)
  local option = (select(1, ...)) or {}

  local id = self:create_id()

  if option.cancellation_token then
    option.cancellation_token:attach(function()
      self:cancel(id)
    end)
  end

  return self.rpc:request(id, method, params)
end

function Server.notify(self, method, params)
  self.rpc:notify(method, params)
end

function Server.response(self, id, result)
  self.rpc:response(id, result)
end

function Server.cancel(self, id)
  self:notify('$/cancelRequest', { id = id; })
  self.rpc.requests[id] = nil
end

function Server.create_id(self)
  local id = self.id
  self.id = self.id + 1
  return id
end

return Server

