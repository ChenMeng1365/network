
# NE40E-X8 流策略、路由策略

```ruby
@sign << ['NE40E-X8', 'traffic']
@sign << ['NE40E-X8', 'traffic_classifier']
@sign << ['NE40E-X8', 'traffic_behavior']
@sign << ['NE40E-X8', 'traffic_policy']

module NE40E_X8
  module_function

  def traffic conflist
    tc,tb,tp = ['traffic_classifier','traffic_behavior','traffic_policy'].map{|t|self.send(t,conflist)}
  end

  # {name => {classifier => [matchers], operator => opt}, ...}
  def traffic_classifier conflist
    tc = {}
    conflist['traffic'].each do|traffic|
      next unless traffic.include?('classifier')
      name,tab = nil,{'operator'=>''}
      traffic.split("\n").each do|line|
        if line.include?('traffic classifier ')
          tc[name] = tab
          name, opt, op = line.split(' ')[2..4]
          tab = {'operator'=>op}
        else
          matcher = line.split(' ')
          tab['classifier'] ||= []
          tab['classifier'] << matcher # sequences
        end
      end
      tc[name] = tab # last tc
      tc.delete(nil)
    end if conflist['traffic']
    return tc
  end

  # {name => [behaviors], ...}
  def traffic_behavior conflist
    tb = {}
    conflist['traffic'].each do|traffic|
      next unless traffic.include?('behavior')
      name,tab = nil,{'behavior'=>[]}
      traffic.split("\n").each do|line|
        if line.include?('traffic behavior ')
          tb[name] = tab
          name,tab = line.split(' ')[2],{'behavior'=>[]}
        else
          behavior = line.split(' ')
          tab['behavior'] << behavior # sequences
        end
      end
      tb[name] = tab # last tb
      tb.delete(nil)
    end if conflist['traffic']
    return tb
  end

  # {name => {policy => {classifier => [behavior,precedence], ...}, mode => mode}, ...}
  def traffic_policy conflist
    tp = {}
    conflist['traffic'].each do|traffic|
      next unless traffic.include?('policy')
      name,tab = nil,{'policy'=>{}}
      traffic.split("\n").each do|line|
        if line.include?('traffic policy ')
          tp[name] = tab
          name,tab = line.split(' ')[2],{'policy'=>{}}
        elsif line.include?('-mode')
          tab['mode'] = 'share-mode'
        elsif line.include?('statistics ')
          tab['statistics'] = line.split(' ')[1]
        else
          policy = line.split(' ')
          classifier, behavior, precedence = policy[1],policy[3],policy[5]
          tab['policy'].merge!({ classifier => (precedence ? [behavior,precedence] : [behavior]) }) # tree
        end
      end
      tp[name] = tab # last tb
      tp.delete(nil)
    end if conflist['traffic']
    return tp
  end
end
```