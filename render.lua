local compile = require('compile')

---@param input string
---@param env table?
---@return string
local function render(input, env)
  local c = compile(input)
  return c(env)
end

return render
