
# 配置文档解析

## Alcatel

```ruby
@sign << ['ALCATEL7750', '配置解析']

module ALCATEL7750
	module_function

	def 配置解析 raw
		conf = {}; name = nil; temp = []
		raw.split("\n").each do|line|
			if line[0..4]=='echo '
				conf[name] = temp
				temp = []
				name = line.split('"')[1]
				conf[name] = ''
			elsif line.include?('#--------------------------------------------------')
				next
			else
				temp << line
			end 
		end
		conf[name] = temp
		conf.delete(nil)
		return conf
	end
end
```

```ruby
@sign << ['Nokia7750', '配置解析']

module Nokia7750
	module_function

	def 配置解析 raw
		conf = {}; name = nil; temp = []
		raw.split("\n").each do|line|
			if line[0..4]=='echo '
				conf[name] = temp
				temp = []
				name = line.split('"')[1]
				conf[name] = ''
			elsif line.include?('#--------------------------------------------------')
				next
			else
				temp << line
			end 
		end
		conf[name] = temp
		conf.delete(nil)
		return conf
	end
end
```

## 思科

```ruby
@sign << ['C7609', '配置解析']

module C7609
	module_function

	def 配置解析 raw
		conf = {}; name = nil; temp = []
		return conf
	end
end
```

```ruby
@sign << ['CRS-16', '配置解析']

module CRS_16
	module_function

	def 配置解析 raw, *guards
		config = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("hostname ")}.to_s.split("hostname ")[1]
    prepart = raw.split("show running-config")[1]
    return {} unless prepart
    content = prepart.split("\nend\n")[0]
    config, pretent = {}, content
    while pretent.include?("!\n!"); pretent = pretent.gsub("!\n!","!") end
    pieces = pretent.split("\n!\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (config[tag] ||= []) << piece
    end
    return config
	end
end
```

## 华为

```ruby
@sign << ['CX600-X8A', '配置解析']
@sign << ['CX600-X8A', '主机名']

module CX600_X8A
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    # prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    # return cfg unless prepart
    content = raw#prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

```ruby
@sign << ['CX600-X16A', '配置解析']
@sign << ['CX600-X16A', '主机名']

module CX600_X16A
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    # prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    # return cfg unless prepart
    content = raw#prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

```ruby
@sign << ['MA5200G-8', '配置解析']
@sign << ['MA5200G-8', '主机名 ']

module MA5200G_8
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

```ruby
@sign << ['NE40E', '配置解析']
@sign << ['NE40E', '主机名 ']

module NE40E
	module_function

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

```ruby
@sign << ['NE80E', '配置解析']
@sign << ['NE80E', '主机名 ']

module NE80E
	module_function

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end

end
```

```ruby
@sign << ['ME60-16', '配置解析']
@sign << ['ME60-16', '主机名 ']

module ME60_16
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    prepart = raw.split("#{hostname}>display current-configuration\n")[1] unless prepart
    return cfg unless prepart
    content = prepart.split(/<#{hostname}>( )*/)[0]
    content = prepart.split("\nreturn")[0] unless content
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

```ruby
@sign << ['ME60-X16', '配置解析']
@sign << ['ME60-X16', '主机名 ']

