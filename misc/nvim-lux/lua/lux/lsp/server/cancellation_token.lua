local Class = require'lux.common.class'

local CancellationToken = Class()

function CancellationToken.init(this)
  this.isCancled = false
end

function CancellationToken.attach(self, callback)
  self.callback = callback
end

function CancellationToken.cancel(self)
  if self.isCancled then
    return
  end
  self.callback()
  self.isCancled = true
end

return CancellationToken

