
# ME60-16 NAT

```ruby
@sign << ['ME60-16', '流量解析']

module ME60_16
  module_function

  def 流量解析 统计回显
    text = 统计回显.split("This operation will take a few minutes. Press 'Ctrl+C' to break ...").last.to_s.split("<").first.to_s
    segments = text.split("\nSlot: ").select{|s|!s.empty?}
    list = {}
    segments.map do|s|
      next unless s.split(" ").first
      title="Slot: "+s.split("\n").first
      list[title]={}
      s.split("\n")[1..-1].each do|sl|next if sl.include?('----')
        sp=sl.split(":")
        next unless sp[0]
        name,unit=sp[0].strip.split('(')
        if unit
          unit = unit.split(')').first
          name = name + ' ' + unit.split(')').last.to_s.strip
          list[title][name] = {"value"=>sp[1..-1].join(':').strip}
          list[title][name].merge!("unit"=>unit)
        else
          list[title][name] = {"value"=>sp[1..-1].join(':').strip}
        end
      end
    end
    records = []
    list.each do|slot, info|
      receive = info['current receive packet bit speed'] || info['current receive packet bit speed bps'] || info['Current receive packet bit speed'] || info['Current receive packet bit speed bps']
      transmit= info['current transmit packet bit speed'] || info['current transmit packet bit speed bps'] || info['Current transmit packet bit speed'] || info['Current transmit packet bit speed bps']
      next unless receive || transmit
      recv_spd = receive['unit'] ? (receive['value'].to_f/(1024*1024*1024)).round(2) : receive['unit']
      send_spd = transmit['unit'] ? (transmit['value'].to_f/(1024*1024*1024)).round(2) : transmit['unit']
      records << [slot, recv_spd, send_spd]
    end
    records
  end
end
```