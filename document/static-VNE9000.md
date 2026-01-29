
# VNE9000 static

```ruby
@sign << ['VNE9000', '静态路由']

module VNE9000
  module_function

  def 静态路由 配置散列
    static_routes = []
    ['ip','ipv6'].each do|tag|
      (配置散列[tag] || []).each do|part|
        if part.include?('route-static')
          part.split("\n").each do|line|
            next unless line.include?('route-static ')
            items = line.split(" ")
            record = items[2].include?('vpn-') ? ["static:#{items[3]}"]+items[4..-1].to_a : ["static"]+items[2..-1].to_a
            static_routes << record
          end
        end
      end
    end
    return static_routes
  end
end

```