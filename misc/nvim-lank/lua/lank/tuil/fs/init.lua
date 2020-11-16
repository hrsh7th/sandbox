local Class = require'lank.tuil.oop.class'
local Promise = require'lank.tuil.async.promise'

local FDState = {}

FDState.max = 5
FDState.queue = {}
FDState.count = 0

FDState.add = function(callback)
  if FDState.count > FDState.max then
    return table.insert(FDState.queue, callback)
  end
  FDState.count = FDState.count + 1
  callback()
end

FDState.del = function()
  FDState.count = FDState.count - 1

  if #FDState.queue > 0 and FDState.count <= FDState.max then
    FDState.count = FDState.count + 1
    table.remove(FDState.queue, 1)()
  end
end

local FileSystem = Class()

function FileSystem.read_file(path, callback)
  vim.loop.fs_open(path, "r", 438, function(err, fd)
    assert(not err, err)
    vim.loop.fs_fstat(fd, function(err, stat)
      assert(not err, err)
      vim.loop.fs_read(fd, stat.size, 0, function(err, data)
        assert(not err, err)
        vim.loop.fs_close(fd, function(err)
          assert(not err, err)
          return callback(vim.split(data, '\n', true))
        end)
      end)
    end)
  end)
end

function FileSystem.scanfile(path, ignore_patterns, callback)
  for _, pattern in ipairs(ignore_patterns) do
    if string.find(path, pattern, 1, true) then
      return Promise.resolve()
    end
  end

  return FileSystem.readdir(path):next(function(entries)
    local promises = { Promise.resolve() }
    for _, entry in ipairs(entries or {}) do
      local entry_path = path .. '/' .. entry.name
      if entry.type == 'file' then
        local ignore = false
        for _, pattern in ipairs(ignore_patterns) do
          if string.find(entry_path, pattern, 1, true) then
            ignore = true
            break
          end
        end
        if not ignore then
          callback({ name = entry_path; type = entry.type; })
        end
      elseif entry.type == 'directory' then
        table.insert(promises, FileSystem.scanfile(entry_path, ignore_patterns, callback))
      end
    end
    return Promise.all(promises)
  end)
end

function FileSystem.readdir(path)
  return Promise.new(function(resolve)
    FDState.add(function()
      vim.loop.fs_scandir(path, function(err, dir)
        if err or not dir then
          FDState.del()
          return resolve({})
        end

        local entries = {}
        while true do
          local name, type = vim.loop.fs_scandir_next(dir)
          if name then
            table.insert(entries, { name = name; type = type; })
          else
            break
          end
        end
        FDState.del()
        return resolve(entries)
      end)
    end)
  end)
end

return FileSystem
