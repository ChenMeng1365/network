#coding:utf-8

module Network
  # 按网络归并地址段
  # [ [ network(x.x.x.x), netmask(x.x.x.x) ], ... ] >=> [ [ network(x.x.x.x), netmask(x.x.x.x) ], ... ]
  def self.merge raw_table
    min,max = 32,0
    nets = raw_table.map do|raw|
      bin = IP.v4(raw[0]).to_b.gsub('.','')
      num = IP.v4(raw[1]).mask_counter
      min = num if min >= num
      max = num if max <= num
      net = bin[0..(num-1)]
    end.sort_by{|net|net.size}.uniq # 按最短网络地址排序
    
    merge = []
    nets.each do|net|
      include = false
      merge << net
      merge.each do|sub|
        include = true if /^#{sub}/.match(net) && net!=sub
      end
      merge.delete(net) if include
    end # 网络地址匹配，仅保留最短网络地址
    
    diet_table = []
    merge.each do|sub|
      net = sub + "0"*(32-sub.size)
      ip = net.unpack("a8a8a8a8").map{|i|eval("0b"+i)}.join(".")
      network,netmask = IP.v4("#{ip}/#{sub.size}")
      diet_table << [network.to_d,netmask.to_d]
    end
    return diet_table
  end
end


__END__
$LOAD_PATH << "."
require 'ipv4_address'
require 'neatjson'

path = 'pubnet.json'
raw = JSON.parse File.read path
table = Network.merge raw
File.write path.gsub('.json','_merge.json'),JSON.pretty_generate(table)
