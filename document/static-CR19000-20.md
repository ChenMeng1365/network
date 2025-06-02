
# CR19000-20 静态路由

```ruby
@sign << ['CR19000-20', '静态路由']

module CR19000_20
  module_function

  def 静态路由 配置散列
    static_routes = []
    ['ip','ipv6'].each do|tag|
      (配置散列[tag] || []).each do|part|
        if part.include?('route-static ')
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

```ruby
@sign << ['CR19000-20', '静态用户地址']
@sign << ['CR19000-20', '静态接口地址', 'PENDING']
@sign << ['CR19000-20', '静态域地址', 'PENDING']

module CR19000_20
  module_function

  def 静态用户地址 conf
    tab = []
    (conf['ip'] || []).each do|part|
      part.split("\n").each do|line|
        next unless line.include? 'subscriber session static ip'
        words = line.split(' ')
        tab << words
      end
    end
    tab
  end

  def 静态接口地址 raw,*guards
    tab = []
    # PENDING
    return tab
  end

  def 静态域地址 raw,*guards
    tab = []
    # PENDING
    return tab
  end
end
```