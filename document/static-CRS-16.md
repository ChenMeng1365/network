
# CRS-16 静态路由

```ruby
@sign << ['CRS-16', '静态路由']

module CRS_16
    module_function

  def 静态路由 配置散列
    routes = []
    配置散列['router'].each do|seg|
      flag = false
      seg.split("\n").each do|line|
        flag = true if line.include?('router static')
        if flag && !line.include?('!')
          words = line.split(" ")
          target = words.first
          if /[a-zA-Z\-]+/.match(words[1])
            nextif = words[1] 
            nexthop = words[2] if /[\d\.]+/.match(words[2])
          elsif /[\d\.]+/.match(words[1])
            nexthop = words[1]
          end
          description = words[words.index('description')+1] if words.index('description')
          tag = words[words.index('tag')+1] if words.index('tag')
          routes << ['static',target, nextif, nexthop, description, tag]
        end
        flag = false if line.include?('!')
      end
    end
    routes.delete(["static", "router", "static", nil, nil, nil])
    routes.delete(["static", "maximum", "path", "ipv4", nil, nil])
    routes.delete(["static", "maximum", "path", "ipv6", nil, nil])
    routes.delete(["static", "address-family", "ipv4", nil, nil, nil])
    routes
  end

end
```