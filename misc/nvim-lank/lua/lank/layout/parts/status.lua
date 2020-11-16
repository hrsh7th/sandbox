return function()
  local state = {
    time = vim.loop.now();
    scene = {
      '-';
      '/';
      '|';
      '\\';
      '-';
      '/';
      '|';
      '\\'
    };
  }
  return function(viewport, props)
    if props.state.status == 'progress' then
      local idx = math.floor(((vim.loop.now() - state.time) % 800) / 100)
      local status_text = ('%d/%d %s'):format(#props.state:get_items(), #props.state.items, state.scene[idx + 1]);
      vim.api.nvim_buf_set_lines(props.status, 0, -1, false, { status_text })
      return {
        buffer = props.status;
        style = {
          highlight = 'NormalFloat:TabLineSel,CursorLine:TabLineSel,SignColumn:TabLineSel';
          width = #status_text;
          height = 1;
          row = 0;
          col = viewport.width - #status_text;
        };
      }
    end
    return nil
  end
end
