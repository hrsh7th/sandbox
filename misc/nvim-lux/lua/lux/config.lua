local Config = {}

function Config:new()
  local this = setmetatable({}, { __index = self })
  this.config = {}
  return this
end

--- get
--- @param key string
--- @return any
function Config:get(key, ...)
  if self.config[key] ~= nil then
    return self.config[key]
  end
  return (select(1, ...))
end

--- set
--- @param key string
--- @param value any
function Config:set(key, value)
  self.config[key] = value
end

return Config:new()

