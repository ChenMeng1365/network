
# ALCATEL7750 static

```ruby
@sign << ['ALCATEL7750', '静态路由']

module ALCATEL7750
  module_function

    # [head='static', target-network, target-netmask, next-hop, preference, status='']
  def 静态路由 配置散列
    records = []
    statics = 配置散列["Static Route Configuration"]
    statics.each do|static|
      words = static.split(" ")
      if words.index("static-route")
        target = words[words.index("static-route")+1]
        network, netmask = target.split("/")
      end
      if words.index("next-hop")
        nexthop = words[words.index("next-hop")+1]
      end
      if words.index("preference")
        preference = words[words.index("preference")+1]
      end
      records << ['static', network, netmask, nexthop, preference, '']
    end
    return records
  end

end
```