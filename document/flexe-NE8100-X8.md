
# NE8100-X8 FlexE

```ruby
@sign << ['NE8100-X8', 'flexe_client']
@sign << ['NE8100-X8', 'flexe_enable']
@sign << ['NE8100-X8', 'flexe_group']
@sign << ['NE8100-X8', 'flexe_genport']

module NE8100_X8
    module_function

    def flexe_client confs
        table = []
        instances = (confs||[]).select{|c|c.include?('flexe client-instance ')}
        instances.each do|instance|
            fc = {}
            instance.split("\n").each do|line|
                if line.include?('flexe client-instance ')
                    fc['name'] = line.split('flexe client-instance ').last.split(' ').first.to_s.strip
                    fc['group'] = line.split('flexe-group ').last.split(' ').first.to_s.strip
                    fc['type'] = line.split('flexe-type ').last.split(' ').first.to_s.strip
                    fc['port-id'] = line.split('port-id ').last.to_s.strip
                end
                if line.include?('flexe-clientid ')
                    fc['client-id'] = line.split('flexe-clientid ').last.to_s.strip
                end
                if line.include?('binding interface ')
                    fc['binding-if'] = line.split('binding interface ').last.split(' ').first.to_s.strip
                    ts = line.split('time-slot ').last.split(' ').first.to_s.strip
                    # TODO: subts = line.split('sub-time-slot ').last.to_s.strip
                    fc['time-slot'] = []
                    ts.split(',').each do|ts_part|
                        if ts_part.include?('-')
                            h,d = ts_part.split('-')
                            fc['time-slot'] << (h.to_i .. d.to_i)
                        else
                            fc['time-slot'] << ts_part.to_i
                        end
                    end
                end
            end
            table << fc
        end
        return table
    end

    def flexe_enable confs
        enables = (confs||[]).select{|c|c.include?('flexe enable ')}
        enables.map{|enable|enable.split("\n").map{|fp|fp.split(' port ').last}}.flatten
    end

    def flexe_group confs
        table = []
        groups = (confs||[]).select{|c|c.include?('flexe group ')}
        groups.each do|group|
            fg = {}
            group.split("\n").each do|line|
                fg['name'] = line.split('flexe group').last.to_s.strip if line.include?('flexe group ')
                fg['num'] = line.split('flexe-groupnum').last.to_s.strip if line.include?('flexe-groupnum ')
                fg['binding-if'] = line.split('binding interface').last.to_s.strip if line.include?('binding interface ')
            end
            table << fg
        end
        return table
    end

    def flexe_genport flexe_client_info
        slot, subslot, _port = flexe_client_info['binding-if'].match(/\d+\/\d+\/\d+/).to_s.split('/')
        port = flexe_client_info['port-id']
        return "FlexE#{slot}/#{subslot}/#{port}"
    end
end
```
