local Class = require'lux.common.class'

local Highlight = Class()

function Highlight.init(this)
  this.namespaces = {}
end

function Highlight:set(bufnr, ns, range, hl_group)
  self.namespaces[ns] = self.namespaces[ns] or vim.api.nvim_create_namespace(ns)

  vim.api.nvim_buf_set_extmark(
    bufnr,
    self.namespaces[ns],
    range.start.line,
    range.start.character,
    {
      end_line = range['end'].line;
      end_col = range['end'].character;
      hl_group = hl_group;
    }
  )
end

function Highlight:del(bufnr, ns)
  self.namespaces[ns] = self.namespaces[ns] or vim.api.nvim_create_namespace(ns)

  vim.api.nvim_buf_clear_namespace(bufnr, self.namespaces[ns], 0, -1)
end

return Highlight.new()

