local Class = require'lux.common.class'

local Context = Class()

function Context.init(this)
  local bufnr = tonumber(vim.fn.expand('<abuf>'), 10)
  bufnr = not bufnr and tonumber(vim.fn.bufnr('%'), 10) or bufnr
  this.bufnr = bufnr
  this.bufname = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':p')
  this.changedtick = vim.fn.getbufvar(bufnr, 'changedtick', -1)
  this.filetype = vim.fn.getbufvar(bufnr, '&filetype', '')
  this.winid = vim.fn.win_getid()
  this.line = vim.fn.getline('.')
  this.lnum = vim.fn.line('.')
  this.col = vim.fn.col('.')
  this.time_ms = vim.loop.now()
end

return Context

