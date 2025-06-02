
# NE5000E-X16A 访问控制列表

```ruby
@sign << ['NE5000E-X16A', 'ACL']

module NE5000E_X16A
  module_function

  def ACL config
    table = {}
    number = nil
    config.split("\n").each do|line|
      number = line.split('number')[1].strip.to_i if line.include?('acl number') or line.include?('acl ipv6 number')
      table[number] ||= {}
      if line.include?('rule')
        rule = line.split(' ')
        table[number][rule[1].to_i] = rule[2..-1]
      end
    end
    table.delete(nil)
    return table
  end
end
```