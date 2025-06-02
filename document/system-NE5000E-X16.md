
# NE5000E-X16 系统信息

```ruby
@sign << ['NE5000E-X16', '系统版本']
@sign << ['NE5000E-X16', '版本']
@sign << ['NE5000E-X16', '补丁']
@sign << ['NE5000E-X16', '板卡']

module NE5000E_X16
  module_function
  
  def 系统版本 文本
    info = {}
    info['version'] = 版本 文本
    info['patch'] = 补丁 文本
    info['board'] = 板卡 文本
    return info
  end

  def 版本 文本
    vrp = 文本.split("\n").find{|l|l.include?("VRP")}
  end

  def 补丁 文本
    patch = 文本.split("\n").find{|l|l.include?("Patch version")}.to_s.split(":")[-1]
  end

  def 板卡 文本
    head = ['Slot','Type','Online','Register','Status','Role','LsId','Primary'] + ['Pic','Status','Type','Port_count','Init_result','Logic_down']
    raw1 = 文本.split("NE5000E's Device status:")[-1].split("\n<")[0].split("\n-------------------------------------------------------------------------------")[2].strip
    tab1 = raw1.split("\n").map{|l|l.split(" ")}
    raw2 = 文本.split("Pic-status information :")[-1].split("\n<")[0].split("\n-------------------------------------------------------------------------------")[2].strip
    tab2 = raw2.split("\n").map{|l|l.split(" ")}[1..-1]
    tab = [head]
    tab1.each do|rec|
      ext = tab2.select{|r|r[0].split("/")[0]==rec[0]}
      if ext.size==0
        tmp = rec + ['','','','','','']
        tab << tmp
      else
        ext.each do|r|
          tmp = rec + r[0..-1]
          tab << tmp
        end
      end
    end
    return tab
  end
end
```