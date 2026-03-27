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

Anything between blocks will be printed, with the exception of whitespace between non-printing blocks.
