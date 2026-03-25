local render = require('render')
local render_file = require('render_file')

function test(name, fn)
  if fn() then
    print('🔥 succeeded ' .. name)
  else
    error('❌ failed ' .. name)
  end
end

test('basic render', function()
return render [[
Numbers 1 to 3:
{% for i = 1, 3 do %}
Number: {%=i%}!
{% end %}
]]==[[
Numbers 1 to 3:
Number: 1!
Number: 2!
Number: 3!
]]
end)

test('utf-8', function()
  return render [[
Some things:
{% if true then %}
Number: {%= 2 + 3 %}!
❌
{% end %}
]]==[[
Some things:
Number: 5!
❌
]]
end)

test('render_file', function()
  render_file('test/file.txt.elua', 'test/file.txt')
  return os.execute('cmp -s test/file.txt test/file.txt.expected') == 0
end)

test('render HTML with params', function()
  Title = "foo"
  Items = {"bar", "baz", "boom", "asdfgasdf"}
  render_file('test/file.elua.html', 'test/file.html')
  return os.execute('cmp -s test/file.html test/file.html.expected') == 0
end)

test('README example', function()
  return render [[
<ol>
{% for i = 1,3 do %}
  <li>Item {%= i %}</li>
{% end %}
</ol>
]] == [[
<ol>
  <li>Item 1</li>
  <li>Item 2</li>
  <li>Item 3</li>
</ol>
]]
end)
