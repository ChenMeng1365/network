
# ME60-X16 License

```ruby
@sign << ['ME60-X16', 'license']

module ME60_X16
  module_function

  def license 报文
    license = {}
    if 报文.include?('----') # 0: pre 1: head 2: body
      list = 报文.split('--------------------------------------------------------------------------------')[2].split("\n").map{|line|line.split(" ")}.select{|s|!s.empty?}
    elsif 报文.include?('FeatureName')
      list = 报文.split(" FeatureName    | ConfigureItemName       | ResourceUsage\n")[1].split("\n<")[0].split("\n").select{|s|!s.empty?}.map{|line|line.split(" ")}
    else
      list = [] # collect error!
    end
    list.each do|item|
      feature, conf_item, res_usage = item
      license[feature] ||= {}
      license[feature][conf_item] = res_usage.split('/').map{|c|c.to_i}
    end
    return license
  end
end
```