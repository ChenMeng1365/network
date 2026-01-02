
# M6000-18S 流量、光功率、用户数统计

```ruby
@sign << ['M6000-18S', 'flux_statistic']
@sign << ['M6000-18S', 'optical_statistic']
@sign << ['M6000-18S', 'subscriber_statistic']

module M6000_18S
    module_function

    def flux_statistic content
        context,flag,record = [], false, []
        content.split("\n").each do|line|
            (flag = true;next) if line.include?('#### begin flux ####')
            next if line.include?('show intf-statistics utilization')
            next if line.strip.empty?
            break if line.include?('#### end flux ####')
            if flag
                words = line.strip.split(' ')
                if words.size==4
                    if record.size==4 # no desc, add an new record
                        context << record+['']
                        record = [words[0], words[1]+"%", words[2]+"%", words[3].to_i]
                    else # normal
                        record += [words[0], words[1]+"%", words[2]+"%", words[3].to_i]
                    end
                elsif words.size < 4 # desc, attach to current record
                    record += words if record.size==4
                    context << record
                    record = []
                end
            end
        end
        context = context[1..-1].select{|c|!c.empty?}
        context.sort_by!{|c|c[0]}
        context.unshift head=['interface','in_percent', 'out_percent', 'in_error', 'description']
        return context
    end

    def optical_statistic content
        context,flag = [], false
        if_name, mod_type, wav_len, in_dbm, in_range, out_dbm, out_range, state = '','','',[],[],[],[],[]
        content.split("\n").each do|line|
            (flag = true;next) if line.include?('#### begin optical ####')
            next if line.include?('show opticalinfo brief')
            next if line.strip.empty?
            break if line.include?('#### end optical ####')
            if flag
                words = line.strip.split(' ')
                next if words[0].include?('Interface') || words[0].include?('TxPower')
                if words.size==4 # if_name, mod_type, wav_len, in_dbm
                    if_name, mod_type, wav_len = words[0..2]
                    in_optical,others = words[3].split('/[')
                    in_ranges = others.gsub(']','').split(',').map{|r|r.to_f} if others
                    in_dbm << (in_optical=='N/A' ? 'N/A' : in_optical.to_f)
                    in_range << in_ranges if others
                elsif words.size==6 # if_name, mod_type, wav_len, in_dbm, out_dbm, state
                    if_name, mod_type, wav_len = words[0..2]
                    in_optical,others = words[3].split('/[')
                    in_ranges = others.gsub(']','').split(',').map{|r|r.to_f} if others
                    in_dbm << (in_optical=='N/A' ? 'N/A' : in_optical.to_f)
                    in_range << in_ranges if others
                    out_optical, others = words[4].split('/[')
                    out_ranges = others.gsub(']','').split(',').map{|r|r.to_f} if others
                    out_dbm << (out_optical=='N/A' ? 'N/A' : out_optical.to_f)
                    out_range << out_ranges if others
                    state << words[5]
                elsif words.size==3 # in_dbm, out_dbm, state
                    in_optical,others = words[0].split('/[')
                    in_ranges = others.gsub(']','').split(',').map{|r|r.to_f} if others
                    in_dbm << (in_optical=='N/A' ? 'N/A' : in_optical.to_f)
                    in_range << in_ranges if others
                    out_optical, others = words[1].split('/[')
                    out_ranges = others.gsub(']','').split(',').map{|r|r.to_f} if others
                    out_dbm << (out_optical=='N/A' ? 'N/A' : out_optical.to_f)
                    out_range << out_ranges if others
                    state << words[2]
                elsif words.size==2
                    if words.include?('offline') # if_name, mod_type='offline'
                        context << words+['',[],[],[],[],[]]
                        if_name, mod_type, wav_len, in_dbm, in_range, out_dbm, out_range, state = '','','',[],[],[],[],[]
                        next
                    end
                    if words[1].match(/(\d|\.)+/) # in_dbm, out_dbm
                        in_optical,others = words[0].split('/[')
                        in_ranges = others.gsub(']','').split(',').map{|r|r.to_f} if others
                        in_dbm << (in_optical=='N/A' ? 'N/A' : in_optical.to_f)
                        in_range << in_ranges if others
                        out_optical, others = words[1].split('/[')
                        out_ranges = others.gsub(']','').split(',').map{|r|r.to_f} if others
                        out_dbm << (out_optical=='N/A' ? 'N/A' : out_optical.to_f)
                        out_range << out_ranges if others
                    else # out_dbm, state
                        out_optical, others = words[0].split('/[')
                        out_ranges = others.gsub(']','').split(',').map{|r|r.to_f} if others
                        out_dbm << (out_optical=='N/A' ? 'N/A' : out_optical.to_f)
                        out_range << out_ranges if others
                        state << words[1]
                    end
                elsif words.size==1 # in_dbm/out_dbm
                    optical, others = words[0].split('/[')
                    ranges = others.gsub(']','').split(',').map{|r|r.to_f} if others
                    in_dbm  << (optical=='N/A' ? 'N/A' : optical.to_f) if in_dbm.size<=out_dbm.size
                    out_dbm << (optical=='N/A' ? 'N/A' : optical.to_f) if in_dbm.size>out_dbm.size
                    in_range  << ranges if others && in_range.size<=out_range.size
                    out_range << ranges if others && in_range.size>out_range.size
                end
                if ( !if_name.empty? && !mod_type.empty? && !wav_len.empty? && !in_dbm.empty? && !out_dbm.empty? && !state.empty? )
                    if if_name.include?('cgei')
                        if in_dbm.size > 4 && out_dbm.size > 4
                            context << [if_name, mod_type, wav_len, in_dbm, in_range, out_dbm, out_range, state]
                            if_name, mod_type, wav_len, in_dbm, in_range, out_dbm, out_range, state = '','','',[],[],[],[],[]
                        end
                    else
                        context << [if_name, mod_type, wav_len, in_dbm, in_range, out_dbm, out_range, state]
                        if_name, mod_type, wav_len, in_dbm, in_range, out_dbm, out_range, state = '','','',[],[],[],[],[]
                    end
                end

            end
        end
        context.sort_by!{|c|c[0]}
        context.unshift head=['interface','module_type', 'wave_length', 'in_optical','in_range','out_optical','out_range','state']
        return context
    end

    def subscriber_statistic content
        context,flag = [], false
        head = ['domain','state','limit','num','num(v4)','num(v6)','num(dual)']
        content.split("\n").each do|line|
            (flag = true;next) if line.include?('#### begin subscriber ####')
            break if line.include?('#### end subscriber ####')
            if flag
                words = line.strip.split(' ')
                next if words.size != 4 || words.include?('subscriber')
                num, sub = words[-1].split('(')
                num4, num6, numd = sub.split(')').first.split('/')
                context << words[0..1]+ [words[2].to_i, num.to_i, num4.to_i, num6.to_i, numd.to_i]
            end
        end
        context.sort_by!{|c|c[0]}
        context.unshift head
        return context
    end
end
```