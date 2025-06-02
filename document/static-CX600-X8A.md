
# CX600-X8A 静态信息

```ruby
@sign << ['CX600-X8A', '静态路由']

module CX600_X8A
  module_function

  def 静态路由 配置散列
    static_routes = []
    ['ip','ipv6'].each do|tag|
      (配置散列[tag] || []).each do|part|
        if part.include?('route-static')
          part.split("\n").each do|line|
            items = line.split(" ")
            record = items[2].include?('vpn-') ? ["static:#{items[3]}"]+items[4..-1] : ["static"]+items[2..-1]
            static_routes << record
          end
        end
      end
    end
    return static_routes
  end
end
```