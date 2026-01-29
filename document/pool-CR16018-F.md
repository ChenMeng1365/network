# CR16018-F pool

```ruby
@sign << ['CR16018-F', '地址池解析']
@sign << ['CR16018-F', 'nat地址配置']


module CR16018_F
  module_function

  def 地址池解析 配置散列
    地址池列表 = []; 分组列表 = {}
    地址池配置 = 配置散列['ip'].select{|配置|配置.include?('ip pool ')}
    地址池分组 = 配置散列['ip'].select{|配置|配置.include?('ip pool-group')}
    地址池分组.each do|分组|
      tag = nil
      分组.each_line do|line|
        if line.include?('pool-group') and (args = line.split('ip pool-group ')[-1].split(' '))
          tag = args[0]
          分组列表[tag] ||= {}
        end
        if line.include?('pool') and !line.include?('pool-group') and (args = line.split('pool ')[-1].strip)
          分组列表[tag]['pool'] ||= []
          分组列表[tag]['pool'] << args
        end
        if line.include?('vpn-instance') and (args = line.split('vpn-instance ')[-1].strip)
          分组列表[tag]['vpn-instance'] = args
        end
      end
    end

    地址池配置.each do|地址池|参数 = {}
      地址池.each_line do|line|
        if line.include?('ip pool') and (args = line.split('ip pool ')[-1].split(' '))
          参数['name'] = args[0]
          分组列表.each do|tag,args|
            参数['vpn-instance'] = args['vpn-instance'] if args['pool'].include?(参数['name']) && args['vpn-instance']
          end
        end
        if line.include?('gateway') and (args = line.split('gateway-list ')[-1].split(' '))
          参数['gateway'] = args[0]
          参数['mode'] = args[1] if args.size>1
        end
        if line.include?('network') and (args = line.split('network ')[-1].split(' '))
          参数['network'] ||= []
          参数['gatemsk'] = args[2]
          参数['network'] << [args[0],args[2]] # network, netmask
        end
        if line.include?('dns-list') and (args = line.split('dns-list ')[-1].split(' '))
          参数['dns-list'] = args
        end
        # if line.include?('forbidden-ip') and (args = line.split('forbidden-ip ')[-1].split(' '))
        #   参数['forbidden-ip'] = args
        # end
      end
      地址池列表 << 参数
    end
    地址池列表
  end

  def nat地址配置 配置散列
    nat地址组 = {}
    address_groups = 配置散列['nat'].select{|配置|配置.include?('nat address-group')}
    address_groups.each do|地址组|
      id = nil
      地址组.each_line do|line|
        if line.include?('nat address-group') and (args = line.split('nat address-group ')[-1].split(' '))
          id = args[0]
          nat地址组[id] ||= {}
        end
        if line.include?('port-range') and (args = line.split('port-range ')[-1].split(' '))
          nat地址组[id]['port-range'] = args.map{|a|a.to_i}
        end
        if line.include?('port-block') and (args = line.split('port-block ')[-1].split(' '))
          nat地址组[id]['port-block'] = args.last.to_i
        end
        if line.include?('address') and !line.include?('nat address') and (args = line.split('address ')[-1].split(' '))
          nat地址组[id]['address'] ||= []
          nat地址组[id]['address'] << [args[0],args[1]] # start, finish
        end
      end
    end

    nat_instances = 配置散列['nat'].select{|配置|配置.include?('nat instance')}
    nat_instances.each do|nat_instance|
      nat_inst_id,nat_inst_name,service_inst_group,addr_group,vpn_inst = nil,nil,nil,nil,nil
      nat_instance.each_line do|line|
        if line.include?('nat instance')
          nat_inst_id = line.split('id').last.to_i
          nat_inst_name = line.split('instance').last.split(' ').first.strip
        end
        if line.include?('service-instance-group')
          service_inst_group = line.split('service-instance-group ')[-1].strip
        end
        if line.include?('address-group')
          addr_group = line.split('address-group ')[-1].split(' ').first
          vpn_inst = line.split('vpn-instance ')[-1] if line.include?('vpn-instance')
        end
      end
      nat地址组[addr_group]['nat-instance-id'] = nat_inst_id
      nat地址组[addr_group]['nat-instance-name'] = nat_inst_name
      nat地址组[addr_group]['service-inst-group'] = service_inst_group
      nat地址组[addr_group]['vpn-instance'] = vpn_inst
    end
    nat地址组
  end
end
```