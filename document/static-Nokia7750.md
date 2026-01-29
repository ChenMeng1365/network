
# Nokia7750 static

```ruby
@sign << ['Nokia7750', '静态路由']

module Nokia7750
  module_function

    # [head='static', target-network, target-netmask, next-hop, preference, status='']
    def 静态路由 配置散列
    statics = 配置散列["Static Route Configuration"].join("\n").match_paragraph("\n        static-route-entry", "\n        exit")
    records = []
    statics.each do|static|
      record = [nil, nil, nil, '', '']
      static.split("\n").each_with_index do|context, index|
        if index==0
          record = context.strip.split('/') + [nil,'','']
        else
          record[2] = 'black-hole' if context.include?('black-hole')
          record[2] = context.split(' ').last if context.include?('next-hop')
          record[3] = context.split('preference ').last if context.include?('preference')
          record[4] = 'shutdown' if context.include?('shutdown') && !context.include?('no shutdown')
          (records << ['static']+record.clone;record = [record[0], record[1]]+[nil, '', '']) if context.include?('exit')
        end
      end
    end
    return records
  end

end
```
