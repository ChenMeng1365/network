
# VNE9000 pool

```ruby
@sign << ['VNE9000', '地址池解析']
@sign << ['VNE9000', 'nat地址配置']

module VNE9000
  module_function

  def 地址池解析 配置散列
    地址池列表 = []
    地址池配置 = 配置散列['dap-server'].select{|配置|配置.include?('ip pool')}
    地址池配置.each do|地址池|参数 = {}
      地址池.each_line do|line|
        if line.include?('ip pool') and (args = line.split('ip pool ')[-1].split(' '))
          参数['name'] = args[0]
        end
        if line.include?('network') and (args = line.split('network ')[-1].split(' '))
          参数['network'] ||= []
          参数['network'] << [args[0],args[1],args[4]] # 0:network 1:masklen 2:blocklen
        end
      end
      地址池列表 << 参数
    end

    新地址池列表 = []
    地址池配置2 = 配置散列['ip'].select{|配置|配置.include?('ip pool')}
    地址池配置2.each do|地址池|参数 = {}
      地址池.each_line do|line|
        if line.include?('ip pool') and (args = line.split('ip pool ')[-1].split(' '))
          参数['name'] = args[0]
          参数['mode'] = args[1..-1].join(' ')
        end
        if line.include?('dap-server') and (args = line.split('pool ')[-1].split(' '))
          参数['dap-pool'] = args[0]
        end
        if line.include?('subnet') and (args = line.split(' '))
          参数['subnet-length'] = [args[args.index('initial')+1], args[args.index('extend')+1]] # 0:initial 1:extend
        end
        if line.include?('vpn-instance') and (args = line.split('vpn-instance ')[-1].split(' '))
          参数['vpn-instance'] = args.first
        end
        if line.include?('dns-server') and (args = line.split('dns-server ')[-1].split(' '))
          参数['dns-server'] = args
        end
      end

      if 地址池 = 地址池列表.find{|地址池|地址池['name'] == 参数['dap-pool']}
        参数.delete('name')
        新地址池列表 << 地址池.merge(参数)
        地址池列表.delete(地址池)
      end
    end

    新地址池列表 + 地址池列表
  end

  def nat地址配置 配置散列

  end
end
```
