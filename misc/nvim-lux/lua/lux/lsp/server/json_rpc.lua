local Class = require'lux.common.class'
local Promise = require'lux.common.promise'
local Emitter = require'lux.common.emitter'

local JSON_RPC = Class(Emitter)

function JSON_RPC.init(this)
  JSON_RPC.super.init(this)
  this.in_pipe = nil
  this.out_pipe = nil
  this.err_pipe = nil
  this.requests = {}
  this.write_buffer = ''
  this.write_timer = nil
  this.read_buffer = ''
  this.read_timer = nil
end

function JSON_RPC.attach(self, in_pipe, out_pipe, err_pipe)
  self.in_pipe = in_pipe
  self.out_pipe = out_pipe
  self.err_pipe = err_pipe

  vim.loop.read_start(self.out_pipe, function(err, data)
    if err then
      self.read_buffer = ''
    else
      self:read(data or '')
    end
  end)
  vim.loop.read_start(self.err_pipe, function(err, data)
  end)
end

function JSON_RPC.detach(self)
  vim.loop.shutdown(self.out_pipe)
  vim.loop.shutdown(self.err_pipe)
end

function JSON_RPC.request(self, id, method, params)
  self:write(self:create_message({
    id = id;
    method = method;
    params = params;
  }))

  return Promise.new(function(resolve, reject)
    self.requests[id] = {
      resolve = resolve;
      reject = reject;
    }
  end)
end

function JSON_RPC.response(self, id, result)
  self:write(self:create_message({
    id = id;
    result = result;
  }))
end

function JSON_RPC.notify(self, method, params)
  self:write(self:create_message({
    method = method;
    params = params;
  }))
end

function JSON_RPC.write(self, message)
  self.write_buffer = self.write_buffer .. message
  if self.write_timer ~= nil then
    return
  end
  self.write_timer = vim.loop.new_timer()
  self.write_timer:start(10, 0, function()
    self.write_timer = nil
    while #self.write_buffer ~= 0 do
      vim.loop.write(self.in_pipe, string.sub(self.write_buffer, 1, 1024))
      self.write_buffer = string.sub(self.write_buffer, 1025)
    end
  end)
end

function JSON_RPC.read(self, data)
  self.read_buffer = self.read_buffer .. data
  if self.read_timer ~= nil then
    return
  end
  self.read_timer = vim.loop.new_timer()
  self.read_timer:start(10, 0, vim.schedule_wrap(function()
    self.read_timer = nil

    while 1 do
      local _, header_offset = string.find(self.read_buffer, '\r\n\r\n')
      if not header_offset then
        return
      end
      local _, _, content_length = string.find(self.read_buffer, 'Content%-Length: (%d+)')
      if not content_length then
        return
      end
      local message_offset = header_offset + tonumber(content_length, 10)
      if #self.read_buffer < message_offset then
        return
      end

      pcall(function()
        local content = string.sub(self.read_buffer, header_offset, message_offset)
        local message = vim.fn.json_decode(content)
        self.read_buffer = string.sub(self.read_buffer, message_offset + 1)
        self:on_message(message);
      end)
    end
  end))
end

function JSON_RPC.on_message(self, message)
  -- request
  if message.id and message.method then
    self:emit('request', message)
  -- response
  elseif message.id and not message.method then
    local request = self.requests[message.id]
    if request then
      if message.error then
        request.reject(message.error)
      else
        request.resolve(message.result)
      end
    end
    self.requests[message.id] = nil
  -- notify
  elseif not message.id and message.method then
    self:emit('notification', message)
  end
end

function JSON_RPC.create_message(_, content)
  content.jsonrpc = '2.0'
  local message = vim.fn.json_encode(content)
  return string.format('Content-Length: %d\r\n\r\n', #message) .. message
end

return JSON_RPC

