return function(...)
  local Parent = (select(1, ...))

  local Class = Parent and setmetatable({}, { __index = Parent }) or {}

  Class.super = Parent

  -- factory
  Class.new = function(...)
    local this = setmetatable({}, { __index = Class })
    Class.init(this, ...)
    return this
  end

  -- default constructor
  function Class.init(this, ...)
    if Class.super then
      this.super.init(this, ...)
    end
  end

  return Class
end
