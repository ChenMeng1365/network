#coding:utf-8

=begin # How To Use
  ip,mask = IP.v4('10.37.214.42/17')
  net = ip.network_with(mask)
  p ip.to_b, mask.to_b, net.to_b
  p ip.is_mask?, mask.is_mask?, net.is_network_with?(mask)
  si,ei = ip.range_with(mask)
  p si.to_d, ei.to_d, si.to_b, ei.to_b
  
  a = IP.v4('10.37.214.21/8')[0]
  b = IP.v4('145.217.33.14/16')[0]
  c = IP.v4('221.25.43.72/24')[0]
  d = IP.v4('238.13.189.51')
  e = IP.v4('246.211.74.63')
  p a.is_class_a?, b.is_class_b?, c.is_class_c?, d.is_class_d?, e.is_class_e?
  p a.is_private?, b.is_private?
=end

class IPv4
  attr_reader :numbers,:number
  
  def mode string
    if ['0b','0x','0d'].include?(string[0..1])
      return string[2..-1],string[0..1]
    else
      return string,'0d'
    end
  end

  def formmat string,mode
    string.split('.').collect{|num|eval("#{mode}#{num}")}
  end

  def check num
    return (0<=num && num<=255) ? true : false
  end
  
  def checks nums
    each = eval(nums.collect{|num|check(num).to_s}.join(' && '))
    all = (nums.size == 4)
    return each && all
  end
  
  def generate string
    (warn "Abnormal formmat string #{string}!";return nil) unless /[0b|0d|0x]?(\d+)\.(\d+)\.(\d+)\.(\d+)/.match(string)
    @content,@mode = mode(string)
    fours = formmat(@content,@mode)
    if checks(fours)
      @numbers = fours.clone
      @number = eval("0b"+to_b.gsub('.',''))
    else
      warn "Abnormal decimal string #{string}!";return nil
    end
    return self
  end
  
  def initialize string
    generate string
  end
  
  #### performance ####
  def to_a
    @numbers
  end

  def to_d
    @numbers.collect{|n|n.to_s(10)}.join"."
  end
  
  def to_h
    @numbers.collect{|n|"%02x"%n}.join"."
  end
  
  def to_b
    @numbers.collect{|n|"%08b"%n}.join"."
  end

  def to_s # s = short
    to_d
  end
  
  def + num
    @number += num
    generate("0b"+("%032b" % @number).unpack("a8a8a8a8").join("."))
  end
  
  def - num
    @number -= num
    generate("0b"+("%032b" % @number).unpack("a8a8a8a8").join("."))
  end

  def & another
    target = nil
    target = another if another.is_a?(IPv4)
    target = IPv4Mask.number(another) if another.is_a?(Integer)
    return self unless target
    newaddr = []
    self.numbers.each_with_index do|number, index|
      newaddr << (number & target.numbers[index])
    end
    return IP.v4(newaddr.join('.'))
  end
  
  def delegation base_pref, sub_pref
    base_len = base_pref.is_a?(IPv4) ? base_pref.mask_counter : base_pref.is_a?(Integer) ? base_pref : nil
    sub_len  = sub_pref.is_a?(IPv4)  ? sub_pref.mask_counter  : sub_pref.is_a?(Integer)  ? sub_pref  : nil
    return [] unless base_len && sub_len
    return [] unless base_len < sub_len
    return [] unless base_len <= 32 && sub_len <= 32
    base = self & base_len
    pref = IPv4Mask.number sub_len
    return (0..(2**(sub_len - base_len)-1)).to_a.map do|i|
      new_subnet = base.clone
      new_subnet + (i << (32-sub_len))
      [new_subnet, pref]
    end
  end

  def is_class_a?
    first =IPv4.new('10.0.0.0').number
    last = IPv4.new('126.255.255.255').number
    (first..last).include?(@number)
  end
  
  def is_class_b?
    first =IPv4.new('128.1.0.0').number
    last = IPv4.new('191.255.255.255').number
    (first..last).include?(@number)
  end
  
  def is_class_c?
    first =IPv4.new('192.0.1.0').number
    last = IPv4.new('223.255.255.255').number
    (first..last).include?(@number)
  end
  
  def is_class_d?
    first =IPv4.new('224.0.0.0').number
    last = IPv4.new('239.255.255.255').number
    (first..last).include?(@number)
  end
  
  def is_class_e?
    first =IPv4.new('240.0.0.0').number
    last = IPv4.new('255.255.255.254').number
    (first..last).include?(@number)
  end
  
  def is_private?
    fpa =IPv4.new('10.0.0.0').number
    lpa = IPv4.new('10.255.255.255').number
    fpb =IPv4.new('172.16.0.0').number
    lpb = IPv4.new('172.31.255.255').number
    fpc =IPv4.new('192.168.0.0').number
    lpc = IPv4.new('192.168.255.255').number
    (fpa..lpa).include?(@number) || (fpb..lpb).include?(@number) ||
    (fpc..lpc).include?(@number)
  end
  
  def is_another?
    [IPv4.new('127.0.0.1').number, IPv4.new('255.255.255.255').number,
     IPv4.new('0.0.0.0').number].include?(@number)
  end
  
  #### mask ####
  def mask_counter
    if is_mask?
      counter,msk = 0,to_b.gsub('.','')
      while msk[-1]=='0'; counter += 1; msk = msk[0..-2]; end
      return 32-counter
    else
      return nil
    end
  end
  
  def anti_mask_counter
    if is_anti_mask?
      counter,msk = 0,to_b.gsub('.','')
      while msk[-1]=='1'; counter += 1; msk = msk[0..-2]; end
      return counter
    else
      return nil
    end
  end
  
  def anti_mask
    if (counter = mask_counter)
      IPv4Mask.anti_number(counter)
    else
      warn "Not a net mask #{self}!";nil
    end
  end
  
  def mask
    if (counter = anti_mask_counter)
      IPv4Mask.number(counter)
    else
      warn "Not an anti-mask #{self}!";nil
    end
  end
  
  def is_mask?
    !to_b.gsub('.','').include?('01')
  end
  
  def is_anti_mask?
    !to_b.gsub('.','').include?('10')
  end
  
  #### network ####
  def network_with mask
    numbers = []
    mask.numbers.each_with_index do|num,index|
      numbers << (num & @numbers[index]).to_s
    end
    IPv4.new(numbers.join('.'))
  end
  
  def range_with mask
    return self, self if mask.mask_counter.to_i == 32
    net = network_with(mask)
    (start_ip = net.clone) + 1
    (end_ip = net.clone) + (2**(32-mask.mask_counter.to_i) - 1)
    return start_ip,end_ip
  end
  
  def is_network_with? mask
    msk_counter,msk = 0,mask.to_b.gsub('.','')
    while msk[-1]=='0'
      msk_counter += 1
      msk = msk[0..-2]
    end
    nt_counter,nt = 0,to_b.gsub('.','')
    while nt[-1]=='0'
      nt_counter += 1
      nt = nt[0..-2]
    end
    return (nt_counter >= msk_counter) ? true : false
  end

  def prefix_with another_ip
    ip1 = self.to_b.gsub('.','')
    ip2 = another_ip.to_b.gsub('.','')
    count = 0
    count += 1 while ip1[count] == ip2[count] && count < 32
    return count
  end
end

class IPv4Mask
  def self.number num
    str = "0b"+("1"*num+"0"*(32-num)).unpack("a8a8a8a8").join(".")
    IPv4.new(str)
  end
  
  def self.string str
    temp = IPv4.new(str)
    unless temp.is_mask?
      raise "Invalid net mask #{str}!"
      return nil
    else
      return temp
    end
  end
  
  def self.anti_number num
    str = "0b"+("0"*num+"1"*(32-num)).unpack("a8a8a8a8").join(".")
    IPv4.new(str)
  end
  
  def self.anti_string str
    temp = IPv4.new(str)
    unless temp.is_anti_mask?
      raise "Invalid anti mask #{str}!"
      return nil
    else
      return temp
    end
  end
end

module IP
  def self.v4 string
    ip,msk = string.split("/")
    unless msk
      return IPv4.new(ip)
    else
      mask = msk.include?('.') ? IPv4Mask.string(msk) : IPv4Mask.number(msk.to_i)
      return IPv4.new(ip),mask
    end
  end
end
