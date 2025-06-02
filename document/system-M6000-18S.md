
# M6000-18S 系统信息

```ruby
@sign << ['M6000-18S', '系统版本']
@sign << ['M6000-18S', '版本']
@sign << ['M6000-18S', '板卡']

module M6000_18S
  module_function
  
  def 系统版本 文本
    info = {}
    info['version'] = 版本 文本
    info['board'] = 板卡 文本
    return info
  end

  def 版本 文本
    ver = 文本.split("\n").find{|l|l.include?("Software, Version:")}
  end

  def 板卡 文本
    head = ['Slot','BoardName','ModName', 'BootVersion','Card','CardType']
    tab = [head]
    raw = 文本.split("System uptime")[-1].split("\nHB-")[0]
    parts,temp = [],[]
    raw.split("\n").each do|line|
      if line[0]=='['
        parts << temp.join("\n")
        temp = []
      end
      temp << line
    end
    parts.each do|part|
      board_num, board_name, mods, cards = '', '', [], []
      idx,card,mod_name,boot_version,mod_names,boot_versions = nil,nil,nil,nil,[],[]
      part.split("\n").each do|line|
        if line.include?("[")
          type = line.split("[")[1].split("]")[0].split(",")[0]
          num = line.split("[")[1].split("]")[0].split(",")[1..-1].map{|i|i.split(" ")[1]}.join("/")
          board_num = "#{type}-#{num}"
        end
        board_name = line.split(":")[-1].strip if line.include?("Board Name")
        
        mod_name = line.split(":")[0].split(",")[0].strip if line[2..3]=='U-'
        boot_version = line.split(":")[-1].strip if line.include?("Bootrom Version")
        if mod_name && boot_version
          mod_names << mod_name
          boot_versions << boot_version
          mod_name, boot_version = nil, nil
        end

        if line.include?("cardID")
          type = line.split(">")[0].split("<")[1].split(",")[0]
          num = line.split(">")[0].split("<")[1].split(",")[1..-1].map{|i|i.split(" ")[1]}.join("/")
          idx = "#{type}-#{num}"
        end
        card = line.split(":")[1].strip if line.include?("Card Name")
        if idx && card
          cards << [idx,card]
          idx, card = nil,nil
        end
      end 
      if cards.size >= 1
        cards.each do|card|
          tab << [board_num, board_name, mod_names.join(';'), boot_versions.join(';')] + card
        end
      else
        tab << [board_num, board_name, mod_names.join(';'), boot_versions.join(';'), '','']
      end
    end
    return tab
  end
end
```