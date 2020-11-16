require'lux.common.promise'.async = function(callback)
  vim.loop.new_timer():start(0, 0, callback)
end

local Lux = {}

function Lux.init()
  Lux.core = require'lux.core'.new()
  Lux.view = require'lux.view'.new()

  local root_dir = string.gsub(package.searchpath('lux', package.path), 'init.lua$', '')
  local dirs = vim.loop.fs_scandir(root_dir .. '/extension')
  while true do
    local dir = vim.loop.fs_scandir_next(dirs)
    if not dir then
      break
    end
    local status, reason = pcall(function()
      require(('lux.extension.%s'):format(dir)).attach()
    end)
    if not status then
      vim.call('lux#log', reason)
    end
  end

  vim.fn.execute('augroup Lux')
  vim.fn.execute('  autocmd!')
  for _, name in pairs({
    'InsertEnter',
    'InsertLeave',
    'InsertCharPre',
    'CursorMoved',
    'CursorMovedI',
    'TextChanged',
    'TextChangedI',
    'TextChangedP',
    'CompleteChanged',
    'CompleteDone',
    'BufEnter',
    'WinEnter',
    'BufWinEnter',
    'BufRead',
    'FileType',
    'BufWritePre',
    'BufWritePost',
    'BufDelete',
    'BufUnload',
    'BufWipeout',
    'VimLeave',
    'VimLeavePre',
  }) do
    vim.fn.execute(('autocmd %s * lua require"lux.vim.autocmd":emit("%s", require("lux.context").new())'):format(name, name))
  end
  vim.fn.execute('augroup END')
end

function Lux.findup(path, markers)
  local p = string.gsub(path, '/[^/]+$', '')
  while p ~= '' and p ~= '/' do
    for _, marker in ipairs(markers) do
      if vim.loop.fs_stat(p .. '/' .. marker) then
        return p
      end
    end
    p = string.gsub(p, '/[^/]+$', '')
  end
  return p
end

return Lux

