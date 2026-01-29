
# CRS-16 bgp

```ruby
@sign << ['CRS-16', '宣告网段解析']

module CRS_16
  module_function

  def 宣告网段解析 配置散列
    ranges = []
    配置散列['router'].each do|segment|
      next unless segment.include?('router bgp ')
      bgps = segment.match_paragraph("router bgp ", "\n!\n")
      bgps.each do|bgp|
        bgp.split("\n").each do|line|
          if line.include?('network ') && line.strip.split(' ').size > 1
            words = line.split(' ')
            address, netmask = line.split(' ')[1].include?(':') ? IP.v6(words[1]) : IP.v4(words[1])
            network = address.network_with netmask
            route_policy = words.index('route-policy') ? words[words.index('route-policy')+1] : ''
            ranges << [ 'bgp', network.to_s, netmask.to_s, route_policy ]
          end
        end
      end
    end
    return ranges
  end
end
```
