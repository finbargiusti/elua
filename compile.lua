local invert = require('invert')

---@param input string
---@return function(env: table): string
local function compile(input)
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
    local fenv = getfenv()
    if env then
      for k, v in pairs(env) do
        fenv[k] = v
      end
    end
    fenv['_write'] = _write
    setfenv(f, fenv)
    f()
    return table.concat(res)
  end
end

return compile
