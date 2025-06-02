
# NE40E-X8 地址池

```ruby
@sign << ['NE40E-X8', '地址池解析']
@sign << ['NE40E-X8', 'nat地址配置']
@sign << ['NE40E-X8', 'sub_range']
@sign << ['NE40E-X8', '地址池日志']

module NE40E_X8
  module_function

  def 地址池解析 配置散列
    地址池列表 = []
    地址池配置 = 配置散列['ip'].select{|配置|配置.include?('ip pool')}
    地址池配置.each do|地址池|参数 = {}
      地址池.each_line do|line|
        if line.include?('ip pool') and (args = line.split('ip pool ')[-1].split(' '))
          参数['name'] = args[0]
          参数['mode'] = args[1..-1].join(' ')
        end
        if line.include?('gateway') and (args = line.split('gateway ')[-1].split(' '))
          参数['gateway'] = args[0]
          参数['gatemsk'] = args[1]
        end
        if line.include?('section') and (args = line.split('section ')[-1].split(' '))
          参数['section'] ||= []
          参数['section'] << [args[1],args[2]] # 0:index 1:start 2:end
        end
        if line.include?('vpn-instance') and (args = line.split('vpn-instance ')[-1].split(' '))
          参数['vpn-instance'] = args.first
        end
        if line.include?('dns-server') and (args = line.split('dns-server ')[-1].split(' '))
          参数['dns-server'] = args
        end
      end
      地址池列表 << 参数
    end
    地址池列表
  end
  
  def nat地址配置 配置散列
    地址池列表 = [];参数 = {}
    return 地址池列表 unless 配置散列['nat']
    地址池配置 = 配置散列['nat'].select{|配置|配置.include?('nat instance ')}
    地址池配置.each do|片段|
      片段.each_line do|line|
        if line.include?("nat instance")
          地址池列表 << 参数 if 参数!={}
          参数 = {}
          参数['instance name'] =  line.split("instance ")[1].split(" ")[0].strip
          参数['instance id'] = line.split("instance ")[1].split("id ")[1].strip
        end
        参数['port-range'] =  line.split("port-range")[1].strip if line.include?("port-range")
        参数['instance group'] =  line.split("service-instance-group")[1].strip if line.include?("service-instance-group")
        if line.include?("nat address-group")
          参数['address group'] ||= {}
          参数['address group']['name'] = line.split("nat address-group ")[1].split(" ")[0].strip
          参数['address group']['id'] = line.split("nat address-group ")[1].split("id ")[1].strip
        end
        if line.include?("section")
          next if line.include?('lock')
          参数['address group']['pool'] ||= []
          if line.include?('mask') # section NUM NETWORK mask NETMASK
            a,section,net,b,masknum = line.split(" ")
            pool,mask = IP.v4("#{net}/#{masknum}")
            参数['address group']['pool'] << [section,pool.to_d,mask.to_d]
          elsif line.include?('exclude-ip-address') # section NUM exclude-ip-address START FINISH
            a, session, exclude, exstart, exfinish = line.split(' ')
            except_session = 参数['address group']['pool'].find{|s|s[0]==session}
            next unless except_session
            start, finish = except_session[1], except_session[2]
            if IP.v4(finish).is_mask?
              rstart, rfinish = IP.v4(start).range_with(IP.v4(finish))
              new_ranges = sub_range([rstart.number-1, rfinish.number], [IP.v4(exstart).number,IP.v4(exfinish).number]) 
            else
              new_ranges = sub_range([IP.v4(start).number, IP.v4(finish).number], [IP.v4(exstart).number,IP.v4(exfinish).number])
            end
            new_ranges.each do|new_range|
              # if empty, only delete old_range
              参数['address group']['pool'] << [session, (IP.v4('0.0.0.0')+new_range[0]).to_d, (IP.v4('0.0.0.0')+new_range[1]).to_d]
            end
            参数['address group']['pool'].delete(except_session)
          else # section NUM START FINISH
            a, session, start, finish = line.split(' ')
            参数['address group']['pool'] << [section,start,finish ]
          end
        end
        参数['address group']['outbound'] = line.split("outbound")[1].split(" ")[0] if line.include?("nat outbound")
      end

      地址池列表 << 参数
    end
    地址池列表
  end

  # 从一段地址范围中排除另一段地址范围 :=> 空,一段,两段地址范围
  def sub_range old_range, exclude_range
    a_start, a_end = old_range
    b_start, b_end = exclude_range
    result = []
    if a_start < b_start
      result << [a_start, [a_end, b_start - 1].min]
    end
    if a_end > b_end
      result << [[b_end + 1, a_start].max, a_end]
    end
    result
  end

  def 地址池日志 详细信息
    地址池列表 = [];时间标签 = Time.now.form
    分片信息 = 详细信息.split("IP address pool Statistic")[0].to_s.split("-----------------------------------------------------------------------\n")[1..-1]
    分片信息.each do|片段|单池 = {"Scan Time"=>时间标签}
      单池['Pool Name'] = /Pool\-Name( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['Pool No'] = /Pool\-No( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['Pool Constant Index'] = /Pool\-constant\-index( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['Position'] = /Position( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip.split(" ")[0]
      单池['Status'] = /Status( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['RUI Flag'] = /RUI\-Flag( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['Gateway'] = /Gateway( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip.split(" ")[0]
      单池['Mask'] = /Mask( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['Vpn Instance'] = /Vpn instance( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip.split(" ")[0]
      单池['Unnumbered Gateway'] = /Unnumbered gateway( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['Total'] = /Total( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['Used'] = /Used( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip.split(" ")[0]
      单池['Free'] = /Free( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['Conflicted'] = /Conflicted( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip.split(" ")[0]
      单池['Disable'] = /Disable( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['Designated'] = /Designated( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip.split(" ")[0]
      # NoNeed #单池['Gateway'] = /Gateway   :(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      单池['Ratio'] = /Ratio( )*:(.+)/.match(片段).to_s.split(":")[1].to_s.strip
      地址池列表 << 单池
    end
    地址池列表
  end
end
```