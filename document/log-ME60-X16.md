
# ME60-X16 日志

```ruby
@sign << ['ME60-X16', '日志']
@sign << ['ME60-X16', 'aaa下线日志']
# require 'time'

module ME60_X16
  module_function

  def 日志 logs # logs => line-texts
    tab = [['time', 'alarm_type', 'alarm_id', 'alarm_lv', 'node', 'module', 'message', 'list']]
    logs.each do|log|
      texts = log.split(": ")
      header,content = texts[0],texts[1..-1].join(': ')
      headers = header.split(' ')
      timetag, node, source = headers[0..-3].join(' '),headers[-2], headers[-1]

      time, src = Time.parse(timetag).strftime("%Y-%m-%d %H:%M:%S"),source.strip
      mod, alarm_lv, mtype = src.split("/")
      alarm_type = mtype.split("[")[0]
      alarm_id = mtype.split("[")[1].to_s.split("]")[0].to_s

      if content.include?("(")
        message = content.split("(")[0]
        list = content.split("(")[1].split(")")[0]
      else
        message = content
        list = ""
      end

      tab << [time, alarm_type, alarm_id, alarm_lv, node, mod, message, list]
    end
    return tab
  end

  def aaa下线日志 rawlog
    records = [['username','ipaddr','mac','interface','pvlan','cvlan','login-time','offline-time','reason']]
    log = rawlog.split("--------------------------------------------------------------------------------\n")[1..-2]
    log.each do|part|
      next if part==''
      begin
        username = part.split("Username:")[1].split(" ")[0].strip
        mac = part.split("MAC:")[1].split("\n")[0].strip
        interface = part.split("Interface:")[1].split(" ")[0].strip
        vlanid = part.split(" VlanID:")[1].split(" ")[0].strip
        svlanid = part.split("SecondVlanID:")[1].split("\n")[0].strip
        ipaddress = part.split("IpAddress:")[1].split("\n")[0].strip
        logintime = part.split("LoginTime:")[1].split("\n")[0].strip
        offlinetime = part.split("OfflineTime:")[1].split("\n")[0].strip
        reason = part.split("OfflineReason:")[1].split("\n")[0].strip
        records << [username, ipaddress, mac, interface, vlanid, svlanid, logintime, offlinetime, reason]
      rescue
        p part
      end
    end
    return records
  end
end
```