
# ZXCTN9000-8EA 接口

```ruby
@sign << ["ZXCTN9000-8EA", "接口配置"]
@sign << ["ZXCTN9000-8EA", "接口物理信息"]
@sign << ["ZXCTN9000-8EA", "接口基本信息"]
@sign << ["ZXCTN9000-8EA", "接口vlan信息"]
@sign << ["ZXCTN9000-8EA", "接口acl信息"]
@sign << ["ZXCTN9000-8EA", "接口mpls信息"]
@sign << ["ZXCTN9000-8EA", "接口lacp信息"]
@sign << ["ZXCTN9000-8EA", "接口isis信息"]
@sign << ["ZXCTN9000-8EA", "接口multicast信息"]
@sign << ["ZXCTN9000-8EA", "接口firload信息"]
@sign << ["ZXCTN9000-8EA", "接口port_request_info信息"]
@sign << ["ZXCTN9000-8EA", "接口arp信息"]
@sign << ["ZXCTN9000-8EA", "接口nd信息"]
@sign << ["ZXCTN9000-8EA", "接口interface_performance信息"]
@sign << ["ZXCTN9000-8EA", "接口ospf信息"]
@sign << ["ZXCTN9000-8EA", "接口urpf信息"]
@sign << ["ZXCTN9000-8EA", "接口am信息"]
@sign << ["ZXCTN9000-8EA", "接口uim信息"]
@sign << ["ZXCTN9000-8EA", "接口QoS"]
@sign << ["ZXCTN9000-8EA", "接口流策略"]
@sign << ["ZXCTN9000-8EA", "接口统计"]
@sign << ["ZXCTN9000-8EA", "接口URPF"]
@sign << ["ZXCTN9000-8EA", "接口接入类型"]
@sign << ["ZXCTN9000-8EA", "特殊接口配置"]
@sign << ["ZXCTN9000-8EA", "物理接口配置"]
@sign << ["ZXCTN9000-8EA", "子接口配置"]
@sign << ["ZXCTN9000-8EA", "接口分捡"]
@sign << ["ZXCTN9000-8EA", "端口识别"]
@sign << ["ZXCTN9000-8EA", "端口MAC"]
@sign << ["ZXCTN9000-8EA", "端口管理状态"]
@sign << ["ZXCTN9000-8EA", "接口描述"]
@sign << ["ZXCTN9000-8EA", "接口地址"]
@sign << ["ZXCTN9000-8EA", "接口开关"]
@sign << ["ZXCTN9000-8EA", "接口vpn实例"]
@sign << ["ZXCTN9000-8EA", "聚合接口判定"]
@sign << ["ZXCTN9000-8EA", "聚合接口分捡"]
@sign << ["ZXCTN9000-8EA", "聚合逻辑接口"]
@sign << ["ZXCTN9000-8EA", "vlan分捡"]
@sign << ["ZXCTN9000-8EA", "vlan统计"]
@sign << ["ZXCTN9000-8EA", "端口去0"]
@sign << ["ZXCTN9000-8EA", "统计接口"]

module ZXCTN9000_8EA
  module_function
  #####################################################################################################
  # 接口/端口配置的基本查询
  # 接口集合 => 接口分检 => 物理接口集合,子接口集合,特殊接口集合

  # 主动模块:
  # firload
  # port-request-info
  # if-intf
  # port-physical-config
  # lacp
  # vlan
  # port-acl
  # lldp # 未实现
  # arp
  # nd
  # mpls
  # interface-performance
  # isis
  # multicast
  # ospfv2
  # ospfv3
  # qos # 未实现

  # 被动模块:(暂不关联)
  # samgr
  # monitor
  # alarm
  # ftp
  # ethernet-segment
  # icbg
  #####################################################################################################
  def 接口配置 正文
    接口表 = {}
    # these will be instancized!
    [self.接口物理信息(正文), self.接口基本信息(正文), self.接口vlan信息(正文), self.接口acl信息(正文),
     self.接口mpls信息(正文), self.接口isis信息(正文), self.接口multicast信息(正文), self.接口lacp信息(正文),
     self.接口firload信息(正文), self.接口port_request_info信息(正文), self.接口ospf信息(正文),
     self.接口arp信息(正文), self.接口nd信息(正文), self.接口interface_performance信息(正文), 
    #  self.接口urpf信息(正文), self.接口am信息(正文), self.接口uim信息(正文),
    ].each do|infolist|
      infolist.each do|intf,text|
        接口表[intf]||=[]
        接口表[intf] << text
      end
    end
    接口表
  end
  
  def 接口物理信息 正文
    tag = 正文["PORT-PHYSICAL-INFO"] ? "PORT-PHYSICAL-INFO" : "port-physical-config"
    接口物理表 = {}
    if tag == "PORT-PHYSICAL-INFO"
      (正文[tag]||"").split("\n!")\
            .collect{|l|"<#{tag}>\n"+l.strip+"\n!\n</#{tag}>" if l!=' '}\
            .compact.each{|接口|接口物理表[/interface (.)*/.match(接口)[0].to_s.strip] = 接口}
    elsif tag == "port-physical-config"
      (正文[tag]||"").split("\n$")\
            .collect{|l|"<#{tag}>\n"+l.strip+"\n!\n</#{tag}>" if l!="\n!"}\
            .compact.each{|接口|接口物理表[/interface (.)*/.match(接口)[0].to_s.strip] = 接口}      
    end
    接口物理表
  end
  
  def 接口基本信息 正文
    tag = 正文["INTERFACE"] ? "INTERFACE" : "if-intf"
    接口基本表 = {}
    if tag== "INTERFACE"
      (正文[tag]||"").split("\n!")\
            .collect{|l|"<#{tag}>\n"+l.strip+"\n!\n</#{tag}>" \
                        if l!=' ' && l.include?('interface')}\
            .compact.each{|接口|接口基本表[/interface (.)*/.match(接口)[0].to_s.strip] = 接口}
    elsif tag=="if-intf"
      (正文[tag]||"").split("\n$")\
            .collect{|l|"<#{tag}>\n"+l.strip+"\n!\n</#{tag}>" \
                        if l!=' ' && l.include?('interface')}\
            .compact.each{|接口|接口基本表[/interface (.)*/.match(接口)[0].to_s.strip] = 接口}
    end
    接口基本表
  end
  
  def 接口vlan信息 正文
    tag = 正文["VLAN"] ? "VLAN" : "vlan"
    接口vlan表 = {}
    if tag == "VLAN"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context.split("\n")[0]}\n","!\n</#{tag}>"
      fragments.each{|frag| 接口vlan表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    elsif tag == "vlan"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context.split("\n")[0]}\n","!\n</#{tag}>"
      fragments.each{|frag| 接口vlan表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口vlan表
  end

  def 接口acl信息 正文
    tag = 正文["PORT_ACL"] ? "PORT_ACL" : "port-acl"
    接口acl表 = {}
    if tag =="PORT_ACL"
      (正文[tag]||"").split("\n!")\
            .collect{|l|"<#{tag}>\n"+l.strip+"\n!\n</#{tag}>" if l!="\n!"}\
            .compact.each{|接口|接口acl表[/interface (.)*/.match(接口)[0].to_s.strip]=接口}
    elsif tag == "port-acl"
      (正文[tag]||"").split("\n$")\
            .collect{|l|"<#{tag}>\n"+l.strip+"\n!\n</#{tag}>" if l!="\n!"}\
            .compact.each{|接口|接口acl表[/interface (.)*/.match(接口)[0].to_s.strip]=接口}
    end
    接口acl表
  end
  
  def 接口mpls信息 正文
    tag = 正文["MPLS"] ? "MPLS" : "ldp"
    接口mpls表 = {}
    if tag=="MPLS"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..-3]}\n","!\n</#{tag}>" # context tail(!\n)
      fragments.each{|frag|接口mpls表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    elsif tag=="ldp"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..-3]}\n","!\n</#{tag}>" # context tail(!\n)
      fragments.each{|frag|接口mpls表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口mpls表
  end
  
  def 接口lacp信息 正文 # trunk
    tag = 正文["LACP"] ? "LACP" : "lacp"
    接口lacp表 = {}
    if tag=="LACP"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..3]}\n","$\n!</#{tag}>" # context tail(!\n)
      fragments.each{|frag|接口lacp表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    elsif tag=="lacp"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..3]}\n","$\n!</#{tag}>" # context tail(!\n)
      fragments.each{|frag|接口lacp表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口lacp表
  end

  def 接口isis信息 正文
    tag = 正文["ISIS"] ? "ISIS" : "isis"
    接口isis表 = {}
    if tag == "ISIS"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..-3]}\n","!\n</#{tag}>" # context tail(\n!)
      fragments.each{|frag|接口isis表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    elsif tag == "isis"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..-3]}\n","!\n</#{tag}>" # context tail(\n!)
      fragments.each{|frag|接口isis表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口isis表
  end
  
  def 接口multicast信息 正文
    tag = 正文["MULTICAST"] ? "MULTICAST" : "multicast"
    接口multicast表 = {}
    if tag == "MULTICAST"
      za,pimsm = TextAbstract.draw_fragments (正文[tag]||""), /^  router pimsm/, /^  \$/
      za,pimsm = TextAbstract.draw_fragments (正文[tag]||""), /^  router pim/, /^  \$/ unless pimsm[0]
      za,igmp= TextAbstract.draw_fragments (正文[tag]||""), /^  router igmp/, /^  \$/
      chead,ctail = "<#{tag}>\n#{za.split("\n")[0]}\n","!\n</#{tag}>" # common head
      # pimsm
      #begin
      context,fragments = TextAbstract.draw_fragments pimsm[0],/^    interface (.)*/, /^    \$/
      head,tail = context[0..-5],context[-4..-1] # open(...  $\n)
      fragments.each{|frag|接口multicast表[/interface (.)*/.match(frag)[0].to_s.strip] = chead+head+frag+tail+ctail}
      #rescue;end
      # igmp
      context,fragments = TextAbstract.draw_fragments igmp.join, /^    interface (.)*/, /^    \$/
      head,tail = context[0..-5],context[-4..-1] # open(...  $\n)
      fragments.each{|frag|接口multicast表[/interface (.)*/.match(frag)[0].to_s.strip] = chead+head+frag+tail+ctail}
    elsif tag == "multicast"
      za,pimsm = TextAbstract.draw_fragments (正文[tag]||""), /^  router pimsm/, /^  \$/
      za,pimsm = TextAbstract.draw_fragments (正文[tag]||""), /^  router pim/, /^  \$/ unless pimsm[0]
      za,igmp= TextAbstract.draw_fragments (正文[tag]||""), /^  router igmp/, /^  \$/
      chead,ctail = "<#{tag}>\n#{za.split("\n")[0]}\n","!\n</#{tag}>" # common head
      # pimsm
      #begin
      context,fragments = TextAbstract.draw_fragments pimsm[0].to_s, /^    interface (.)*/, /^    \$/
      head,tail = context[0..-5],context[-4..-1] # open(...  $\n)
      fragments.each{|frag|接口multicast表[/interface (.)*/.match(frag)[0].to_s.strip] = chead+head+frag+tail+ctail}
      #rescue;end
      # igmp
      context,fragments = TextAbstract.draw_fragments igmp.join, /^    interface (.)*/, /^    \$/
      head,tail = context[0..-5],context[-4..-1] # open(...  $\n)
      fragments.each{|frag|接口multicast表[/interface (.)*/.match(frag)[0].to_s.strip] = chead+head+frag+tail+ctail}
    end
    接口multicast表
  end

  def 接口firload信息 正文
    tag = 正文["firload"] ? "firload" : "firload"
    接口firload表 = {}
    if tag == "firload"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context.split("\n")[0]}\n","!\n</#{tag}>"
      fragments.each{|frag| 接口firload表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口firload表
  end

  def 接口port_request_info信息 正文
    tag = 正文["port-request-info"] ? "port-request-info" : "port-request-info"
    接口pri表 = {}
    if tag == "port-request-info"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^interface (.)*/, /^\n/
      head,tail = "<#{tag}>\n#{context.split("\n")[0]}\n","!\n</#{tag}>"
      fragments.each{|frag| 接口pri表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口pri表
  end

  def 接口arp信息 正文
    tag = 正文["arp"] ? "arp" : "arp"
    接口arp表 = {}
    if tag == "arp"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\narp\n#{context.split("\n")[0]}\n","!\n</#{tag}>"
      fragments.each{|frag| 接口arp表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口arp表
  end

  def 接口nd信息 正文
    tag = 正文["nd"] ? "nd" : "nd"
    接口nd表 = {}
    if tag == "nd"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^interface (.)*/, /^\$/
      head,tail = "<#{tag}>\n#{context.split("\n")[0]}\n","!\n</#{tag}>"
      fragments.each{|frag| 接口nd表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口nd表
  end

  def 接口interface_performance信息 正文
    tag = 正文["interface-performance"] ? "interface-performance" : "interface-performance"
    接口iperf表 = {}
    if tag == "interface-performance"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^interface (.)*/, /^\$/
      head,tail = "<#{tag}>\nintf-statistics\n#{context.split("\n")[0]}\n","!\n</#{tag}>"
      fragments.each{|frag| 接口iperf表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口iperf表
  end

  def 接口ospf信息 正文
    tag = 正文["ospfv2"] ? "ospfv2" : "ospfv2"
    接口ospfv2表 = {}
    if tag == "ospfv2"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^router ospf (.)*/, /^\!/
      paragraphs = TextAbstract.match_paragraph(context, /^router ospf (.)*/,/^\$/)
      paragraphs.each do|para|
        ospf = /^router ospf (.)*/.match(para)[0].to_s.strip
        areas = TextAbstract.match_paragraph(para, /^  area (.)*/, /^  \$/)
        areas.each do|area|
          area_id = /^  area (.)*/.match(area)[0].to_s.rstrip
          intfs = TextAbstract.match_paragraph(area, /^    interface (.)*/, /^    \$/)
          intfs.each{|intf| 接口ospfv2表['ospfv2+'+/interface (.)*/.match(intf)[0].to_s.strip] = "<#{tag}>\n#{ospf}\n#{area_id}\n#{intf}\n  $\n$\n!\n</#{tag}>"}
        end
      end
    end
    
    tag = 正文["ospfv3"] ? "ospfv3" : "ospfv3"
    接口ospfv3表 = {}
    if tag == "ospfv3"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^ipv6 router ospf (.)*/, /^\!/
      paragraphs = TextAbstract.match_paragraph(context, /^ipv6 router ospf (.)*/,/^\$/)
      paragraphs.each do|para|
        ospf = /^router ospf (.)*/.match(para)[0].to_s.strip
        areas = TextAbstract.match_paragraph(para, /^  area (.)*/, /^  \$/)
        areas.each do|area|
          area_id = /^  area (.)*/.match(area)[0].to_s.rstrip
          intfs = TextAbstract.match_paragraph(area, /^    interface (.)*/, /^    \$/)
          intfs.each{|intf| 接口ospfv3表['ospfv3+'+/interface (.)*/.match(intf)[0].to_s.strip] = "<#{tag}>\n#{ospf}\n#{area_id}\n#{intf}\n  $\n$\n!\n</#{tag}>"}
        end
      end
    end

    接口ospfv2表.merge(接口ospfv3表)
  end

  def 接口urpf信息 正文
    tag = 正文["URPF"] ? "URPF" : "urpf"
    接口urpf表 = {}
    if tag == "URPF"
      (正文[tag]||"").split("\n!")\
            .collect{|l|"<#{tag}>\n"+l.strip+"\n!\n</#{tag}>" if l!="\n!"}\
            .compact.each{|接口|接口urpf表[/interface (.)*/.match(接口)[0].to_s.strip]=接口}
     elsif tag == "urpf"
      (正文[tag]||"").split("\n$")\
            .collect{|l|"<#{tag}>\n"+l.strip+"\n!\n</#{tag}>" if l!="\n!"}\
            .compact.each{|接口|接口urpf表[/interface (.)*/.match(接口)[0].to_s.strip]=接口}
    end
    接口urpf表          
  end
  
  def 接口am信息 正文
    tag = 正文["AM"] ? "AM" : "am"
    接口am表 = {}
    if tag == "AM"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^    \$/
      head,tail = "<#{tag}>\n#{context[0..-3]}\n","!\n</#{tag}>" # context tail(!\n)
      fragments.each{|frag|接口am表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    elsif tag == "am"
      context,fragments = TextAbstract.draw_fragments (正文[tag]||""), /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..-3]}\n","!\n</#{tag}>" # context tail(!\n)
      fragments.each{|frag|接口am表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口am表
  end
  
  def 接口uim信息 正文
    tag = 正文["UIM"] ? "UIM" : "uim"
    接口uim表 = {}
    if tag =="UIM"
      za,vcc = TextAbstract.draw_fragments (正文[tag]||""), /^vcc\-configuration/, /^\!/
      za,vbui= TextAbstract.draw_fragments (正文[tag]||""), /^vbui\-configuration/, /^\!/
      # vcc
      context,fragments = TextAbstract.draw_fragments vcc.join, /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..-3]}","!\n</#{tag}>" # context tail(\n!\n)
      fragments.each{|frag|接口uim表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
      # vbui
      context,fragments = TextAbstract.draw_fragments vbui.join, /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..-3]}","!\n</#{tag}>" # context tail(\n!\n)
      fragments.each{|frag|接口uim表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    elsif tag =="uim"
      za,vcc = TextAbstract.draw_fragments (正文[tag]||""), /^vcc\-configuration/, /^\$/
      za,vbui= TextAbstract.draw_fragments (正文[tag]||""), /^vbui\-configuration/, /^\$/
      # vcc
      context,fragments = TextAbstract.draw_fragments vcc.join, /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..-3]}","!\n</#{tag}>" # context tail(\n!\n)
      fragments.each{|frag|接口uim表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
      # vbui
      context,fragments = TextAbstract.draw_fragments vbui.join, /^  interface (.)*/, /^  \$/
      head,tail = "<#{tag}>\n#{context[0..-3]}","!\n</#{tag}>" # context tail(\n!\n)
      fragments.each{|frag|接口uim表[/interface (.)*/.match(frag)[0].to_s.strip] = head+frag+tail}
    end
    接口uim表
  end

  # func: 端口应用QoS模板
  def 接口QoS 正文
    # QoS有一部分在流策略,这里只解析car限速
    tag = 正文["CAR"] ? 'CAR' : 'car'
    cars = {};current = nil; cars[current] = {}
    lines = 正文[tag].to_s.split("\n")
    lines.each_with_index do|line, index|
      if line.include?('interface')
        current = line.split('interface ').last
        cars[current] ||= {}
      end
      if line.include?('rate-limit ')
        if line.size==80 && lines[index+1][0..1]!='  '
          words = (line+lines[index+1]).split(" ")
        else
          words = line.split(" ")
        end
        cars[current]['direction'] = words[words.index('rate-limit')+1]
        cars[current]['cir']       = words.index('cir') ? words[(words.index('cir')+1)..(words.index('cir')+2)].join : ''
        cars[current]['pir']       = words.index('pir') ? words[(words.index('pir')+1)..(words.index('pir')+2)].join : ''
        cars[current]['cbs']       = words.index('cbs') ? words[words.index('cbs')+1]+'bytes' : ''
        cars[current]['pbs']       = words.index('pbs') ? words[words.index('pbs')+1]+'bytes' : ''
        cars[current]['action']    = [
          words.index('conform-action') ? words[words.index('conform-action')+1] : '', 
          words.index('exceed-action')  ? words[words.index('exceed-action')+1] : '', 
          words.index('violate-action') ? words[words.index('violate-action')+1] : ''
        ]
      end
    end
    cars.delete(nil)
    cars
  end

  # func: 端口应用流量模板
  def 接口流策略 正文
    tag = 正文["hqos"] ? 'hqos' : 'hqos'
    svc_policy = {}
    lines = 正文[tag].to_s.split("\n")
    lines.each_with_index do|line, index|
      if line.include?('service-policy')
        words = line.split(' ')
        interface = words[words.index('service-policy')+1]
        direction = words[words.index('service-policy')+2]
        template  = words[words.index('service-policy')+3]
        svc_policy[interface] ||= {}
        svc_policy[interface][direction] = template
      end
    end
    svc_policy
  end
  
  # func: 端口统计功能
  def 接口统计 正文
    tag = 正文["interface-performance"] ? 'interface-performance' : 'interface-performance'
    intf_perf = {}; current = nil; intf_perf[current] = {}
    lines = 正文[tag].to_s.split("\n")
    lines.each_with_index do|line, index|
      if line.include?('interface-performance')
        current = line.split('interface ').last
      end
      if line.include?('traffic-statistics enable')
        intf_perf[current] = :statistic_enable
      end
    end
    intf_perf.delete(nil)
    intf_perf
  end
  
  # func: 端口URPF功能
  def 接口URPF 正文
    接口urpf表 = self.接口urpf信息 正文
    urpf = {}
    接口urpf表.each do|intf, conf|
      words = conf.split(' ')
      addr = words.join.include?('ipv4') ? 'ipv4' : 'ipv6'
      mode = words[words.index('reachable-via')+1]=='any' ? 'loose' : 'strict'
      acl  = words.index('acl-name') ? words[words.index('acl-name')+1] : 'none'
      ignr = words.include?('ignore-default-route') ? 'ignore-default-route' : 'none'
      urpf[intf.split(' ').last] = {'addr'=>addr, 'mode'=>mode, 'acl'=>acl, 'ignore'=>ignr}
    end
    urpf
  end
  
  # func: 端口接入类型
  def 接口接入类型 正文
    接口uim表 = self.接口uim信息 正文
    access_type = {}
    接口uim表.each do|intf, conf|
      type = conf.include?('ip-access-type') ? conf.split('ip-access-type ').last.split("\n").first : nil
      access_type[intf.split(' ').last] = type if type
    end
    access_type
  end

  def 特殊接口配置 接口集合
    特殊接口集合 = []
    接口集合.each do|key,configs|
      特殊接口集合 << [key]+configs if key.include?('loopback') || key.include?('null') || \
        key.include?('extimer') || key.include?('vbui') || key.include?('spi') || \
        key.include?('gcvi') || key.include?('guvi') || key.include?('mgmt_eth') || \
        key.include?('qx_eth') || key.include?('qx') || key.include?('gre_tunnel')
    end
    特殊接口集合
  end
  
  def 物理接口配置 接口集合,特殊接口集合=nil
    物理接口集合 = []
    例外 = (特殊接口集合 ? 特殊接口集合 : (self.特殊接口配置 接口集合)).collect{|c|c[0]}
    接口集合.each do|key,configs|
      物理接口集合 << [key]+configs unless 例外.include?(key) || key.include?('.')
    end
    物理接口集合
  end
  
  def 子接口配置 接口集合,特殊接口集合=nil
    子接口集合 = []
    例外 = (特殊接口集合 ? 特殊接口集合 : (self.特殊接口配置 接口集合)).collect{|c|c[0]}
    接口集合.each do|key,configs|
      子接口集合 << [key]+configs if !例外.include?(key) && key.include?('.')
    end
    子接口集合
  end
  
  def 接口分捡 接口集合
    特殊接口集合 = self.特殊接口配置 接口集合
    物理接口集合 = self.物理接口配置 接口集合,特殊接口集合
    子接口集合 = self.子接口配置 接口集合,特殊接口集合
    return 物理接口集合,子接口集合,特殊接口集合
  end


  #####################################################################################################
  # 端口描述信息相关
  #####################################################################################################

  # func: 根据一个端口的描述信息，给出其格式化的类型、连接符、端口编号
  def 端口识别 描述
    描述 = 描述[0] if 描述.instance_of?(Array) # M6000取接口配置中名称部分 [name,<tag>...</tag>,...]
    type = /xgei|gei|ulei|smartgroup|loopback|extimer|vbui|null|guvi|gcvi|mgmt_eth|vei|spi|flexe_client|flexe_group|ptp|gps|qx_eth|qx|bvi|pw|subvlan/.match(描述)
    类型 = type ? type.to_s : '未知类型'
    port = /(\d+|\/|\.)*(\d+)/.match(描述.split(类型).join)
    端口 = port ? port.to_s : '未知端口'
    端口 = '' if 类型=='mgmt_eth'
    连接符 = if ['smartgroup','loopback','vbui','null','mgmt_eth','vei','flexe_client','flexe_group','qx','bvi','pw','subvlan'].include?(类型)
      '' 
    elsif ['xgei','gei','ulei','extimer','guvi','gcvi','spi','ptp','gps','qx_eth'].include?(类型)
      '-'
    end
    return 类型,连接符,端口
  end
  
  # func: 根据一个端口的描述信息，给出其mac地址，若无mac则返回nil
  def 端口MAC 描述
    描述.each_line do|line|
      if pattern = /\, address is (.+)/.match(line)
        matcher = /[\d|A-F|a-f]+\.[\d|A-F|a-f]+\.[\d|A-F|a-f]+/.match(pattern[1].strip)
        return pattern[1].strip if matcher.to_s==pattern[1].strip
      end
    end
    return nil
  end
  
  # func: 根据一个端口的描述信息，给出其管理状态是打开/关闭的判断
  def 端口管理状态 描述
    描述 = 描述[1..-1].join("\n") if 描述.instance_of?(Array) # M6000取接口配置中名称部分 [name,<tag>...</tag>,...]
    管理状态 = true
    描述.split("\n").each do|line|
      管理状态 = false if line.include?("shutdown") && !line.include?("no shutdown")
    end
    管理状态
  end

  # func: 根据一个端口的配置给出其描述
  def 接口描述 接口配置
    描述 = ''
    接口配置.join("\n").each_line do|line| if line.strip[0..10]=='description'
      描述 = line.split('description')[1..-1].join().strip; break
    end end
    描述.to_s
  end

  # func: 根据一个端口的配置给出其配置的接口地址
  def 接口地址 接口配置
    地址集 = []
    接口配置.join("\n").each_line do|line|
      if line.strip[0..9]=='ip address'
        地址集 << line.gsub('secondary','').split('ip address')[-1].strip.split(' ')
      end
      if line.strip[0..11]=='ipv6 address'
        地址集 << line.gsub('secondary','').split('ipv6 address')[-1].strip.split('/')
      end
    end
    地址集
  end
  
  # func: 根据一个端口的配置给出其开关状态（配置层面的"端口管理状态"）
  def 接口开关 接口配置
    描述 = '' # for phy_if is shutdown, for sub_if,smartgroup are open
    接口配置.join("\n").each_line do|line|
      if line.include?("no shutdown") and !line.include?('description')
        描述 = 'no shutdown'; break
      end
      if line.include?("smartgroup")
        描述 = 'no shutdown'; break
      end
      if line.include?("shutdown") and !line.include?('no') and !line.include?('description')
        描述 = 'shutdown'; break
      end
    end
    描述
  end
  
  # func: 根据一个端口的配置给出其关联的vpn实例
  def 接口vpn实例 接口配置
    实例 = ''
    接口配置.join("\n").each_line do|line|
      实例 = "vpn-inst:" + /vrf forwarding .+/.match(line).to_s.split(" ")[-1] if /vrf forwarding .+/.match(line)
    end
    实例
  end


  #####################################################################################################
  # 聚合接口判定相关
  #####################################################################################################
  
  # func: 根据一个接口的描述信息，给出其所属聚合接口的信息，若非聚合端口返回空
  def 聚合接口判定 配置
    配置.join.split("\n").each do|描述|
      if 描述.include?("smartgroup") && 描述.include?("mode") && 
         !描述.include?("description") && !self.端口识别(配置).join.include?("smartgroup")
        return {self.端口识别(配置).join=>"smartgroup"+描述.strip.split(" ")[1]}
      end
    end;{}
  end

  # func: 给出聚合接口和物理接口的集合，通过计算找出所有聚合接口的集合
  def 聚合接口分捡 聚合接口,物理接口集合
    聚合接口 = self.端口识别(聚合接口)
    聚合接口集合 = [聚合接口.join]
    物理接口集合.each do|物理接口| 物理接口.join.each_line do|line|
      if line.include?("smartgroup") && !line.include?("description")
        aggrnum = line.strip.split(" ")[1]
        聚合接口集合 << self.端口识别(物理接口).join if ['smartgroup','',aggrnum].join==聚合接口.join
      end
    end end
    聚合接口集合
  end

  # func: 根据一个接口的描述信息，给出其所属聚合接口的逻辑接口，若无返回空
  def 聚合逻辑接口 配置
    配置.join.split("\n").each do|描述|
      if 描述.include?("nas logic-interface")
        num = 描述.split(" ")
        return [num[-5],num[-3],num[-1]].join('/')
      end
    end
    return nil
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
    vlan_part = 接口配置.find{|配置|(配置.include?("<VLAN>")&&配置.include?("</VLAN>")) || (配置.include?("<vlan>")&&配置.include?("</vlan>"))} || ""
    vlan_part.each_line do|line| next if line.include?('no')
      if pattern = /encapsulation-dot1q range (.+)/.match(line)
        dot1q = eval(pattern[1].to_s.gsub('-','..')) # Range or Integer
        vlan['dot1q'] ||= [];vlan['dot1q'] << dot1q;next
      end
      if pattern = /encapsulation-dot1q (\d+)/.match(line)
        dot1q = eval(pattern[1].to_s)
        vlan['dot1q'] ||= [];vlan['dot1q'] << dot1q;next
      end
      if pattern = /qinq range internal-vlan-range (.+) external-vlan-range (.+)/.match(line)
        vlan['qinq'] ||= []
        exvlan = eval(pattern[2].to_s.gsub('-','..')) # Range or Integer
        invlan = eval(pattern[1].to_s.gsub('-','..'))
        if exvlan.instance_of?(Range)
          exvlan.each{|exv|vlan['qinq'] << [exv,invlan]}
        elsif exvlan.instance_of?(Fixnum)
          vlan['qinq'] << [exvlan,invlan]
        end;next
      end
      if pattern = /qinq internal-vlanid (\d+) external-vlanid (\d+)/.match(line)
        qinq = [pattern[2].to_i,pattern[1].to_i]
        vlan['qinq'] ||= [];vlan['qinq'] << qinq;next
      end
    end
    return vlan # {vlan:[ int|range ] qinq:[ [int,int|range] ] dot1q:[ int ]}
  end
  
  def vlan统计 name,物理接口集合,子接口集合
    bas子接口数据库,聚合接口表 = {},[]
    聚合接口集合 = 物理接口集合.select{|物理接口|self.端口识别(物理接口)[0]=='smartgroup'}
    聚合接口表 += 聚合接口集合.collect{|聚合接口|self.聚合接口分捡(聚合接口,物理接口集合)}

    子接口集合.each do|接口配置|
      物理接口名称 = self.端口识别(接口配置).join.split(".")[0]
      物理接口 = 物理接口集合.find{|物理接口|物理接口[0].split(" ")[1]==(物理接口名称)}
      next unless self.端口管理状态(物理接口) # 物理接口关闭的不统计
      next unless self.端口管理状态(接口配置) # 子接口关闭的不统计
      
      vlan配置 = {}
      self.vlan分捡(接口配置).each do|type,data|
        if type=='vlan' || type=='dot1q'
          vlan配置[4096] ||= []; vlan配置[4096] += data # 用4096表示单层vlan
        elsif type=='qinq'
          data.each{|pvlan,cvlan|vlan配置[pvlan] ||= []; vlan配置[pvlan] << cvlan}
        end
      end
      
      子接口名称 = self.端口识别(接口配置)
      if 子接口名称[0].include?("gei")
        # 子接口索引 = ["eth--"+子接口名称[-1].split(".")[0].split('/')[-3..-1].join(',')] # AIBOS风格
        子接口索引 = [子接口名称.join.split(".")[0]] # 原生风格
      end
      if 子接口名称[0].include?("smartgroup") && 
        聚合接口组 = 聚合接口表.find{|聚合接口组|聚合接口组.include?(子接口名称.join.split('.')[0])}
        聚合接口的等效名称 = 聚合接口组.clone;
        # 聚合接口的等效名称.delete(子接口名称.join.split('.')[0]) # 除了smartgroup自身，为所有等效接口创建  # 是否保留smartgroup是个争议
        子接口索引 = 聚合接口的等效名称.map do|等效名称|
          # "eth--"+self.端口识别(等效名称)[-1].split(".")[0].split('/')[-3..-1].join(',') # AIBOS风格
          self.端口识别(等效名称).join.split(".")[0] # 原生风格
        end
        # 子接口索引 << "trunk--"+[255,0,子接口名称[2].split('.')[0]].join(',') # AIBOS风格
        子接口索引 << 子接口名称.join.split(".")[0] # 原生风格
      end

      bas子接口数据库[name] ||= {}
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
  
  # gei-x/x/x.00000xxx => gei-x/x/x.xxx
  # 一些统计场合子接口会补前置0，这里可以将其去掉
  def 端口去0 描述
    if 描述.include?("00") && 描述.include?('.')
      接口,子接口 = 描述.split(".")
      [接口,子接口.to_i.to_s].join(".")
    else
      描述
    end
  end

  # 针对show intf-statistics utilization phy-interface-only
  def 统计接口 文本
    文本.split("\n").inject([]) do|表格, 行|
      表格 << 行.split(" ") if 行.include?("gei-") or 行.include?("smartgroup") or 行.include?("spi-")
      表格 # [interface, in-bps, in-uti, out-bps, out-uti, in-errors, in-dbm, out-dbm]
    end
  end
end
```