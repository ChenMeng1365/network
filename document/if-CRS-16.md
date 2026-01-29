
# CRS-16 IF

```ruby
@sign << ['CRS-16', '接口配置']
@sign << ['CRS-16', '接口分捡']
@sign << ['CRS-16', '端口识别']
@sign << ['CRS-16', '接口地址']
@sign << ['CRS-16', '接口描述']
@sign << ['CRS-16', '接口vpn实例']
@sign << ['CRS-16', '接口开关']
@sign << ['CRS-16', '接口QoS']
@sign << ['CRS-16', '接口流策略']

module CRS_16
    module_function

    def 接口配置 正文
        正文['interface']
    end

    def 接口分捡 接口集合
        物理接口集合,子接口集合,特殊接口集合 = [],[],[]
        接口集合.each do|接口|
            类型,连接符,端口 = self.端口识别 接口
            (子接口集合 << 端口;next) if 端口.include?('.')
            (特殊接口集合 << 端口;next) if ['Loopback','MgmtEth','tunnel-ip'].include?(类型)
            物理接口集合 << 端口
        end
        return 物理接口集合,子接口集合,特殊接口集合
    end

    def 端口识别 描述
        连接符 = ''
        name = 描述.split("\n").first.gsub('preconfigure','').split(' ').last
        type = /MgmtEth|tunnel\-ip|Bundle\-Ether|Loopback|GigabitEthernet|HundredGigE|TenGigE|POS/.match(name)
        类型 = type ? type.to_s : '未知类型'
        port = /\d{1}(\w+|\/|\d+|\.)*/.match(name)
        端口 = port ? port.to_s : '未知端口'
        return 类型,连接符,端口
    end

    def 接口地址 接口配置
        地址集 = []
        接口配置.each_line do|line|
          if line.strip[0..11]=='ipv4 address' and !line.include?('unnumbered')
            地址集 << line.split('ipv4 address')[-1].strip.split(' ')
          end
          if line.strip[0..11]=='ipv6 address' and !line.include?("auto link-local") and !line.include?('unnumbered')
            地址集 << line.split('ipv6 address')[-1].strip.split('/')
          end
        end
        地址集
    end

    def 接口描述 接口配置
        描述 = ''
        接口配置.each_line do|line| if line.strip[0..10]=='description'
          描述 = line.split('description')[-1].strip; break
        end end
        描述.to_s
    end

    def 接口vpn实例 接口配置
        实例 = ''
        接口配置.each_line do|line|
          实例 = "vpn-inst:" + line.split("vrf").last.strip if line.strip[0..2]=='vrf'
        end
        实例
    end

    def 接口开关 接口配置
        描述 = ''
        接口配置.each_line do|line|
          if line.include?('shutdown') and !line.include?('no') and !line.include?('undo') and !line.include?('description')
            描述 = 'shutdown'; break
          end
        end
        描述
    end

    def 接口QoS 接口配置
        qos = {}
    end

    def 接口流策略 接口配置
        traffic = {}
        接口配置.each_line do|line|
          if line.include?('service-policy')
            words = line.split(' ')
            direction = line.include?('input') ? 'inbound' : 'outbound'
            profile = words[words.index('service-policy')+2]
            traffic[direction] = profile
          end
        end
        traffic
    end
end
```
