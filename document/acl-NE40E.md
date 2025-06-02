
# NE40E 访问控制列表

```ruby
@sign << ['NE40E', 'ACL']
@sign << ['NE40E', 'resort']
@sign << ['NE40E', 'detect_adv']
@sign << ['NE40E', 'gen_rule']

module NE40E
  module_function

  def ACL config
    table = {}
    number = nil
    config.split("\n").each do|line|
      number = line.split('number')[1].strip.to_i if line.include?('acl number') or line.include?('acl ipv6 number')
      table[number] ||= {}
      if line.include?('rule')
        rule = line.split(' ')
        table[number][rule[1].to_i] = rule[2..-1]
      end
    end
    table.delete(nil)
    return table
  end

  # 重排ACL序号，只对纯文本编排，注意最末行
  def resort text, index # {[old,old]=>new}
    packs,newlist = {},[]
    index.each do|is,ni| packs[ni] = [] end
    text.split("\n").each do|line|
      items = line.split(' ')
      id = items[1].to_i
      index.each do|is,ni|
        packs[ni] << items[2..-1].join(' ') if (is[0]..is[1]).include?(id)
      end
      newlist << "undo rule #{id}"
    end
    packs.each do|ni,pack|
      pack.sort.each_with_index do|rule, si|
        newlist << "rule #{ni.to_i+si.to_i} #{rule}"
      end
    end
    return newlist.join("\n")
  end

  # INTEGER<1000-1999>    Interface access-list(add to current using rules)
  # INTEGER<10000-10999>  MPLS access list (add to current using rules)
  # INTEGER<2000-2999>    Basic access-list(add to current using rules)
  # INTEGER<3000-3999>    Advanced access-list(add to current using rules)
  # INTEGER<4000-4999>    Specify a L2 ACL group(add to current using rules)
  # ip-pool               Specify IP pool configuration
  # ipv6                  ACL IPv6
  # name                  Specify a named ACL
  # number                Specify a numbered ACL

  PORTS = {
    137 => 'netbios-ns',
    138 => 'netbios-dgm',
    139 => 'netbios-ssn',
    19 => 'CHARgen',
    179 => 'bgp',
    514 => 'cmd',
    13 => 'daytime',
    9 => 'discard',
    53 => 'domain',
    7 => 'echo',
    512 => 'exec',
    79 => 'finger',
    21 => 'ftp',
    20 => 'ftp-data',
    70 => 'gopher',
    101 => 'hostname',
    194 => 'irc',
    543 => 'klogin',
    544 => 'kshell',
    513 => 'login',
    515 => 'lpd',
    119 => 'nntp',
    109 => 'pop2',
    110 => 'pop3',
    25 => 'smtp',
    111 => 'sunrpc',
    49 => 'tacacs',
    517 => 'talk',
    23 => 'telnet',
    37 => 'time',
    540 => 'uucp',
    43 => 'whois',
    80 => 'www'
  }

  # acl-adv rule
  def detect_adv rule,index=nil
    words = rule.instance_of?(String) ? rule.split(' ') : rule # text or array
    # words: <action> <protocol> [<src>] [<dst>] [<tail>]
    # <src> := [ source <sip> <smk> ] [ source-port [[eq|gt|lt <spt>]|[range <spt1> <spt2>]] ]
    # <dst> := [ destination <dip> <dmk>] [ destination-port [[eq|gt|lt <dpt>]|[range <dpt1> <dpt2>]] ]
    # <tail> := "PENDING"
    ritle = {}
    ritle['index'] = index if index
    action,protocol = words[0..1]
    ritle['action'] = action
    ritle['protocol'] = protocol
    ['source','destination'].each do|edge|
      if words.include?(edge)
        edge_ip = words[words.index(edge)+1]
        unless edge_ip=='any'
          if edge_ip.include?(':')
            start_ip, ei_amask = IP.v6(edge_ip)
          else
            ei_amask_str = words[words.index(edge)+2]
            ei_amask_str = '0.0.0.0' if ei_amask_str == '0'
            start_ip,ei_amask = IP.v4(edge_ip),IP.v4(ei_amask_str)
          end
          end_ip = start_ip.clone + ei_amask.number
          ritle[edge] = [start_ip.to_s, end_ip.to_s]
        end
      end
    end
    ['source-port', 'destination-port'].each do|port|
      if words.include?(port)
        op = words[words.index(port)+1]
        range = case op
        when 'range'
          a, b = words[words.index(port)+2], words[words.index(port)+3]
          a = PORTS.key(a) ? PORTS.key(a) : a.to_i
          b = PORTS.key(b) ? PORTS.key(b) : b.to_i
          [ a, b ]
        when 'lt'
          a = words[words.index(port)+2]
          a = PORTS.key(a) ? PORTS.key(a) : a.to_i
          [ 0, a ]
        when 'gt'
          a = words[words.index(port)+2]
          a = PORTS.key(a) ? PORTS.key(a) : a.to_i
          [ 65535, a ]
        when 'eq'
          a = words[words.index(port)+2]
          a = PORTS.key(a) ? PORTS.key(a) : a.to_i
          [ a, a ]
        end.sort
        ritle[port] = range
      end
    end
    # TODO: tail
    return ritle
  end

  # 查询规则1#
  def in_range? ritle, target
    tip = IP.v4(target[:ip])
    tnum = tip.number
    if ritle["destination"] && ritle["destination-port"]
      si,ei = ritle["destination"].map{|i|IP.v4(i).number}
      sp,ep = ritle["destination-port"]
      return ritle if (si..ei).include?(tnum) && (sp..ep).include?(target[:port]) && ritle['action']==target[:action]
    end
    return nil
  end

  # 查询规则2#
  def list_in_range? list, target
    tip = IP.v4(target[:ip])
    tnum = tip.number
    set = []
    list.each do|ritle|
      if ritle["destination"] && ritle["destination-port"]
        si,ei = ritle["destination"].map{|i|IP.v4(i).number}
        sp,ep = ritle["destination-port"]
        set << ritle if (si..ei).include?(tnum) && (sp..ep).include?(target[:port]) && ritle['action']==target[:action]
      end
    end
    return set
  end

  # 生成规则：
  # options = {
  #   index: 107,
  #   action: 'deny',
  #   protocol: 'tcp',
  #   sip: '1.1.1.1',
  #   sport: 80,
  #   dip: '2.2.2.2',
  #   dport: 443
  # }
  def gen_rule options
    rule = ['rule']
    return {'conf-error'=>"缺少必要参数:规则索引"} unless options[:index]
    return {'conf-error'=>"缺少必要参数:动作"}     unless options[:action]
    return {'conf-error'=>"缺少必要参数:协议"}     unless options[:protocol]
    return {'runtime-error'=>"规则空位不足"}      if options[:index]=='no slot'
    rule << options[:index]
    rule << options[:action]
    rule << options[:protocol]
    options[:sip]   and rule << "source #{options[:sip]}"
    options[:sport] and rule << "source-port eq #{options[:sport]}"
    options[:dip]   and rule << "destination #{options[:dip]}"
    options[:dport] and rule << "destination-port eq #{options[:dport]}"
    return {"operation"=>rule.join(" ")}
  end
end
```