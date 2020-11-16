local Logger = {}

Logger.logs = {}
Logger.timer = vim.loop.new_timer()

function Logger.log(...)
  table.insert(Logger.logs, { ... })
  vim.schedule(function()
    for _, l in pairs(Logger.logs) do
      print(vim.inspect(l))
    end
    Logger.logs = {}
  end)
end

return Logger

