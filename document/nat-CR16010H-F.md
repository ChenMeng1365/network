
# CR16010H-F NAT

```ruby
@sign << ['CR16010H-F', '流量解析']

module CR16010H_F
  module_function

  def 流量解析 统计回显
    slots = 统计回显.match_paragraph("\nCPU ","\n  Peak time:")
    records = []
    slots.each do|slot|
      lines = slot.split("\n")
      slot_name = lines[0].split('on ').last.split(':').first.gsub(' ','')
      record = [slot_name] # [slot_name, input, output, band]
      lines.each do|line|
        record[1] = (line.split(',').last.split('bytes').first.to_f*8/(1024*1024*1024)).round(2) if line.include?('input rate')
        record[2] = (line.split(',').last.split('bytes').first.to_f*8/(1024*1024*1024)).round(2) if line.include?('output rate')
        record[3] = line.split(':').last.strip if line.include?('Bandwidth use ratio')
      end
      records << record if record.size > 1
    end
    records    
  end
end
```