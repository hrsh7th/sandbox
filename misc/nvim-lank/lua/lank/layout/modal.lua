local status = require'lank.layout.parts.status'()
local PROMPT_AREA_HEIGHT = 3

return function()
  local background = vim.api.nvim_create_buf(false, true)
  local prompt_area = vim.api.nvim_create_buf(false, true)
  local preview = vim.api.nvim_create_buf(false, true)

  return function(viewport, props)
    local max_item_count = (viewport.height * 0.6) - PROMPT_AREA_HEIGHT - 2

    -- update contents
    local items = props.state:get_items()
    local lines = {}
    for i = props.state.index, math.min(#items, props.state.index + max_item_count) do
      table.insert(lines, items[i].word)
    end
    vim.api.nvim_buf_set_lines(props.main, 0, -1, true, lines)

    if #lines == 0 then
      table.insert(lines , '')
    end

    -- update cursor sign
    vim.fn.sign_unplace('LankSignCursor', { buffer = props.main })
    vim.fn.sign_place(0, 'LankSignCursor', 'LankSignCursor', props.main , { lnum = props.state.cursor; })

    return {
      buffer = background;
      style = {
        highlight = 'CursorLine:NormalFloat,SignColumn:NormalFloat',
        width = viewport.width * 0.6;
        height = #lines + PROMPT_AREA_HEIGHT + 2;
        row = viewport.height * 0.2;
        col = viewport.width * 0.2;
      };
      children = {
        function(viewport)
          return {
            buffer = prompt_area;
            style = {
              highlight = 'NormalFloat:TabLineSel,CursorLine:TabLineSel,SignColumn:TabLineSel',
              width = viewport.width;
              height = PROMPT_AREA_HEIGHT;
              row = 0;
              col = 0;
            };
            children = {
              function(viewport)
                return {
                  buffer = props.prompt;
                  style= {
                    highlight = 'NormalFloat:TabLineSel,CursorLine:TabLineSel,SignColumn:TabLineSel',
                    width = viewport.width - 4 - 15;
                    height = 1;
                    row = 1;
                    col = 2;
                  };
                };
              end;
              function(viewport, props)
                local element = status(viewport, props)
                if element then
                  element.style.row = 1
                  element.style.col = viewport.width - 4 - 15
                  return element
                end
                return nil
              end
            };
          };
        end;
        function(viewport)
          local width = viewport.width - 4
          return {
            buffer = props.main;
            style = {
              highlight = 'CursorLine:NormalFloat,SignColumn:NormalFloat',
              width = props.state.preview and width / 2 or width;
              height = math.max(1, #lines);
              row = PROMPT_AREA_HEIGHT + 1;
              col = 2;
            };
            children = props.state.preview and {
              function(viewport)
                return {
                  buffer = preview;
                  style = {
                    highlight = 'NormalFloat:TabLineSel,CursorLine:TabLineSel,SignColumn:TabLineSel',
                    width = viewport.width - 1;
                    height = viewport.height;
                    row = 0;
                    col = viewport.width;
                  };
                };
              end
            } or {}
          };
        end
      };
    };
  end
end
