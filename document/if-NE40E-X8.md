
# NE40E-X8 接口

```ruby
@sign << ["NE40E-X8", "接口配置"]
@sign << ["NE40E-X8", "特殊接口配置"]
@sign << ["NE40E-X8", "物理接口配置"]
@sign << ["NE40E-X8", "子接口配置"]
@sign << ["NE40E-X8", "接口分捡"]
@sign << ["NE40E-X8", "端口识别"]
@sign << ["NE40E-X8", "端口MAC"]
@sign << ["NE40E-X8", "端口管理状态"]
@sign << ["NE40E-X8", "接口描述"]
@sign << ["NE40E-X8", "接口地址"]
@sign << ["NE40E-X8", "接口开关"]
@sign << ["NE40E-X8", "接口vpn实例"]
@sign << ["NE40E-X8", "接口QoS"]
@sign << ["NE40E-X8", "接口流策略"]
@sign << ["NE40E-X8", "接口统计"]
@sign << ["NE40E-X8", "接口URPF"]
@sign << ["NE40E-X8", "接口接入类型"]
@sign << ["NE40E-X8", "聚合接口判定"]
@sign << ["NE40E-X8", "聚合接口分捡"]
@sign << ["NE40E-X8", "聚合逻辑接口"]
@sign << ["NE40E-X8", "聚合接口查询"]
@sign << ["NE40E-X8", "vlan分捡"]
@sign << ["NE40E-X8", "vlan统计"]
@sign << ["NE40E-X8", "统计接口"]

module NE40E_X8
  module_function
  #####################################################################################################
  # 接口/端口配置的基本查询
  # 接口集合 => 接口分检 => 物理接口集合,子接口集合,特殊接口集合
  #####################################################################################################
  def 接口配置 正文
    正文['interface'] # Array
  end

  def 特殊接口配置 接口集合
    接口集合.collect{|接口|
      接口 if /Virtual|Aux|NULL|LoopBack|Logic\-Channel/.match(接口.split("\n")[0])
    }.compact.sort_by{|接口|接口.split("\n")[0]}
  end

  def 物理接口配置 接口集合,特殊接口集合=nil
    其余接口 = 特殊接口集合 ? (接口集合-特殊接口集合) : (接口集合-self.特殊接口配置(接口集合))
    其余接口.collect{|接口|接口 unless 接口.split("\n")[0].include?('.')}.compact
  end

  def 子接口配置 接口集合,特殊接口集合=nil
    其余接口 = 特殊接口集合 ? (接口集合-特殊接口集合) : (接口集合-self.特殊接口配置(接口集合))
    其余接口.collect{|接口|接口 if 接口.split("\n")[0].include?('.')}.compact
  end

  def 接口分捡 接口集合
    特殊接口集合 = self.特殊接口配置(接口集合)
    物理接口集合 = self.物理接口配置(接口集合,特殊接口集合)
    子接口集合 = self.子接口配置(接口集合,特殊接口集合)
    return 物理接口集合,子接口集合,特殊接口集合
  end


  #####################################################################################################
  # 端口描述信息相关
  #####################################################################################################

  # func: 根据一个端口的描述信息，给出其格式化的类型、连接符、端口编号
  def 端口识别 描述
    连接符 = ''
    type = /100GE|GE|GigabitEthernet|Pos|Ethernet|Eth\-Trunk|Vlanif|Virtual\-Template|NULL|LoopBack|Aux/.match(描述)
    类型 = type ? type.to_s : '未知类型'
    port = /(\d+|\/|\.)*(\d+)/.match(描述.split(类型).join)
    端口 = port ? port.to_s : '未知端口'
    return 类型,连接符,端口
  end

  # func: 根据一个端口的描述信息，给出其mac地址，若无mac则返回nil
  def 端口MAC 描述
    描述.each_line do|line|
      if pattern = /Hardware address is (.+)/.match(line)
        matcher = /[\d|A-F|a-f]+\-[\d|A-F|a-f]+\-[\d|A-F|a-f]+/.match(pattern[1].strip)
        return pattern[1].strip if matcher.to_s==pattern[1].strip
      end
    end
    return nil
  end

  # func: 根据一个端口的描述信息，给出其管理状态是打开/关闭的判断
  def 端口管理状态 描述
    管理状态 = true
    描述.split("\n").each do|line|
      管理状态 = false if line.include?("shutdown") && !line.include?("undo shutdown")
    end
    管理状态
  end

  # func: 根据一个端口的配置给出其描述
  def 接口描述 接口配置
    描述 = ''
    接口配置.each_line do|line| if line.strip[0..10]=='description'
      描述 = line.split('description')[-1].strip; break
    end end
    描述.to_s
  end

  # func: 根据一个端口的配置给出其配置的接口地址
  def 接口地址 接口配置
    地址集 = []
    接口配置.each_line do|line|
      if line.strip[0..9]=='ip address' and !line.include?('unnumbered')
        地址集 << line.gsub("sub","").split('ip address')[-1].strip.split(' ')
      end
      if line.strip[0..11]=='ipv6 address' and !line.include?("auto link-local") and !line.include?('unnumbered')
        地址集 << line.gsub("sub","").split('ipv6 address')[-1].strip.split('/')
      end
    end
    地址集
  end

  # func: 根据一个端口的配置给出其开关状态（配置层面的"端口管理状态"）
  def 接口开关 接口配置
    描述 = ''
    接口配置.each_line do|line| 
      if line.include?('shutdown') and !line.include?('no') and !line.include?('undo') and !line.include?('description')
        描述 = 'shutdown'; break
      end
    end
    描述
  end
  
  # func: 根据一个端口的配置给出其关联的vpn实例
  def 接口vpn实例 接口配置
    实例 = ''
    接口配置.each_line do|line|
      实例 = "vpn-inst:" + /vpn\-instance .+/.match(line).to_s.split(" ")[-1] if /vpn\-instance .+/.match(line)
      实例 = "vsi:" + /vsi .+/.match(line).to_s.split(" ")[-1] if /vsi .+/.match(line)
    end
    实例
  end

  # func: 端口应用QoS模板
  def 接口QoS 接口配置
    qos = {}
    接口配置.each_line do|line|
      if line.include?('qos-profile')
        words = line.split(' ')
        direction = line.include?('inbound') ? 'inbound' : 'outbound'
        profile = words[words.index('qos-profile')+1]
        if vlan_index = words.index('vlan')
          qos["vlan-id:#{words[vlan_index+1]}"] ||= {}
          qos["vlan-id:#{words[vlan_index+1]}"][direction] = profile
        elsif words.index('pe-vid') && words.index('ce-vid')
          pe_index, ce_index = words.index('pe-vid'), words.index('ce-vid')
          qos["pvc-id:#{words[pe_index+1]}/#{words[ce_index+1]}"] ||= {}
          qos["pvc-id:#{words[pe_index+1]}/#{words[ce_index+1]}"][direction] = profile
        else
          qos["port"] ||= {}
          qos["port"][direction] = profile
        end
      end
    end
    qos
  end

  # func: 端口应用流量模板
  def 接口流策略 接口配置
    traffic = {}
    接口配置.each_line do|line|
      if line.include?('traffic-policy')
        words = line.split(' ')
        direction = line.include?('inbound') ? 'inbound' : 'outbound'
        profile = words[words.index('traffic-policy')+1]
        traffic[direction] = profile
      end
    end
    traffic
  end

  # func: 端口统计功能
  def 接口统计 接口配置
    接口配置.each_line do|line|
      return :statistic if line.strip =='statistic enable'
    end
    return false
  end

  # func: 端口URPF功能
  def 接口URPF 接口配置
    接口配置.each_line do|line|
      return (line.include?('strict') ? 'strict' : 'loose') if line.include?('urpf')
    end
    return nil
  end

  # func: 端口接入类型
  def 接口接入类型 接口配置
    接口配置.each_line do|line|
      if line.include?('access-type')
        words = line.split(' ')
        atype = words[words.index('access-type')+1]
        if words.index('default-domain')
          a3dom = words[words.index('default-domain')+1]
          dname = words[words.index('default-domain')+2]
          return {'access-type'=>atype, a3dom => dname}
        else
          return {'access-type'=>atype}
        end
      end
    end
    return {}
  end

  #####################################################################################################
  # 聚合接口判定相关
  #####################################################################################################
  
  # func: 根据一个接口的描述信息，给出其所属聚合接口的信息，若非聚合端口返回空
  def 聚合接口判定 配置
    配置.split("\n").each do|描述|
      if 描述.include?("eth-trunk") && !描述.include?("description")
        return {self.端口识别(配置).join=>"Eth-Trunk"+描述.split("eth-trunk")[1].strip}
      end
    end;{}
  end

  # func: 给出聚合接口和物理接口的集合，通过计算找出所有聚合接口的集合
  def 聚合接口分捡 聚合接口,物理接口集合
    聚合接口 = self.端口识别(聚合接口)
    聚合接口集合 = [聚合接口.join]
    物理接口集合.each do|物理接口| 物理接口.each_line do|line|
      聚合接口集合 << self.端口识别(物理接口).join if line.include?("eth-trunk #{聚合接口[-1]}")
    end end
    聚合接口集合
  end

  # func: 根据一个接口的描述信息，给出其所属聚合接口的逻辑接口，若无返回空
  def 聚合逻辑接口 配置
    配置.split("\n").each do|描述|
      return 描述.split(" ")[-1] if 描述.include?("nas logic-port")
    end
    return nil
  end

  # func: 给出聚合接口查询命令的返回结果，提取接口对应的物理接口，若无返回空
  def 聚合接口查询 查询报文
    return [] if 查询报文.include?("not exist")
    parts = 查询报文.split("--------------------------------------------------------------------------------")
    return parts[1].split("\n").map{|s|s.split(" ")}.select{|s|s.size>1}.map{|s|s.first.split('(').first}.select{|s|!s.include?('Actor')}
  end

  #####################################################################################################
  # 接口VLAN相关
  # 对接口vlan配置的解析
  # dot1q : [vlan, ...]
  # qinq  : [[pvlan, (cvlan..cvlan)], [pvlan, cvlan], ...]
  # vlan  : [(cvlan..cvlan), cvlan, ...]
  #####################################################################################################
  def vlan分捡 接口配置
    vlan = {}
    接口配置.each_line do|line| next if line.include?('undo')
      if pattern = /vlan\-type dot1q (\d+)/.match(line)
        dot1q = pattern.to_s.split("dot1q")[-1].strip.to_i
        vlan['dot1q'] ||= [];vlan['dot1q'] << dot1q;next
      end
      if pattern = /dot1q termination vid (\d+)/.match(line) # new version
        dot1q = pattern.to_s.split("vid")[-1].strip.to_i
        vlan['dot1q'] ||= [];vlan['dot1q'] << dot1q;next
      end
      if pattern = /qinq termination pe-vid (\d+) ce-vid (\d+)/.match(line) # new version
        qinq = [pattern[1], pattern[2]]
        vlan['qinq'] ||= [];vlan['qinq'] << qinq;next
      end
      if pattern = /user\-vlan (\d+) (\d+) qinq (\d+)/.match(line)
        qinq = [pattern[3].to_i, (pattern[1].to_i)..(pattern[2].to_i)]
        vlan['qinq'] ||= [];vlan['qinq'] << qinq;next
      end
      if pattern = /user\-vlan (\d+) qinq (\d+)/.match(line)
        qinq = [pattern[2].to_i, pattern[1].to_i]
        vlan['qinq'] ||= [];vlan['qinq'] << qinq;next
      end
      if pattern = /user\-vlan (\d+) (\d+)/.match(line)
        user_vlan = ((pattern[1].to_i)..(pattern[2].to_i))
        vlan['vlan'] ||= [];vlan['vlan'] << user_vlan;next
      end
      if pattern = /user\-vlan (\d+)/.match(line)
        user_vlan = pattern[1].to_i
        vlan['vlan'] ||= [];vlan['vlan'] << user_vlan;next
      end
    end
    return vlan # {vlan:[ int|range ] qinq:[ [int,int|range] ] dot1q:[ int ]}
  end
  
  def vlan统计 name,物理接口集合,子接口集合
    bas子接口数据库,聚合接口表 = {},[]
    聚合接口集合 = 物理接口集合.select{|物理接口|self.端口识别(物理接口)[0]=='Eth-Trunk'}
    聚合接口表 += 聚合接口集合.collect{|聚合接口|self.聚合接口分捡(聚合接口,物理接口集合)}
    
    子接口集合.each do|接口配置|
      物理接口名称 = self.端口识别(接口配置).join.split(".")[0]
      物理接口 = 物理接口集合.find{|物理接口|物理接口.split("\n")[0].split(" ")[1]==(物理接口名称)}
      next unless self.端口管理状态(物理接口) # 物理接口关闭的不统计
      next unless self.端口管理状态(接口配置) # 子接口关闭的不统计
      
      vlan配置 = {}
      self.vlan分捡(接口配置).each do|type,data|
        if type=='vlan'
          vlan配置[4096] ||= []; vlan配置[4096] += data # 用4096表示单层vlan
        elsif type=='qinq'
          data.each{|pvlan,cvlan|vlan配置[pvlan] ||= []; vlan配置[pvlan] << cvlan}
        else
          # discard dot1q
        end
      end
      
      子接口名称 = self.端口识别(接口配置)
      bas子接口数据库[name] ||= {}
      子接口索引 = []
      if 子接口名称[0].include?("GigabitEthernet")
        # 子接口索引 = ["eth--"+子接口名称[-1].split(".")[0].split('/')[-3..-1].join(',')] # AIBOS风格
        子接口索引 = [子接口名称.join.split(".")[0]] # 原生风格
      end
      if 子接口名称[0].include?("Eth-Trunk") && 
        聚合接口组 = 聚合接口表.find{|聚合接口组|聚合接口组.include?(子接口名称.join.split('.')[0])}
        聚合接口的等效名称 = 聚合接口组.clone
        #聚合接口的等效名称.delete(子接口名称.join.split('.')[0]) # 除了trunk自身，为所有等效接口创建  # 是否保留Trunk是个争议
        子接口索引 = 聚合接口的等效名称.collect do|等效名称|
          # "trunk--"+self.端口识别(等效名称)[-1].split(".")[0].split('/')[-3..-1].join(',') # AIBOS风格
          self.端口识别(等效名称).join.split(".")[0] # 原生风格
        end
      end
      
      子接口索引.each do|索引|
        bas子接口数据库[name][索引] ||= {}
        vlan配置.each do|pv,cv|
          bas子接口数据库[name][索引][pv] ||= []
          bas子接口数据库[name][索引][pv] += cv
          bas子接口数据库[name][索引][pv].uniq!
        end
      end
    end
    return bas子接口数据库
  end


  #####################################################################################################
  # 接口相关统计信息的处理
  #####################################################################################################
  
  # 针对display interface brief main
  def 统计接口 文本
    文本.split("\n").inject([]) do|表格, 行|
      表格 << 行.split(" ") if 行.include?("100GE") or 行.include?("GigabitEthernet") or 行.include?("Eth-Trunk")
      表格 # [interface, physical, protocol, in-uti, out-uti, in-errors, out-errors]
    end
  end
end
```