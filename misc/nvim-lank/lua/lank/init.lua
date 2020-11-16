local Class = require'lank.tuil.oop.class'
local Autocmd = require'lank.tuil.vim.autocmd'
local Context = require'lank.context'

vim.fn.sign_define('LankSignPrompt', {
  text = '$';
})

vim.fn.sign_define('LankSignCursor', {
  text = '>';
})

local Lank = Class()

function Lank.init(self)
  self.contexts = {}

  Autocmd:on('CursorMoved', function()
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    for _, context in ipairs(self.contexts) do
      if buf == context.buffers.main then
        if context:shown() then
          if context.window:get_win_by_buf(buf) == win then
            local cursor = vim.api.nvim_win_get_cursor(win)
            context.state:set_cursor(cursor[1])
            return
          end
        end
      end
    end
  end)
end

function Lank.call(self, id, method)
  local context = nil
  for _, context_ in ipairs(self.contexts) do
    if context_.id == id then
      context = context_
      break
    end
  end
  if context then
    context[method](context)
  end
end

function Lank.run(self, params)
  local context = Context.new(params)
  context:open()
  table.insert(self.contexts, context)
end

return Lank.new();

