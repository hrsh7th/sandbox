function consume_input(key)
  cursor = get_cursor()
  mode = get_mode()
  if mode == "Normal" then
    if key == "h" then
      set_cursor(cursor[1] - 1, cursor[2])
    elseif key == "j" then
      set_cursor(cursor[1], cursor[2] + 1)
    elseif key == "k" then
      set_cursor(cursor[1], cursor[2] - 1)
    elseif key == "l" then
      set_cursor(cursor[1] + 1, cursor[2])
    elseif key == "i" then
      set_mode("Insert")
    elseif key == "0" then
      set_cursor(1, cursor[2])
    elseif key == "$" then
      line = get_line(cursor[2] - 1)
      set_cursor(string.len(line), cursor[2])
    elseif key == "Ctrl+c" then
      exit()
    end
  end
  if mode == "Insert" then
    if key == "Esc" then
      set_mode("Normal")
    elseif key == "Backspace" then
      delete()
    else
      input(key)
    end
  end
end

