# CX600-X16A VPN

```ruby
@sign << ['CX600-X16A', 'vpn_instance']
@sign << ['CX600-X16A', 'evpn_instance']
@sign << ['CX600-X16A', 'bridge_domain']
@sign << ['CX600-X16A', 'if_bridge_domain']

module CX600_X16A
  module_function

  def vpn_instance conf
    doc = {}
    vpn_family = 'ipv4-family'
    conf.split("\n").each do|line|
      doc['vpn-name'] = line.split('vpn-instance ').last.strip if line.include?('ip') && line.include?('vpn-instance')
      vpn_family = 'ipv4-family' if line.include?('ipv4-family')
      vpn_family = 'ipv6-family' if line.include?('ipv6-family')
      doc[vpn_family] ||= {}
      doc[vpn_family]['route-distinguisher'] = line.split('route-distinguisher ').last.strip if line.include?('route-distinguisher')
      if line.include?('vpn-target')
        family = line.include?('evpn') ? 'evpn' : vpn_family.split('-').first
        direction = 'export' if line.include?('export')
        direction = 'import' if line.include?('import')
        words = line.split('vpn-target ').last.split(' ')
        target = words.select{|w|!w.include?('community') && !w.include?('evpn') && !w.strip.empty?}.map{|w|w.strip}
        doc[vpn_family][family] ||= {}
        doc[vpn_family][family][direction] ||= [] 
        doc[vpn_family][family][direction] += target
      end
    end
    return doc
  end

  def evpn_instance conf
    doc = {}
    conf.split("\n").each do|line|
      doc['vpn-name'] = line.split('vpn-instance ')[-1].split(' ').first.strip if line.include?('evpn') && line.include?('vpn-instance')
      doc['mode'] = 'bd-mode' if line.include?('bd-mode') && line.include?('vpn-instance')
      doc['route-distinguisher'] = line.split('route-distinguisher ').last.strip if line.include?('route-distinguisher')
      if line.include?('segment-routing')
        doc['segment-routing'] ||= {}
        family = line.include?('ipv6') ? 'ipv6-family' : 'ipv4-family'
        doc['segment-routing'][family] ||= {}
        doc['segment-routing'][family]['mode'] = 'best-effort' if line.include?('best-effort')
        doc['segment-routing'][family]['locator'] = line.split('locator ').last.strip if line.include?('locator')
      end
      if line.include?('vpn-target')
        direction = 'export' if line.include?('export')
        direction = 'import' if line.include?('import')
        words = line.split('vpn-target ').last.split(' ')
        target = words.select{|w|!w.include?('community') && !w.include?('evpn') && !w.strip.empty?}.map{|w|w.strip}
        doc['vpn-target'] ||= {}
        doc['vpn-target'][direction] ||= [] 
        doc['vpn-target'][direction] += target
      end
    end
    return doc
  end

  def bridge_domain bdconf
    bd = {}
    bdconf.split("\n").each do|line|
      bd['bridge-domain'] = line.split(' ').last.strip if line.include?('bridge-domain')
      bd['statistic'] = 'enable' if line.include?('statistic enable')
      bd['evpn-instance'] = line.split("vpn-instance").last.strip if line.include?('vpn-instance')
    end
    return bd
  end

  def if_bridge_domain ifconf
    ifconf.split("\n").each do|line|
      return line.split(' ').last.strip if line.include?('bridge-domain')
    end
    return nil
  end
end
```