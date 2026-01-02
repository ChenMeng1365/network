# ZXCTN9000-8EA VPN

```ruby
@sign << ['ZXCTN9000-8EA', 'l2vpn']
@sign << ['ZXCTN9000-8EA', 'vpls']
@sign << ['ZXCTN9000-8EA', 'vpls_if']

module ZXCTN9000_8EA
  module_function

  def l2vpn conf
    content = (conf['l2vpn'] || "")
    instances = TextAbstract.match_paragraph(content, "\nvpls ", "\n$").map{|t|"vpls "+t+"\n$"}
    return instances
  end

  def vpls conf
    doc = {};mode = nil
    conf.split("\n").each do|line|
      doc['vpn-name'] = line.split('vpls ').last.split(' ').first.strip if line.include?('vpls ')
      doc['mode'] = line.include?('vpls ') && line.include?('evpn') ? 'vpls-evpn' : 'vpls'
      doc['rd'] = line.split('rd ').last.strip if line.include?(' rd ')
      if line.include?('auto-discovery')
        mode = line.split('auto-discovery ').last.strip
        doc['auto-discovery'] = mode
      end
      if line.include?('route-target')
        direction = 'export' if line.include?('export')
        direction = 'import' if line.include?('import')
        words = line.split('route-target ').last.split(' ')
        target = words.select{|w|!w.include?('route-target') && !w.include?('port') && !w.strip.empty?}.map{|w|w.strip}
        if mode
          doc[mode] ||= {}
          doc[mode]['route-target'] ||= {}
          doc[mode]['route-target'][direction] ||= [] 
          doc[mode]['route-target'][direction] += target
        else
          doc['route-target'] ||= {}
          doc['route-target'][direction] ||= [] 
          doc['route-target'][direction] += target
        end
      end
      if line.include?('srv6 locator')
        locator = line.split('srv6 locator').last.strip
        if mode
          doc[mode]['srv6-locator'] = locator
        else
          doc['srv6-locator'] = locator
        end
      end
    end
    return doc
  end

  def vpls_if conf
    doc = {}
    access_points = TextAbstract.match_paragraph(conf, "\n  access-point ", "\n  $").map{|t|"  access-point "+t+"\n  $"}
    doc['vpn-name'] = conf.split("\n").first.split('vpls ').last.split(' ').first.strip
    access_points.each do|access_point|
      doc['access-point'] ||= {}
      port = nil
      access_point.split("\n").each do|line|
        port = line.split('access-point').last.strip if line.include?('access-point ')
        if port
          doc['access-point'][port] ||= {}
          doc['access-point'][port]['access-params'] ||= [line.split('access-params').last.strip] if line.include?('access-params')
          (doc['access-point'][port]['access-params'] ||= [])<< 'leaf' if line.include?('leaf')
        end
      end
    end
    return doc
  end
end
```