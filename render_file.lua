local render = require('render')

---@param from string
---@param to string
local function render_file(from, to)
  local file, err = io.open(from, 'r')
  if not file then
    error(err)
  end
  local input = file:read('*all')
  file:close()
  local output = render(input)
  file, err = io.open(to, 'w')
  if not file then
    error(err)
  end
  file:write(output)
  file:flush()
  file:close()
end

return render_file
