
# NE8100-X8 静态信息

```ruby
@sign << ['NE8100-X8', '静态路由']

module NE8100_X8
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