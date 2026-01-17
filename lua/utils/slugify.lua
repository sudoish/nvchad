local M = {}

-- No length limit for git flow branch names

local function is_alphanumeric_char(char)
  local byte = string.byte(char)
  if not byte then
    return false
  end
  return (byte >= 48 and byte <= 57) or (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)
end

function M.slugify(text)
  if type(text) ~= "string" or #text == 0 then
    return ""
  end

  local result = {}
  local prev_was_separator = false
  local i = 1

  while i <= #text do
    local char = text:sub(i, i)
    local byte = string.byte(char)

    if byte and is_alphanumeric_char(char) then
      local lower_char = char:lower()
      result[#result + 1] = lower_char
      prev_was_separator = false
    else
      if not prev_was_separator then
        result[#result + 1] = "-"
        prev_was_separator = true
      end
    end

    i = i + 1
  end

  local slug = table.concat(result)

  slug = slug:gsub("^%-+", "")
  slug = slug:gsub("%-+$", "")

  -- No length truncation - allow full slug for git flow branch names

  return slug
end

return M
