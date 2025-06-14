
# network utility

## Classic Reference

All documents are predefined in document directory.

```ruby
require  'cc'
CC.use 'kernel', 'file', 'chrono'
requires 'network', 'CasetDown/casetdown'

@sign = [] # signature is not mustable

# Mode A: Runtime
["document/telnet.md"].each do|path|
  codes = path.refine
  codes.run{|code|eval(code)}
end

# OR

# Mode B: Static
build = ["document/telnet.md"].inject(String.new) do |build, path|
  codes = path.refine
  build << "\n\n"+ codes.join("\n\n")
end
File.write "build.rb", build
require_relative 'build'

puts C7609
```

## Custom Refine

Use `custom-path.md` path `#refine(:active)` can load a markdown document anywhere.

<pre>
```ruby
module Custom
  def path
    'Hello~'
  end
end
```
</pre>

```ruby
build = "custom-path.md".refine(:active).join("\n")
File.write "build.rb", build
require_relative 'build'

include Custom
puts path
```