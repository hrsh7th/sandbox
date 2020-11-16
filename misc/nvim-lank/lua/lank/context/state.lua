local Class = require'lank.tuil.oop.class'
local Emitter = require'lank.tuil.event.emitter'
local Matcher = require'lank.matcher'

local State = Class(Emitter)

function State.init(self)
  State.super.init(self)

  self.time = vim.loop.now()
  self.status = 'none'
  self.preview = false
  self.index = 1
  self.cursor = 1
  self.items = {}
  self.query = ''
  self.matches = {}
  self.matches_query = ''
end

function State.set_preview(self, preview)
  if self.preview ~= preview then
    self.preview = preview
    self:emit('change', 'preview')
  end
end

function State.set_status(self, status)
  if self.status ~= status then
    self.status = status
    self:emit('change', 'status')
  end
end

function State.set_cursor(self, cursor)
  if self.cursor ~= cursor then
    self.cursor = cursor
    self:emit('change', 'cursor')
  end
end

function State.set_index(self, index)
  if self.index ~= index then
    self.index = index
    self:emit('change', 'index')
  end
end

function State.set_query(self, query)
  if self.query ~= query then
    self.query = query
    self:set_cursor(1)
    self:emit('change', 'query')
  end
end

function State.add_item(self, item)
  table.insert(self.items, item)
  local now = vim.loop.now()
  if now - self.time > 200 then
    self.time = now
    if self.status == 'none' then
      self:set_status('progress')
    end
    self:emit('change', 'items')
  end
end

function State.get_items(self)
  if self.query ~= '' then
    if self.matches_query ~= self.query then
      self.matches_query = self.query
      self.matches = Matcher.query(self.query, self.items)
    end
    return self.matches
  end
  return self.items
end

return State

