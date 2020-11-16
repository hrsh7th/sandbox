local Class = require'lank.tuil.oop.class'
local FileSystem = require'lank.tuil.fs'

local Source = Class()

function Source.init(self, args)
  self.path = args.path
  self.process = nil
  self.ignore_patterns = args.ignore_patterns
end

function Source.start(self, state)
  FileSystem.scanfile(self.path, self.ignore_patterns, function(entry)
    state:add_item({ word = entry.name })
  end):next(function()
    state:set_status('done')
  end)
end

function Source.stop(self, state)
  state:set_status('done')
  if self.process then
    self.process.stop()
  end
end

return Source


