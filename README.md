# ELua

Minimal lua-based templating library.

Usage:

```html
<ol>
    {% for i = 1,3 do %}
    <li>Item {%= i %}</li>
    {% end %}
</ol>
```

`{% %}` will become lua

`{%= %}` will be printed.

Any other text between at least one print-style block will also be printed.
