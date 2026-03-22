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
        res[#res + 1] = string.format("io.write([[%s]])", output:sub(i))
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
      res[#res + 1] = string.format("io.write([[\n%s]])", k)
    end

    res[#res + 1] = output:sub(s, e)

    prev_t = t
    i = e + 1
  end

  output = table.concat(res)

  -- now we can fill in the lua stuff
  output = output:gsub('{%%=(.-)%%}', [=[io.write(%1)]=])
  output = output:gsub('{%%(.-)%%}', [[%1
]])
  return output
end

local function renderfile(input, filename)
  local e = invert(input)
  local res, err = loadstring(e)
  if not res then
    -- print(e)
    error(err)
  end
  local prev = io.output()
  io.output(filename)
  res()
  io.flush()
  io.output(prev)
end

---@param input string
---@return string
local function render(input)
  local tmp_output = os.tmpname()
  renderfile(input, tmp_output)
  local f, err = io.open(tmp_output, 'r')
  if not f then error(err) end
  local output = f:read('*all')
  f:close()
  return output
end

return render
