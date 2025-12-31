
# ME60-X16 静态信息

```ruby
@sign << ['ME60-X16', '静态路由']

module ME60_X16
  module_function

  def 静态路由 配置散列
    static_routes = []
    ['ip','ipv6'].each do|tag|
      (配置散列[tag] || []).each do|part|
        if part.include?('route-static ')
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

```ruby
@sign << ['ME60-X16', '静态用户地址']
@sign << ['ME60-X16', '静态接口地址']
@sign << ['ME60-X16', '静态域地址']

module ME60_X16
  module_function

  def 静态用户地址 conf
    tab = []
    (conf['static-user'] || []).each do|part|
      part.split("\n").each do|line|
        words = line.split(' ')
        tab << words
      end
    end
    tab
  end

  def 静态接口地址 raw,*guards
    tab = []
    content = raw.split('display arp all')[1].to_s.split('<')[0].to_s
    textlist = content.split('------------------------------------------------------------------------------')[1].to_s
    textlist.split("\n").each do|line|
      item = line.strip.split(' ')
      if item.size == 1
        tab[-1] += item
      else
        tab << item
      end
    end
    return tab
  end

  def 静态域地址 raw,*guards
    tab = []
    pools = *guards
    pools.each do|dname|

      content = raw.split("display access-user domain #{dname}")[1].to_s.split('<HB-')[0].to_s
      textlist = content.split('------------------------------------------------------------------------------')[2].to_s
      textlist.split("\n").each do|line|
        item = line.strip.split(' ')
        if item.size == 3
          tab[-1] += item
        else
          tab << item
        end
      end

    end
    return tab
  end
end
```