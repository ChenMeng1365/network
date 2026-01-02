
# M6000-8 流量、光功率、用户数统计

```ruby
@sign << ['M6000-8', 'flux_statistic']
@sign << ['M6000-8', 'optical_statistic']
@sign << ['M6000-8', 'subscriber_statistic']

module M6000_8
    module_function

    def flux_statistic content
        context,flag = [], false
        head = ['interface', 'in_flux(bps)', #　Bps => bps
            'in_percent(bps)','out_flux', # Bps => bps
            'out_percent','in_error','in_optical','out_optical']
        content.split("\n").each do|line|
            (flag = true;next) if line.include?('#### begin flux ####')
            break if line.include?('#### end flux ####')
            if flag
                words = line.strip.split(' ')
                next if words.size < 8
                context << [words[0], words[1].to_i*8, words[2]+'%', words[3].to_i*8, words[4]+'%', words[5].to_i, words[6].to_f, words[7].to_f]
            end
        end
        context.sort_by!{|c|c[0]}
        context.unshift head
        return context
    end

    def optical_statistic content_or_table
        content =  content_or_table.is_a?(Array) ? content_or_table : (self.flux_statistic content_or_table)
        # head: ['interface', 'in_optical', 'out_optical']
        return content.map{|c|[c[0],c[-2],c[-1]]}
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