local M = {}

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
        local suffix = output:sub(i)
        if prev_t ~= '=' then
          suffix = suffix:gsub('^%s-\n', '')
          if suffix:match('^%s+$') then
            -- let's avoid printing whitespaces following a non-printer.
            break
          end
        end
        res[#res + 1] = string.format("_write('%s')", suffix:gsub('\n', '\\n'):gsub("'", "\'"))
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
      res[#res + 1] = string.format("_write('%s')", k:gsub('\n', '\\n'):gsub("'", "\'"))
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

---@param input string
---@return function(env: table): string
function M.compile(input)
  local t = invert(input)
  local f, err = loadstring(t)
  if not f then
    print(t)
    error('bad template: ' .. err)
  end
  return function(env)
    local res = {}
    local _write = function(x)
      res[#res + 1] = tostring(x)
    end
    local fenv = {
      _write = _write
    }
    setmetatable(fenv, { __index = _G })
    if env then
      for k, v in pairs(env) do
        fenv[k] = v
      end
    end
    setfenv(f, fenv)
    f()
    return table.concat(res)
  end
end

---@param input string
---@param env table?
---@return string
function M.render(input, env)
  local c = M.compile(input)
  return c(env)
end

---@param from string
---@param to string
function M.render_file(from, to)
  local file, err = io.open(from, 'r')
  if not file then
    error(err)
  end
  local input = file:read('*all')
  file:close()
  local output = M.render(input)
  file, err = io.open(to, 'w')
  if not file then
    error(err)
  end
  file:write(output)
  file:flush()
  file:close()
end

return M
