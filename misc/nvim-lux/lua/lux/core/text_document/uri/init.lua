local URI = {}

local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

function URI.encode(path)
  if is_windows then
    path = string.gsub(path, '\\', '/')
  end
  path = string.gsub(path, '/$', '')
  path = string.gsub(path, '[^%w%.%-/_~]', function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  return 'file://' .. path
end

function URI.decode(uri)
  uri = string.gsub('^.*://', '')
  uri = string.gsub(uri, '%%(%x%x)', function(h)
    return string.char(tonumber(h, 16))
  end)
  if is_windows then
    uri = string.gsub(uri, '/', '\\')
  end
  return uri
end

return URI

