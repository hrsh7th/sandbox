local Class = require'lank.tuil.oop.class'
local FileSystem = require'lank.tuil.fs'

local Source = Class()

function Source.init(self, args)
  self.path = args.path
end

function Source.start(self, state)
  FileSystem.read_file(self.path, function(lines)
    for _, line in ipairs(lines) do
      state:add_item({ word = line })
    end
    state:set_status('done')
  end)
end

function Source.stop(_, state)
end

return Source

