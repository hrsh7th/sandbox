local bind = require'lank.tuil.functional.bind'
local throttle = require'lank.tuil.async.throttle'
local Class = require'lank.tuil.oop.class'
local Emitter = require'lank.tuil.event.emitter'
local Window = require'lank.tuil.vim.window'
local State = require'lank.context.state'


local Context = Class(Emitter)

function Context.init(self, params)
  Context.super.init(self)

  self.id = vim.api.nvim_create_buf(false, true)

  self.win_prev = vim.api.nvim_get_current_win()
  self.source = params.source
  self.window = Window.new(params.layout)
  self.state = State.new()
  self.buffers = {
    main = self.id;
    prompt = vim.api.nvim_create_buf(false, true);
    status = vim.api.nvim_create_buf(false, true);
  }

  -- initialize main buffer
  vim.api.nvim_buf_set_keymap(self.buffers.main, 'n', 'i', ('<Cmd>lua require"lank":call(%d, "goto_query")<CR>'):format(self.id), { noremap = true })
  vim.api.nvim_buf_set_keymap(self.buffers.main, 'n', 'a', ('<Cmd>lua require"lank":call(%d, "goto_query")<CR>'):format(self.id), { noremap = true })
  vim.api.nvim_buf_set_keymap(self.buffers.main, 'n', 'p', ('<Cmd>lua require"lank":call(%d, "toggle_preview")<CR>'):format(self.id), { noremap = true })

  -- initializa prompt buffer
  vim.api.nvim_buf_set_keymap(self.buffers.prompt, 'n', '<Esc>', ('<Cmd>lua require"lank":call(%d, "goto_main")<CR>'):format(self.id), { noremap = true })
  vim.api.nvim_buf_set_keymap(self.buffers.prompt, 'i', '<CR>', ('<Esc><Cmd>lua require"lank":call(%d, "goto_main")<CR>'):format(self.id), { noremap = true })
  vim.fn.sign_unplace('LankSignPrompt', { buffer = self.buffers.prompt })
  vim.fn.sign_place(0, 'LankSignPrompt', 'LankSignPrompt', self.buffers.prompt, { lnum = 1; })

  -- events
  self.state:on('change', bind(self.on_state, self))
  self.window:on('open', vim.schedule_wrap(bind(self.on_open, self)))
  self.window:on('close', vim.schedule_wrap(bind(self.on_close, self)))
  vim.api.nvim_buf_attach(self.buffers.prompt, false, { on_lines = bind(self.on_query, self) })
end

function Context.goto_query(self)
  if self.window:shown() then
    vim.api.nvim_set_current_win(self.window:get_win_by_buf(self.buffers.prompt))
    vim.api.nvim_command('startinsert!')
  end
end

function Context.goto_main(self)
  if self.window:shown() then
    vim.api.nvim_set_current_win(self.window:get_win_by_buf(self.buffers.main))
  end
end

function Context.toggle_preview(self)
  self.state:set_preview(not self.state.preview)
end

function Context.shown(self)
  return self.window:shown()
end

function Context.open(self)
  self:render()
end

function Context.close(self)
  self.window:close()
end

function Context.render(self)
  self.window:open({
    main = self.buffers.main;
    prompt = self.buffers.prompt;
    status = self.buffers.status;
    state = self.state;
  })
end

function Context.on_state(self, type)
  local timeout = vim.tbl_contains({ 'cursor', 'preview' }, type) and 1 or 200
  throttle('on_state', timeout, function()
    if self.window:shown() then
      local main_win = self.window:get_win_by_buf(self.buffers.main)
      local main_cursor = vim.api.nvim_win_get_cursor(main_win)
      if main_cursor[1] ~= self.state.cursor then
        vim.api.nvim_win_set_cursor(main_win, { self.state.cursor, main_cursor[2] })
      end
      self:render()
    end
  end)
end

function Context.on_query(self)
  local cursor = vim.api.nvim_win_get_cursor(self.window:get_win_by_buf(self.buffers.prompt))
  local line = vim.api.nvim_buf_get_lines(self.buffers.prompt, cursor[1] - 1, cursor[1], false)[1]
  self.state:set_query(line)
end

function Context.on_open(self)
  self.source:start(self.state)
  vim.api.nvim_set_current_win(self.window:get_win_by_buf(self.buffers.main))
end

function Context.on_close(self)
  self.source:stop(self.state)
  vim.api.nvim_set_current_win(self.win_prev)
end

return Context

