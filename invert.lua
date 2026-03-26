---@param input string
local function invert(input)
  local output = input

  local res = {}

  local i = 1
  local prev_t = 'a'
  while true do
    local s, e, t = output:find('{%%(=?).-%%}', i)
    if not s then
      if i <= #output then
        res[#res + 1] = string.format("_write([[%s]])", output:sub(i))
      end
      break
    end

    if i < s and (prev_t == 'a' or (t == '=' or prev_t == '=')) then
      local k = output:sub(i, s - 1)
      if prev_t ~= '=' then
        k = k:gsub('^%s-\n', '')
      end
      if t ~= '=' then
        k = k:gsub('[^%S\n]-$', '')
      end
      res[#res + 1] = string.format("_write([[\n%s]])", k)
    end

    res[#res + 1] = output:sub(s, e)

    prev_t = t
    i = e + 1
  end

  output = table.concat(res)

  -- now we can fill in the lua stuff
  output = output:gsub('{%%=(.-)%%}', [=[_write(%1)]=])
  output = output:gsub('{%%(.-)%%}', [[%1
]])
  return output
end

return invert
