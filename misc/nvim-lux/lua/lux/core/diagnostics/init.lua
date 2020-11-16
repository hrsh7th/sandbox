local Class = require'lux.common.class'
local Emitter = require'lux.common.emitter'

local Diagnostics = Class(Emitter)

function Diagnostics.init(this)
  Diagnostics.super.init(this)
  this.diagnostics = {}
end

--- publish
--- @param params table { source = string; uri = string; diagnostics = table }
function Diagnostics.publish(self, params)
  self.diagnostics[params.uri] = self.diagnostics[params.uri] or {}
  self.diagnostics[params.uri][params.source] = {}
  for _, diagnostic in pairs(params.diagnostics) do
    table.insert(self.diagnostics[params.uri][params.source], diagnostic)
  end
  self:emit('publish')
end

function Diagnostics.find(self, text_document)
  local uri = text_document:uri()
  local diagnostics = {}
  for _, source in pairs(self.diagnostics[uri] or {}) do
    for _, diagnostic in ipairs(source) do
      table.insert(diagnostics, diagnostic)
    end
  end
  return diagnostics
end

return Diagnostics

