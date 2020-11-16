local Class = require'lux.common.class'
local URI = require'lux.core.text_document.uri'

local TextDocument = Class()

function TextDocument.init(this, context)
  this.version = 0
  this.changedtick = context.changedtick
  this.bufnr = context.bufnr
  this.bufname = context.bufname
  this.filetype = context.filetype
  this.lines = this:get_lines()
end

--- match
function TextDocument:match(selectors)
  for _, selector in ipairs(selectors) do
    local match = true
    if selector.language then
      match = match and (self:language_id() == selector.language)
    end
    if selector.pattern then
      local m =  vim.regex(vim.fn.glob2regpat(selector.pattern)):match_str(self:path())
      if m then
        match = match and true
      end
    end
    if match then
      return true
    end
  end
  return false
end

--- language_id
--- @return string
function TextDocument:language_id()
  return self.filetype
end

--- path
--- @return string
function TextDocument:path()
  return self.bufname
end

--- uri
--- @return string
function TextDocument:uri()
  return URI.encode(self.bufname)
end

---
--- @param _ any 1: 'bytes', 2: bufnr
--- @param changedtick number
--- @param start_row number
--- @param start_col number
--- @param start_byte number
--- @param old_row number
--- @param old_col number
--- @param old_byte number
--- @param new_row number
--- @param new_col number
--- @param new_byte number
function TextDocument:sync(_, _, changedtick, start_row, start_col, _, old_row, old_col, _, new_row, new_col, _)
  self.version = self.version + 1
  self.changedtick = changedtick

  old_col = old_col + ((old_row == 0) and start_col or 0)
  new_col = new_col + ((new_row == 0) and start_col or 0)
  old_row = old_row + start_row
  new_row = new_row + start_row

  local old_text = self:text(start_row, start_col, old_row, old_col)
  local old_start_line = self.lines[start_row + 1] or ''
  local old_end_line = self.lines[old_row + 1] or ''
  self.lines = self:get_lines()
  local new_text = self:text(start_row, start_col, new_row, new_col)

  return {
    range = {
      start = {
        line = start_row;
        character = vim.str_utfindex(old_start_line .. ' ', start_col);
      };
      ['end'] = {
        line = old_row;
        character = vim.str_utfindex(old_end_line .. ' ', old_col);
      };
    };
    newText = new_text;
    rangeLength = vim.str_utfindex(old_text .. ' ', #old_text);
  };
end

function TextDocument:get_lines()
  local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  table.insert(lines, '')
  return lines
end

function TextDocument:text(start_row, start_col, end_row, end_col)
  local text = ''
  for i = start_row, end_row do
    local line = self.lines[i + 1] or ''
    if start_row == end_row then
      text = text .. string.sub(line .. ' ', start_col + 1, end_col) .. (#line < end_col and '\n' or '')
    elseif i == start_row then
      text = text .. string.sub(line .. ' ', start_col + 1) .. '\n'
    elseif i == end_row then
      text = text .. string.sub(line .. ' ', 1, end_col) .. (#line < end_col and '\n' or '')
    else
      text = text .. line .. '\n'
    end
  end
  return text
end

return TextDocument

