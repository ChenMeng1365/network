
# Nokia7750 pool

```ruby
@sign << ['Nokia7750', '地址池解析']
@sign << ['Nokia7750', 'nat地址配置']

module Nokia7750
  module_function

  def 地址池解析 配置散列
    _intfs, _subintfs, abpools, vpn_apply = self.接口关联 配置散列
    return (abpools + vpn_apply).select{|a|!a[-1].empty?}
  end

  def nat地址配置 配置散列
  end
  
end
```
