local Class = require'lux.common.class'

local Completion = Class()

function Completion.init(this)
  this.sources = {}
end

function Completion:register(source)
  table.insert(self.sources, source)
  return function()
    for i, source_ in ipairs(self.sources) do
      if source_ == source then
        return table.remove(self.sources, i)
      end
    end
  end
end

return Completion