module ME60_X16
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    prepart = raw.split("#{hostname}>display current-configuration\n")[1] unless prepart
    return cfg unless prepart
    content = prepart.split(/<#{hostname}>( )*/)[0]
    content = prepart.split("\nreturn")[0] unless content
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

```ruby
@sign << ['NE40E-X8', '配置解析']
@sign << ['NE40E-X8', '主机名 ']

module NE40E_X8
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

```ruby
@sign << ['NE40E-X16', '配置解析']
@sign << ['NE40E-X16', '主机名 ']

module NE40E_X16
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    prepart = raw.split("#{hostname}>display current-configuration\n")[1] unless prepart
    return cfg unless prepart
    content = prepart.split(/<#{hostname}>( )*/)[0]
    content = prepart.split("\nreturn")[0] unless content
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

```ruby
@sign << ['NE40E-X16A', '配置解析']
@sign << ['NE40E-X16A', '主机名 ']

module NE40E_X16A
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    prepart = raw.split("display current-configuration\n").select{|part|!part.include?('>>>>')}
    return cfg if prepart.empty?
    content = prepart.join.split("\nreturn\n").first
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end

end
```

```ruby
@sign << ['NE5000E-X16', '配置解析']
@sign << ['NE5000E-X16', '主机名 ']

module NE5000E_X16
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end

end
```

```ruby
@sign << ['NE5000E-X16A', '配置解析']
@sign << ['NE5000E-X16A', '主机名 ']

module NE5000E_X16A
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

```ruby
@sign << ['NE5000E-20', '配置解析']
@sign << ['NE5000E-20', '主机名 ']

module NE5000E_20
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    if raw.include?("<#{hostname}>\ndisplay current-configuration\n")
      pretent = raw.split("display current-configuration")[1].split("\nreturn")[0]
    else
      prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
      return cfg unless prepart
      content = prepart.split(/<#{hostname}>( )*\n/)[0]
      pretent = "\n"+content
    end
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end

end
```

```ruby
@sign << ['NE8000E-X8', '配置解析']
@sign << ['NE8000E-X8', '主机名 ']

module NE8000E_X8
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    # prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    # return cfg unless prepart
    content = raw#prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

```ruby
@sign << ['NE8100-X8', '配置解析']
@sign << ['NE8100-X8', '主机名 ']

module NE8100_X8
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    # prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    # return cfg unless prepart
    content = raw#prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end

end
```

```ruby
@sign << ['VNE9000', '配置解析']
@sign << ['VNE9000', '主机名 ']

module VNE9000
	module_function

  def 配置解析 braw,*guards
    raw = braw
    begin
      raw.split("\n")
    rescue
      raw = braw.force_encoding('GBK').encode('UTF-8')
    end
    cfg = {}
    hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
    # prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
    # return cfg unless prepart
    content = raw#prepart.split(/<#{hostname}>( )*\n/)[0]
    pretent = "\n"+content
    while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
    pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
    pieces.each do|piece|
      tag = piece.split("\n")[0].split(" ")[0]
      (cfg[tag] ||= []) << piece
    end
    return cfg
  end

  def 主机名 config
    config['sysname'].first.to_s.split(' ')[1]
  end
end
```

## 中兴

```ruby
@sign << ['M6000', '配置解析']
@sign << ['M6000', '主机名']

module M6000
	module_function

  # Fix a special bug when naming as a tag
  def preprocess raw
    new_raw = []
    raw.split("\n").each do|line|
      if line.include?('<') && line.include?('>') && line[0..1]!='!<'
        new_raw << line.gsub('<','&lt;').gsub('>','&gt;')
      else
        new_raw << line
      end
    end
    return new_raw.join("\n")
  end

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || self.preprocess(raw).split("\n").find{|line|line.include?("hostname ")}.to_s.split("hostname ")[1]
    # prepart = self.preprocess(raw).split(/#{hostname}#( )*show running-config( )*\n/)[1]
    # return cfg unless prepart
    content = self.preprocess(raw)#prepart.split(/#{hostname}#( )*\n/)[0]

    begin
      XmlParser.parse("<root>#{content}</root>").elements.each do|element|
        cfg[element.name] = element.attributes[:text]
      end
    #rescue
    end
    cfg
  end

  def 主机名 config
    config['system-config'].to_s.split("\n")[0].split(' ')[1]
  end
end
```

```ruby
@sign << ['M6000-8', '配置解析']
@sign << ['M6000-8', '主机名']

module M6000_8
	module_function

  # Fix a special bug when naming as a tag
  def preprocess raw
    new_raw = []
    raw.split("\n").each do|line|
      if line.include?('<') && line.include?('>') && line[0..1]!='!<'
        new_raw << line.gsub('<','&lt;').gsub('>','&gt;')
      else
        new_raw << line
      end
    end
    return new_raw.join("\n")
  end

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || self.preprocess(raw).split("\n").find{|line|line.include?("hostname ")}.to_s.split("hostname ")[1]
    prepart = self.preprocess(raw).split(/#{hostname}#( )*show running-config( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/#{hostname}#( )*\n/)[0]
    begin
      XmlParser.parse("<root>#{content}</root>").elements.each do|element|
        cfg[element.name] = element.attributes[:text]
      end
    #rescue
    end
    cfg
  end

  def 主机名 config
    config['system-config'].to_s.split("\n")[0].split(' ')[1]
  end
end
```

```ruby
@sign << ['M6000-8E', '配置解析']
@sign << ['M6000-8E', '主机名']

module M6000_8E
	module_function

  # Fix a special bug when naming as a tag
  def preprocess raw
    new_raw = []
    raw.split("\n").each do|line|
      if line.include?('<') && line.include?('>') && line[0..1]!='!<'
        new_raw << line.gsub('<','&lt;').gsub('>','&gt;')
      else
        new_raw << line
      end
    end
    return new_raw.join("\n")
  end

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || self.preprocess(raw).split("\n").find{|line|line.include?("hostname ")}.to_s.split("hostname ")[1]
    prepart = self.preprocess(raw).split(/#{hostname}#( )*show running-config( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/#{hostname}#( )*\n/)[0]

    begin
      XmlParser.parse("<root>#{content}</root>").elements.each do|element|
        cfg[element.name] = element.attributes[:text]
      end
    #rescue
    end
    cfg
  end

  def 主机名 config
    config['system-config'].to_s.split("\n")[0].split(' ')[1]
  end
end
```

```ruby
@sign << ['M6000-16E', '配置解析']
@sign << ['M6000-16E', '主机名']

module M6000_16E
	module_function

  # Fix a special bug when naming as a tag
  def preprocess raw
    new_raw = []
    raw.split("\n").each do|line|
      if line.include?('<') && line.include?('>') && line[0..1]!='!<'
        new_raw << line.gsub('<','&lt;').gsub('>','&gt;')
      else
        new_raw << line
      end
    end
    return new_raw.join("\n")
  end

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || self.preprocess(raw).split("\n").find{|line|line.include?("hostname ")}.to_s.split("hostname ")[1]
    prepart = self.preprocess(raw).split(/#{hostname}#( )*show running-config( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/#{hostname}#( )*\n/)[0]
    begin
      XmlParser.parse("<root>#{content}</root>").elements.each do|element|
        cfg[element.name] = element.attributes[:text]
      end
    #rescue
    end
    cfg
  end

  def 主机名 config
    config['system-config'].to_s.split("\n")[0].split(' ')[1]
  end
end
```

```ruby
@sign << ['M6000-18S', '配置解析']
@sign << ['M6000-18S', '主机名']

module M6000_18S
	module_function

  # Fix a special bug when naming as a tag
  def preprocess raw
    new_raw = []
    raw.split("\n").each do|line|
      if line.include?('<') && line.include?('>') && line[0..1]!='!<'
        new_raw << line.gsub('<','&lt;').gsub('>','&gt;')
      else
        new_raw << line
      end
    end
    return new_raw.join("\n")
  end

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || self.preprocess(raw).split("\n").find{|line|line.include?("hostname ")}.to_s.split("hostname ")[1]
    prepart = self.preprocess(raw).split(/#{hostname}#( )*show running-config( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/#{hostname}#( )*\n/)[0]

    begin
      XmlParser.parse("<root>#{content}</root>").elements.each do|element|
        cfg[element.name] = element.attributes[:text]
      end
    #rescue
    end
    cfg
  end

  def 主机名 config
    config['system-config'].to_s.split("\n")[0].split(' ')[1]
  end
end
```

```ruby
@sign << ['T8000-18', '配置解析']
@sign << ['T8000-18', '主机名 ']

module T8000_18
	module_function

  # Fix a special bug when naming as a tag
  def preprocess raw
    new_raw = []
    raw.split("\n").each do|line|
      if line.include?('<') && line.include?('>') && line[0..1]!='!<'
        new_raw << line.gsub('<','&lt;').gsub('>','&gt;')
      else
        new_raw << line
      end
    end
    return new_raw.join("\n")
  end

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || self.preprocess(raw).split("\n").find{|line|line.include?("hostname ")}.to_s.split("hostname ")[1]
    prepart = self.preprocess(raw).split(/#{hostname}#( )*show running-config( )*\n/)[1]
    return cfg unless prepart
    content = prepart.split(/#{hostname}#( )*\n/)[0]

    begin
      XmlParser.parse("<root>#{content}</root>").elements.each do|element|
        cfg[element.name] = element.attributes[:text]
      end
    #rescue
    end
    cfg
  end

  def 主机名 config
    config['system-config'].to_s.split("\n")[0].split(' ')[1]
  end
end
```

```ruby
@sign << ['ZXCTN9000-8EA', '配置解析']
@sign << ['ZXCTN9000-8EA', '主机名 ']

module ZXCTN9000_8EA
	module_function

  # Fix a special bug when naming as a tag
  def preprocess raw
    new_raw = []
    raw.split("\n").each do|line|
      if line.include?('<') && line.include?('>') && line[0..1]!='!<'
        new_raw << line.gsub('<','&lt;').gsub('>','&gt;')
      else
        new_raw << line
      end
    end
    return new_raw.join("\n")
  end

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || self.preprocess(raw).split("\n").find{|line|line.include?("hostname ")}.to_s.split("hostname ")[1]
    # prepart = self.preprocess(raw).split(/#{hostname}#( )*show running-config( )*\n/)[1]
    # return cfg unless prepart
    content = self.preprocess(raw)#prepart.split(/#{hostname}#( )*\n/)[0]

    begin
      XmlParser.parse("<root>#{content}</root>").elements.each do|element|
        cfg[element.name] = element.attributes[:text]
      end
    #rescue
    end
    cfg
  end

  def 主机名 config
    config['system-config'].to_s.split("\n")[0].split(' ')[1]
  end
end
```

```ruby
@sign << ['ZXCTN9000-18EA', '配置解析']
@sign << ['ZXCTN9000-18EA', '主机名 ']

module ZXCTN9000_18EA
	module_function

  # Fix a special bug when naming as a tag
  def preprocess raw
    new_raw = []
    raw.split("\n").each do|line|
      if line.include?('<') && line.include?('>') && line[0..1]!='!<'
        new_raw << line.gsub('<','&lt;').gsub('>','&gt;')
      else
        new_raw << line
      end
    end
    return new_raw.join("\n")
  end

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || self.preprocess(raw).split("\n").find{|line|line.include?("hostname ")}.to_s.split("hostname ")[1]
    # prepart = self.preprocess(raw).split(/#{hostname}#( )*show running-config( )*\n/)[1]
    # return cfg unless prepart
    content = self.preprocess(raw)#prepart.split(/#{hostname}#( )*\n/)[0]

    begin
      XmlParser.parse("<root>#{content}</root>").elements.each do|element|
        cfg[element.name] = element.attributes[:text]
      end
    #rescue
    end
    cfg
  end

  def 主机名 config
    config['system-config'].to_s.split("\n")[0].split(' ')[1]
  end
end
```

```ruby
@sign << ['V6000', '配置解析']
@sign << ['V6000', '主机名 ']

module V6000
	module_function

  # Fix a special bug when naming as a tag
  def preprocess raw
    new_raw = []
    raw.split("\n").each do|line|
      if line.include?('<') && line.include?('>') && line[0..1]!='!<'
        new_raw << line.gsub('<','&lt;').gsub('>','&gt;')
      else
        new_raw << line
      end
    end
    return new_raw.join("\n")
  end

  def 配置解析 raw,*guards
    cfg = {}
    hostname = guards[0] || self.preprocess(raw).split("\n").find{|line|line.include?("hostname ")}.to_s.split("hostname ")[1]
    # prepart = self.preprocess(raw).split(/#{hostname}#( )*show running-config( )*\n/)[1]
    # return cfg unless prepart
    content = self.preprocess(raw)#prepart.split(/#{hostname}#( )*\n/)[0]

    begin
      XmlParser.parse("<root>#{content}</root>").elements.each do|element|
        cfg[element.name] = element.attributes[:text]
      end
    #rescue
    end
    cfg
  end

  def 主机名 config
    config['system-config'].to_s.split("\n")[0].split(' ')[1]
  end
end
```

## 华三

```ruby
@sign << ['CR16010H-F', '配置解析']
@sign << ['CR16010H-F', '主机名']

module CR16010H_F
    module_function

    def 配置解析 braw,*guards
        raw = braw
        begin
            raw.split("\n")
        rescue
            raw = braw.force_encoding('GBK').encode('UTF-8')
        end
        cfg = {}
        hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
        prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
        prepart = raw.split("#{hostname}>display current-configuration\n")[1] unless prepart
        return cfg unless prepart
        content = prepart.split(/<#{hostname}>( )*/)[0]
        content = prepart.split("\nreturn")[0] unless content
        pretent = "\n"+content
        while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
        pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
        pieces.each do|piece|
            tag = piece.split("\n")[0].split(" ")[0]
            (cfg[tag] ||= []) << piece
        end
        return cfg
    end

    def 主机名 config
        config['sysname'].first.to_s.split(' ')[1]
    end
end
```

```ruby
@sign << ['CR16018-F', '配置解析']
@sign << ['CR16018-F', '主机名']

module CR16018_F
    module_function

    def 配置解析 braw,*guards
        raw = braw
        begin
            raw.split("\n")
        rescue
            raw = braw.force_encoding('GBK').encode('UTF-8')
        end
        cfg = {}
        hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
        prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
        prepart = raw.split("#{hostname}>display current-configuration\n")[1] unless prepart
        return cfg unless prepart
        content = prepart.split(/<#{hostname}>( )*/)[0]
        content = prepart.split("\nreturn")[0] unless content
        pretent = "\n"+content
        while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
        pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
        pieces.each do|piece|
            tag = piece.split("\n")[0].split(" ")[0]
            (cfg[tag] ||= []) << piece
        end
        return cfg
    end

    def 主机名 config
        config['sysname'].first.to_s.split(' ')[1]
    end
end
```

```ruby
@sign << ['CR19000-20', '配置解析']
@sign << ['CR19000-20', '主机名']

module CR19000_20
    module_function

    def 配置解析 braw,*guards
        raw = braw
        begin
            raw.split("\n")
        rescue
            raw = braw.force_encoding('GBK').encode('UTF-8')
        end
        cfg = {}
        hostname = guards[0] || raw.split("\n").find{|line|line.include?("sysname ")}.to_s.split("sysname ")[1]
        prepart = raw.split(/#{hostname}>( )*display current-configuration( )*\n/)[1]
        prepart = raw.split("#{hostname}>display current-configuration\n")[1] unless prepart
        return cfg unless prepart
        content = prepart.split(/<#{hostname}>( )*/)[0]
        content = prepart.split("\nreturn")[0] unless content
        pretent = "\n"+content
        while pretent.include?("\n#\n#"); pretent = pretent.gsub("\n#\n#","\n#") end
        pieces = pretent.split("\n#\n").select{|pc|pc.strip != ''}
        pieces.each do|piece|
            tag = piece.split("\n")[0].split(" ")[0]
            (cfg[tag] ||= []) << piece
        end
        return cfg
    end

    def 主机名 config
        config['sysname'].first.to_s.split(' ')[1]
    end
end
```
