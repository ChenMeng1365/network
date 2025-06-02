#coding:utf-8

class WhiteList
  attr_reader :allowed

  def initialize path
    pubnet = JSON.parse File.read path
    @allowed = pubnet.inject([]) do|allowed,network|
      ip,mask = IP.v4(network.join('/'))
      start_ip,end_ip = ip.range_with(mask)
      allowed << [start_ip, end_ip]
      allowed
    end
    @allowed
  end

  def allow? ip
    @allowed.inject(false){|flag, range| flag || (range[0].number..range[1].number).include?(ip.number)}
  end
end

