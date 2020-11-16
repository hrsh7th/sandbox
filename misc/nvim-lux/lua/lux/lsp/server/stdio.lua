local Class = require'lux.common.class'
local Emitter = require'lux.common.emitter'
local Autocmd = require'lux.vim.autocmd'

local Stdio = Class(Emitter)

Stdio.STATUS = {
  NONE = 'NONE';
  RUNNING = 'RUNNING';
  EXITING = 'EXITING';
  EXITED = 'EXITED';
}

--- init
--- @param params table -- { path: string; args: table; }
function Stdio.init(this, params)
  Stdio.super.init(this)
  this.in_pipe = vim.loop.new_pipe(false)
  this.out_pipe = vim.loop.new_pipe(false)
  this.err_pipe = vim.loop.new_pipe(false)
  this.handle = nil
  this.params = params
  this.status = Stdio.STATUS.NONE

  Autocmd:on('VimLeavePre', function()
    this:stop()
  end)
end

function Stdio.start(self, cwd)
  if self.handle then
    return
  end

  local handle = vim.loop.spawn(self.params.path, {
    args = self.params.args;
    cwd = cwd;
    stdio = {
      self.in_pipe,
      self.out_pipe,
      self.err_pipe
    };
    detached = false;
  }, function(code, signal)
    self:stop()
    self.status = Stdio.STATUS.EXITED
    self:emit('exit', code, signal)
  end)
  self.status = Stdio.STATUS.RUNNING
  self.handle = handle
end

function Stdio.stop(self)
  if not self.handle then
    return
  end

  self.in_pipe:shutdown()
  self.out_pipe:shutdown()
  self.err_pipe:shutdown()
  self.handle:close()
  self.handle:kill(15)
  self.status = Stdio.STATUS.EXITING
  self.handle = nil
end

return Stdio

