
# NE40E-X8 BGP

```ruby
@sign << ['NE40E-X8', '宣告网段解析']

module NE40E_X8
  module_function

  def 宣告网段解析 配置散列
    ranges = []
    配置散列['bgp'].first.split("\n").each do|line|
      if line.include?('network ') && line.split(' ').size > 2
        ip1,ip2 = line.split(' ')[1..2]
        ip, mask = line.split(' ')[1].include?(':') ? IP.v6("#{ip1}/#{ip2}") : IP.v4("#{ip1}/#{ip2}")
        network = ip.network_with mask
        start_ip, end_ip = ip.range_with mask
        ranges << [ 'bgp', network.to_s, end_ip.to_s ]
      end
      # puts [hostname]+line.split(' ') if line.include?('network ') && line.split(' ').size == 2
    end
    return ranges
  end
end
```