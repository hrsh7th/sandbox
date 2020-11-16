local Buffer = {}

function Buffer.open(filepath, ...)
  local bufnr = vim.fn.bufnr(filepath)
  if bufnr == 0 then
    vim.fn.execute(('edit %s'):format(filepath))
  elseif bufnr ~= vim.fn.bufnr() then
    vim.fn.execute(('%sbuffer'):format(bufnr))
  end

  local range_or_position = (select(1, ...))
  if range_or_position.start then
    local range = range_or_position
  else
    local position = range_or_position
  end
end

return Buffer

