local Matcher = {}

function Matcher.query(query, items)
  Matcher.patterns(query)

  local matches = {}
  for _, item in ipairs(items) do
    local word = item.word
    if item.filter_text and #query > 0 and (string.byte(item.filter_text, 1) == string.byte(query, 1)) then
      word = item.filter_text
    end
    local chars = {}
    for pattern in Matcher.patterns(query) do
      local s, e = string.find(word, pattern)
      if s then
        for i = s, e do
          chars[i] = true
        end
      end
    end
  end
end

function Matcher.match(input, word)
  local input_bytes = string.byte(input, 1, -1)
  local word_bytes = string.byte(word, 1, -1)
  local input_len = #input_bytes
  local word_len = #word_bytes
  local input_index = 1
  local word_index = 0
  local chars = {}
  local matches = {}
  while true do
    -- seek next_word_index
    word_index = Matcher.get_next_word_index(word_bytes, word_index + 1)

    -- search matches
    for i = input_index, input_len do
    end
  end
end

function Matcher.get_next_word_index(bytes, index)
  while index <= #bytes do
    if index == 1 then
      return true
    end
    if not Matcher.is_lower(bytes, index - 1) and Matcher.is_upper(bytes, index) then
      return true
    end
    if not Matcher.is_alpha(bytes, index - 1) and Matcher.is_alpha(bytes, index) then
      return true
    end
    index = index + 1
  end
  return false
end

function Matcher.is_upper(bytes, index)
  return 65 <= bytes[index] and bytes[index] <= 96
end

function Matcher.is_lower(bytes, index)
  return 97 <= bytes[index] and bytes[index] <= 122
end

function Matcher.is_alpha(bytes, index)
  return 65 <= bytes[index] and bytes[index] <= 122
end

return Matcher
