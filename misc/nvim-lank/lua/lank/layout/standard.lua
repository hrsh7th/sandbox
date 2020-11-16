return function()
  return function(viewport, props)
    local max_item_count = viewport.height * 0.16

    -- update contents
    local items = props.state:get_items()
    local lines = {}
    for i = props.state.index, math.min(#items, props.state.index + max_item_count) do
      table.insert(lines, items[i].word)
    end
    vim.api.nvim_buf_set_lines(props.main, 0, -1, false, lines)

    -- update cursor sign
    vim.fn.sign_unplace('LankSignCursor', { buffer = props.main })
    vim.fn.sign_place(0, 'LankSignCursor', 'LankSignCursor', props.main , { lnum = props.state.cursor; })

    -- update status
    local status_text = ('%d/%d'):format(#props.state:get_items(), #props.state.items)
    vim.api.nvim_buf_set_lines(props.status, 0, -1, false, { status_text })

    -- canvas
    return {
      buffer = props.main;
      style = {
        highlight = 'Normal:NormalFloat,CursorLine:NormalFloat,SignColumn:NormalFloat';
        width = viewport.width;
        height = viewport.height * 0.16;
        split = 'bottom';
      };
      children = {
        -- prompt
        function(viewport)
          return {
            buffer = props.prompt;
            style = {
              highlight = 'CursorLine:TabLineSel,NormalFloat:TabLineSel,SignColumn:TabLineSel,EndOfBuffer:TabLineSel';
              width = viewport.width - #status_text;
              height = 1;
              row = viewport.height;
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
              width = #status_text;
              height = 1;
              row = viewport.height;
              col = viewport.width - #status_text;
            }
          }
        end;
      }
    }
  end
end


