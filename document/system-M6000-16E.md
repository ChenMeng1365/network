
# M6000-16E 系统信息

```ruby
@sign << ['M6000-16E', '系统版本']
@sign << ['M6000-16E', '版本']
@sign << ['M6000-16E', '板卡']

module M6000_16E
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
    parts.delete('')

    parts.each do|part|
      board_num, board_name, cards = '', '', {}
      mod_name,boot_version,mod_names,boot_versions = nil,nil,[],[]      

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

        if line.include?("Interface Card") and line.include?(":")
          rest = line.split("Interface Card")[-1]
          idx, item = rest.split(":")
          cards[idx.strip] = item.strip
        end
      end

      if cards.empty?
        tab << [board_num, board_name, mod_names.join(';'), boot_versions.join(';'), '', '']
      else
        cards.each do|idx, card|
          tab << [board_num, board_name, mod_names.join(';'), boot_versions.join(';'), board_num+"/"+idx, card]
        end
      end
    end
    return tab
  end
end
```