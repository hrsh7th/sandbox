local Lux = require'lux'
local Server = require'lux.lsp.server'
local Stdio = require'lux.lsp.server.stdio'

return {
  attach = function()
    Lux.core.languages:register(Server.new({
      get_root_dir = function(text_document)
        return Lux.findup(text_document:path(), { '.git' })
      end;
      channel = Stdio.new({
        path = vim.fn.expand('~/Develop/Repos/lua-language-server/bin/macOS/lua-language-server');
        args = { '-E', vim.fn.expand('~/Develop/Repos/lua-language-server/main.lua') }
      });
      selectors = {
        { language = 'lua' }
      };
    }))
  end;
}
