
# M6000-8 静态信息

```ruby
@sign << ['M6000-8', '静态路由']

module M6000_8
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

```ruby
@sign << ['M6000-8', '静态用户地址']
@sign << ['M6000-8', '静态接口地址']
@sign << ['M6000-8', '静态域地址']

module M6000_8
  module_function

  def 静态用户地址 conf
    tab = []
    lines = (conf['ip-host'] || "").split("\n")
    lines.each_with_index do|line,index|
      next unless line.include?('ip-host')
      if line.size==80 && lines[index+1][0..1]!='  '
        words = (line+lines[index+1]).split(" ")
      else
        words = line.split(' ')
      end
      tab << words
    end
    tab
  end

  def 静态接口地址 raw,*guards
    tab = []
    content = raw.split('show arp dynamic')[1].to_s.split('HB-')[0].to_s
    textlist = content.split('--------------------------------------------------------------------------------')[1].to_s
    textlist.split("\n").each do|line|
      item = line.strip.split(' ')
      if item.size == 1
        tab[-1][3] += item[0]
      elsif item.size == 2
        tab[-1][3] += item[0]
        tab[-1][-1]+= item[1]
      else
        tab << item
      end
    end

    content = raw.split('show arp permanent')[1].to_s.split('HB-')[0].to_s
    textlist = content.split('--------------------------------------------------------------------------------')[1].to_s
    textlist.split("\n").each do|line|
      item = line.strip.split(' ')
      if item.size == 1
        tab[-1][3] += item[0]
      else
        tab << item
      end
    end
    return tab
  end

  def 静态域地址 raw,*guards
    tab = []
    content = raw.split('show subscriber user-type ip-host')[1].to_s.split('HB-')[0].to_s
    textlist = content.split('--------------------------------------------------------------------------------')[1].to_s
    textlist.split("\n").each do|line|
      item = line.strip.split(' ')
      if item.size == 1
        tab[-1][1] += item[0]
      else
        item.insert 1, ''
        tab << item
      end
    end
    return tab
  end
end
```