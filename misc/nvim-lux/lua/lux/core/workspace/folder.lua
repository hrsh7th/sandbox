local Class = require'lux.common.class'

local Folder = Class()

function Folder.init(this, args)
  this.name = args.name
  this.uri = args.uri
end

return Folder

