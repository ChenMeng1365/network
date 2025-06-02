#coding:utf-8

module Route
  module_function
  # [destination, netmask, gateway, interface, owner, priority, metric]
  
  def match candiroutes, ipv4,backup_size = 2
    backup_size < 0 and backup_size = 0
    backup_routing_table = []
    candiroutes.each do|pile|
      net, mask = pile[0], pile[1]
      l = ipv4.number >> (32-mask)
      r = net.number >> (32-mask)  
      l != r and next
      backup_routing_table << pile
    end
    backup_stack = backup_routing_table.map{|r|r[1]}.uniq.sort.reverse[0..(backup_size-1)]
    routing_table = backup_routing_table.select{|r|backup_stack.include? r[1]}.sort_by!{|r|r[1]}.reverse
  end
  
  def merge candiroutes
    merge_table = []
    candiroutes = candiroutes.map do|c|
      s = c[0].number
      e = c[0].number + 2**(32-c[1]) - 1
      c + [s, e, :yet]
    end
    candiroutes.each_with_index do|c, i|
      candiroutes[(i+1)..(-1)].each do |cc|
        cc[-1] == :bemerged and next
        merged = c[-3] <= cc[-3] && cc[-2] <= c[-2]
        bemerged = cc[-3] <= c[-3] && c[-2] <= cc[-2]
        if merged
          cc[-1] = :bemerged
        elsif !merged && bemerged
          c[-1] = :bemerged
          break
        end
      end
      merge_table << c[0..2] unless c[-1]==:bemerged
    end
    merge_table
  end
  
end

__END__
$:<<"."
require 'ipv4_address'

=begin
  ip = IP.v4('172.11.0.1')
  n1,m1 = IP.v4('172.8.0.0/13')
  n2,m2 = IP.v4('172.10.0.0/255.254.0.0')
  n2_5,m2_5 = IP.v4('172.10.0.0/255.254.0.0')
  n3,m3 = IP.v4('192.168.0.0/255.255.255.0')

  candiroutes = [ 
    [n1, m1.mask_counter, '1.1.1.1',:intf1, 'static', 1, 0],
    [n2, m2.mask_counter, '2.2.2.2',:intf2, 'static', 1, 0],
    [n3,m3.mask_counter, '3.3.3.3', :intf3, 'static', 0, 0],
    [n2_5,m2_5.mask_counter, '4.4.4.4',:intf4, 'static', 1, 0]
  ]

  pp Route.match candiroutes, ip
=end

=begin
  n1,m1 = IP.v4('172.8.0.0/13')
  n2,m2 = IP.v4('172.10.0.0/255.254.0.0')
  n3,m3 = IP.v4('192.168.0.0/255.255.255.0')

  candiroutes = [
    [n1, m1.mask_counter, '1.1.1.1', :intf, 'static', 1, 0],
    [n2, m2.mask_counter, '1.1.1.1', :intf, 'static', 1, 0],
    [n3, m3.mask_counter, '1.1.1.1', :intf, 'static', 1, 0]
  ]
  pp Route.merge candiroutes
=end