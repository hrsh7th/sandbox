return function()
  return function(viewport, props)
    -- update contents
    local items = props.state:get_items()
    local lines = {}
    for i = props.state.index, math.min(#items, props.state.index + viewport.height) do
      table.insert(lines, items[i].word)
    end
    vim.api.nvim_buf_set_lines(props.main, 0, -1, false, lines)

    -- update cursor sign
    vim.fn.sign_unplace('LankSignCursor', { buffer = props.main })
    vim.fn.sign_place(0, 'LankSignCursor', 'LankSignCursor', props.main , { lnum = props.state.cursor; })

    -- canvas
    return {
      buffer = props.main;
      style = {
        highlight = 'Normal:NormalFloat,CursorLine:NormalFloat,SignColumn:NormalFloat';
        width = viewport.width * 0.16;
        height = viewport.height;
        split = 'right';
      };
      children = {
        -- prompt
        function(viewport)
          return {
            buffer = props.prompt;
            style = {
              highlight = 'CursorLine:TabLineSel,NormalFloat:TabLineSel,SignColumn:TabLineSel,EndOfBuffer:TabLineSel';
              width = viewport.width * 0.5;
              height = 1;
              row = viewport.height - 4;
              col = 0;
            }
          }
        end;
        -- status
        function(viewport)
          return {
            buffer = props.status;
            style = {
              highlight = 'CursorLine:TabLineSel,NormalFloat:TabLineSel,SignColumn:TabLineSel,EndOfBuffer:TabLineSel';
              width = viewport.width * 0.5;
              height = 1;
              row = viewport.height - 4;
              col = viewport.width * 0.5;
            }
          }
        end;
      }
    }
  end
end

