
# Alcatel7750 IF #ALT

```ruby
@sign << ['Nokia7750', '接口关联']
@sign << ['Nokia7750', '接口配置']
@sign << ['Nokia7750', '接口分捡']
@sign << ['Nokia7750', '端口识别']
@sign << ['Nokia7750', '接口地址']
@sign << ['Nokia7750', '接口描述']
@sign << ['Nokia7750', '接口vpn实例']
@sign << ['Nokia7750', '接口开关']
@sign << ['Nokia7750', '接口QoS']
@sign << ['Nokia7750', '接口流策略']

module Nokia7750
    module_function

    def extract_token(str)
      if str =~ /"([^"\\]*(?:\\.[^"\\]*)*)"/
        $1
      else
        str.strip.split(/\s+/).first
      end
    end

    def 接口关联 正文
      # ies
      #  +----> name        as ies-id
      #  +----> description as ies-desc
      #  +----> interface -----> name as port-desc
      #  |          +----------> sap  as port-name
      #  |          +----------> address
      #  +----> subscriber-interface ----------> name as port-desc-part1
      #             +--------------------------> address ※ shared by all group-interface
      #             +----> group-interface ----> name as port-desc-part2
      #                          +-------------> sap  as port-name # if exist is a interface, else is a pool
      # vprn
      #  +----> name as vrf-name
      #  +----> rd
      #  +----> rt-in rt-out
      #  +----> interface
      #             +--------> name as port-desc
      #             +--------> sap  as port-name
      #             +--------> address
      #
      # port-name (ies-id)ies-name ies-desc/port-desc address
      # port-name (ies-id)ies-name ies-desc/port-desc1 port-desc2 address
      # port-name (rd)vrf-name/port-desc address

      intfs = []; subintfs = []; abpools = []
      iess = 正文['Service Configuration'].join("\n").match_paragraph("        ies ","\n        exit")
      iess.each do|ies|
        # ies basic info
        ies_abs = ies.split("\n").first
        ies_id = ies_abs.split(" ").first
        if ies_abs.include?('name')
          ies_name = extract_token(ies_abs.split('name ').last)
        end
        if ies_abs.include?('customer')
          ies_custom = extract_token(ies_abs.split('customer ').last)
        end
        ies_desc = ies.split("\n").find{|line|line.include?('description')}.to_s.split("description ").last.to_s[1..-2].to_s

        # interface info
        ifs = ies.match_paragraph("\n            interface ","\n            exit")
        ifs.each do|intf|
          if_name = extract_token(intf.split("\n").first.strip) # as port-desc
          addresses = []
          intf.split("\n").each do|line|
            addresses << line.split("address").last.strip if line.include?(" address ")
          end
          if_sap  = intf.split("\n").find{|g|g.include?("sap ")}.to_s.split("sap ").last.to_s.split(" ").first
          if if_sap
            intfs << [if_sap, ["ies:#{ies_id}", "ies:#{ies_name}", ies_desc, if_name], addresses ]
          end
        end
        
        # subscriber-interface info
        subifs = ies.match_paragraph("\n            subscriber-interface ","\n            exit")
        subifs.each do|subif|
          subif_name = extract_token(subif.split("\n").first.strip) # as port-desc-p1

          addresses = []
          subif.split("\n").each do|line|
            addresses << line.split("address").last.strip if line.include?(" address ")
          end

          groupifs = subif.match_paragraph("\n                group-interface ","\n                exit")
          groupifs.each do|groupif|
            group_name = extract_token(groupif.split("\n").first.strip) # as port-desc-p2
            group_sap  = groupif.split("\n").find{|g|g.include?("sap ")}.to_s.split("sap ").last.to_s.split(" ").first # as port-name

            if group_sap
              subintfs << [group_sap, ["ies:#{ies_id}", "ies:#{ies_name}", ies_desc, subif_name, group_name], addresses] 
              abpools << [group_sap, ["ies:#{ies_id}", "ies:#{ies_name}", ies_desc, subif_name, group_name], addresses] 
            else
              abpools << [group_sap, ["ies:#{ies_id}", "ies:#{ies_name}", ies_desc, subif_name, group_name], addresses] 
            end
          end
        end
      end
      
      vpn_apply = []
      vpns = 正文['Service Configuration'].join("\n").match_paragraph("\n        vprn ","\n        exit")
      vpns.each do|vpn|
        vpn_abs = vpn.split("\n").first
        vpn_id = vpn_abs.split(" ").first
        if vpn_abs.include?('name')
          vpn_name = extract_token(vpn_abs.split('name ').last)
        end
        if vpn_abs.include?('customer')
          vpn_custom = extract_token(vpn_abs.split('customer ').last)
        end
        vpn_desc = vpn.split("\n").find{|line|line.include?('description')}.to_s.split("description ").last.to_s[1..-2].to_s

        vpn_as = vpn.split("\n").find{|line|line.include?('autonomous-system')}.to_s.split("autonomous-system ").last.to_s
        vpn_rd = vpn.split("\n").find{|line|line.include?('route-distinguisher')}.to_s.split("route-distinguisher ").last.to_s
        vpn_tag_in = vpn.split("\n").find{|line|line.include?('vrf-target')}.to_s.split("vrf-target ").last.to_s.split("target:").last.to_s
        vpn_tag_out = vpn.split("\n").find{|line|line.include?('vrf-target')}.to_s.split("vrf-target ").last.to_s.split("target:").last.to_s
        vpn_tag_in = vpn.split("\n").find{|line|line.include?('vrf-import')}.to_s.split("vrf-import ").last.to_s[1..-2].to_s
        vpn_tag_out = vpn.split("\n").find{|line|line.include?('vrf-export')}.to_s.split("vrf-export ").last.to_s[1..-2].to_s

        # interface info
        ifs = vpn.match_paragraph("\n            interface ","\n            exit")
        ifs.each do|intf|
          if_name = extract_token(intf.split("\n").first.strip) # as port-desc
          addresses = []
          intf.split("\n").each do|line|
            addresses << line.split("address").last.strip if line.include?(" address ")
          end
          if_sap  = intf.split("\n").find{|g|g.include?("sap ")}.to_s.split("sap ").last.to_s.split(" ").first
          if if_sap
            intfs << [if_sap, ["vprn:#{vpn_id}", "vprn:#{vpn_name}", vpn_desc, if_name], addresses]
            vpn_apply << [if_sap, [vpn_id, vpn_name, vpn_desc, if_name], [vpn_as, vpn_rd,vpn_tag_in, vpn_tag_out], addresses]
          else
            vpn_apply << [if_sap, [vpn_id, vpn_name, vpn_desc, if_name], [vpn_as, vpn_rd,vpn_tag_in, vpn_tag_out], addresses]
          end
        end
      end

      return intfs, subintfs, abpools, vpn_apply
    end

    def 接口配置 正文
      ports = []
      basics = 正文['Port Configuration'].join("\n").match_paragraph("\n    port","\n    exit").map{|port|"port "+port}
      basics.each do|basic|
          类型,连接符,端口 = self.端口识别 basic
          ports << [端口, basic]
      end
      networks = 正文['Router (Network Side) Configuration'].join("\n").match_paragraph("\n        interface ","\n        exit").map{|port|"interface "+port}
      networks.each do|network|
          端口 = network.split("\n").select{|line|line.include?("port ")}.map{|line|line.split("port ").last}.join
          if port = ports.find{|port|port==端口}
            ports.index(port)
            ports[index] << network
          else
            端口 = network.split("\n").select{|line|line.include?("interface ")}.map{|line|line.split("interface ")[1..-1].join(' ')}.join
            ports << [端口, network]
          end
      end
      return ports
    end

    def 接口分捡 接口集合
        return 接口集合,[],[]
    end

    def 端口识别 接口配置
        描述 = 接口配置.is_a?(Array) ? 接口配置[1..-1].join("\n") : 接口配置
        连接符 = ' '
        类型 = 'Port'
        port = /(\w+|\-|\_|\d+|\/|\:|\s+)+/.match(描述.split("\n").first.split(" ")[1..-1].join(' '))
        端口 = port ? port.to_s : '未知端口'
        return 类型,连接符,端口
    end

    def 接口地址 接口配置
        地址集 = []
        接口配置.join("\n").each_line do|line|
          if line.strip[0..6]=='address'
            地址集 << line.split('address')[-1].strip.split('/')
          end
        end
        地址集
    end

    def 接口描述 接口配置
        描述 = ''
        接口配置.join("\n").each_line do|line| if line.strip[0..10]=='description'
          描述 = line.split('description')[-1].strip; break
        end end
        描述.to_s[1..-2]
    end

    def 接口vpn实例 接口配置
    end

    def 接口开关 接口配置
    end

    def 接口QoS 接口配置

    end

    def 接口流策略 接口配置
    end
end
```
