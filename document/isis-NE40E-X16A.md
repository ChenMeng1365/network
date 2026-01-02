
# NE40E-X16A isis

```ruby
@sign << ['NE40E-X16A', '接口isis']
@sign << ['NE40E-X16A', 'isis']

module NE40E_X16A
    module_function

    def 接口isis 接口配置
        isis = {}
        port_name = self.端口识别(接口配置.split("\n").first.to_s).join()
        lines = 接口配置.split("\n").select{|line|line.strip[0..4]=='isis '}
        lines.each do|line|
            isis['pid'] = line.strip.split(' ').last.to_i if line.include?('isis enable')
            isis['ipv6-pid'] = line.strip.split(' ').last.to_i if line.include?('isis ipv6 enable')
            isis['circuit-type'] = line.split('circuit-type').last.strip if line.include?('isis circuit-type')
            isis['cost'] = line.strip.split(' ').last.to_i if line.include?('isis cost')
            isis['ipv6-cost'] = line.strip.split(' ').last.to_i if line.include?('isis ipv6 cost')
            if line.include?('isis ldp-sync')
                isis['ldp-sync'] ||= {}
                isis['ldp-sync']['state'] = 'enable'
                isis['ldp-sync']['hold-max-cost-timer'] = line.strip.split(' ').last+'s' if line.include?('isis timer ldp-sync')
            end
            isis['hold-max-cost-timer'] = line.strip.split(' ').last+'ms' if line.include?('isis peer hold-max-cost')
        end
        return { port_name => isis }
    end

    def isis isis配置
        isis = {};frr4_flag, frr6_flag = false, false
        isis配置.split("\n").each do|line|
            isis['pid'] = line.split(' ').last.strip if line[0..4]=='isis '
            isis['level'] = line.split(' ').last.strip if line.include?('is-level')
            isis['cost-style'] = line.split(' ').last.strip if line.include?('cost-style')
            if line.include?('timer lsp-generation')
                isis['lsp-generation-timer'] ||= {}
                setter = line.split('lsp-generation').last.strip.split(' ')
                setlevels = []
                setlevels = ['level-1'] if setter[-1]=='level-1'
                setlevels = ['level-2'] if setter[-1]=='level-2'
                setlevels = ['level-1', 'level-2']
                setlevels.each do|setlevel|
                    isis['lsp-generation-timer']['max-interval'] = setter[0]+'s'
                    isis['lsp-generation-timer']['init-interval'] = setter[1]+'ms' if setter[1] && !setter[1].include?('level')
                    isis['lsp-generation-timer']['incr-interval'] = setter[2]+'ms' if setter[2] && !setter[2].include?('level')
                end
            end
            if line.include?('bfd all-interfaces') && line.strip[0..2]=='bfd'
                isis['bfd'] ||= {}
                isis['bfd']['interface'] = 'enable' if line.include?('enable')
                words = line.split(' ')
                isis['bfd']['min-tx-interval'] = words[words.index('min-tx-interval')+1] + 'ms' if words.index('min-tx-interval')
                isis['bfd']['min-rx-interval'] = words[words.index('min-rx-interval')+1] + 'ms' if words.index('min-rx-interval')
                isis['bfd']['detect-multiplier'] = words[words.index('detect-multiplier')+1].to_i if words.index('detect-multiplier')
                isis['bfd']['tos-exp'] = words[words.index('tos-exp')+1].to_i if words.index('tos-exp')
                isis['bfd']['frr-binding'] = 'enable' if line.include?('frr-binding')
            end
            if line.include?('ipv6 bfd all-interfaces')
                isis['ipv6-bfd'] ||= {}
                isis['ipv6-bfd']['interface'] = 'enable' if line.include?('enable')
                words = line.split(' ')
                isis['ipv6-bfd']['min-tx-interval'] = words[words.index('min-tx-interval')+1] + 'ms' if words.index('min-tx-interval')
                isis['ipv6-bfd']['min-rx-interval'] = words[words.index('min-rx-interval')+1] + 'ms' if words.index('min-rx-interval')
                isis['ipv6-bfd']['detect-multiplier'] = words[words.index('detect-multiplier')+1].to_i if words.index('detect-multiplier')
                isis['ipv6-bfd']['frr-binding'] = 'enable' if line.include?('frr-binding')
            end
            isis['net'] = line.split(' ').last if line.include?('network-entity')
            isis['is-name'] = line.split(' ').last if line.include?('is-name')
            if line.include?('avoid-microloop') && line.strip[0..4]=='avoid'
                isis['avoid-microloop'] ||= {}
                isis['avoid-microloop']['frr-protected'] ||= {'rib-update-delay'=>'100ms'} if line.include?('frr-protected')
                isis['avoid-microloop']['frr-protected']['rib-update-delay'] = line.split(' ').last+'ms' if line.include?('frr-protected') && line.include?('rib-update-delay')
                isis['avoid-microloop']['te-tunnel'] ||= {'rib-update-delay'=>'1000ms'} if line.include?('te-tunnel')
                isis['avoid-microloop']['te-tunnel']['rib-update-delay'] = line.split(' ').last+'ms' if line.include?('te-tunnel') && line.include?('rib-update-delay')
            end
            if line.include?('ipv6 avoid-microloop')
                isis['ipv6-avoid-microloop'] ||= {}
                isis['ipv6-avoid-microloop']['segment-routing'] ||= {'rib-update-delay'=>'5000ms'} if line.include?('segment-routing')
                isis['ipv6-avoid-microloop']['segment-routing']['rib-update-delay'] = line.split(' ').last+'ms' if line.include?('segment-routing') && line.include?('rib-update-delay')
            end
            isis['preference'] = line.split(' ').last.to_i if line.strip[0..10]=='preference '
            isis['ipv6-preference'] = line.split(' ').last.to_i if line.include?('ipv6 preference ')
            if line.include?('timer spf')
                setter = line.split('timer spf').last.strip.split(' ')
                isis['spf-timer'] ||= {}
                isis['spf-timer']['max-interval'] = setter[0]+'s'
                isis['spf-timer']['init-interval'] = setter[1]+'ms' if setter[1]
                isis['spf-timer']['incr-interval'] = setter[2]+'ms' if setter[2]
            end
            if line.include?('set-overload')
                isis['set-overload'] ||= {}
                isis['set-overload']['allow'] = 'interlevel' if line.include?('allow interlevel')
                isis['set-overload']['allow'] = 'external' if line.include?('allow external')
                isis['set-overload']['on-startup'] ||= {} if line.include?('on-startup')
                words = line.strip.split(' ')
                if line.include?('on-startup') && words[words.index('on-startup')+1].to_s.match(/^\d+$/)
                    isis['set-overload']['on-startup']['timeout'] = words[words.index('on-startup')+1]+'s'
                else
                    # isis['set-overload']['on-startup']['timeout'] = '600s'
                    if line.include?('send-sa-bit') && words[words.index('send-sa-bit')+1].match(/^\d+$/)
                        isis['set-overload']['on-startup']['send-sa-bit'] = words[words.index('send-sa-bit')+1]+'s'
                    else
                        # isis['set-overload']['on-startup']['send-sa-bit'] = '30s'
                    end
                    # TODO: start-from-nbr | wait-for-bgp | route-delay-distribute
                end
            end
            (isis['frr'] = {}; frr4_flag = true) if line.strip=='frr'
            isis['frr']['loop-free-alternate'] = line.split(' ').last if line.include?('loop-free-alternate ') && frr4_flag
            isis['frr']['ti-lfa'] = line.split(' ').last if line.include?('ti-lfa ') && frr4_flag
            (frr4_flag = false) if frr4_flag && line==' #'
            (isis['ipv6-frr'] = {}; frr6_flag = true) if line.include?('ipv6 frr')
            isis['ipv6-frr']['loop-free-alternate'] = line.split(' ').last if line.include?('loop-free-alternate ') && frr6_flag
            isis['ipv6-frr']['ti-lfa'] = line.split(' ').last if line.include?('ti-lfa ') && frr6_flag
            (frr6_flag = false) if frr6_flag && line==' #'
            isis['topology'] = line.split('topology ').last.strip if line.include?('ipv6 enable topology ')
            isis['ipv6-advertise'] = 'link-attributes' if line.include?('ipv6 advertise link attributes')
            isis['ipv6-traffic-eng'] = line.split(' ').last if line.include?('ipv6 traffic-eng')
            if line.include?('ipv6 metric-delay')
                isis['ipv6-metric-delay'] ||= {}
                isis['ipv6-metric-delay']['advertisement'] = line.split(' ').last if line.include?('advertisement enable')
                if line.include?('suppress')
                    words = line.split(' ')
                    isis['ipv6-metric-delay']['suppress'] ||= {}
                    isis['ipv6-metric-delay']['suppress']['timer'] = words[words.index('timer')+1]+'s' if words.index('timer')
                    isis['ipv6-metric-delay']['suppress']['percent-threshold'] = words[words.index('percent-threshold')+1]+'%' if words.index('percent-threshold')
                    isis['ipv6-metric-delay']['suppress']['absolute-threshold'] = words[words.index('absolute-threshold')+1]+'ms' if words.index('absolute-threshold')
                end
            end
            if line.include?('segment-routing ipv6 locator')
                isis['srv6-locator'] ||= {}
                isis['srv6-locator']['name'] = line.split('locator').last.strip.split(' ').first
                isis['srv6-locator']['auto-sid-disable'] = true if line.split('locator').last.strip.split(' ')[1]
            end
        end
        return isis
    end
end
```
