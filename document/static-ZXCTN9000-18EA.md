
# ZXCTN9000-18EA

```ruby
@sign << ['ZXCTN9000-18EA', '静态路由']

module ZXCTN9000_18EA
  module_function

  def 静态路由 配置散列
    static_routes = []
    ['static','ipv6-static-route'].each do|tag|
      lines = (配置散列[tag] || "").split("\n")
      lines.each_with_index do|line,index|
        next unless line.include?('route ')
        if line.size==80 && lines[index+1][0..1]!='ip'
          items = (line+lines[index+1]).split(" ")
        else
          items = line.split(" ")
        end
        if items[2].include?('vrf')
          head = "static:#{items[3]}"
          tail = items[4].include?(':') ? items[4].split('/')+items[5..-1] : items[4..-1]
        else
          head = "static"
          tail = items[2].include?(':') ? items[2].split('/')+items[3..-1] : items[2..-1]
        end
        static_routes << [head]+tail
      end
    end
    return static_routes
  end
end
```