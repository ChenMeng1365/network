#coding:utf-8

class IPv6
  attr_reader :numbers,:number
  
  def mode string
    return IPAddr.new(string).to_string,"0x"
  end
  
  def formmat string,mode='0x'
    string.split(':').collect{|num|eval("#{mode}#{num}")}
  end
  
  def check num
    return (0<= num && num <=0xffff) ? true : false
  end
  
  def checks nums
    each = eval(nums.collect{|num|check(num).to_s}.join(' && '))
    all = (nums.size == 8)
    return each && all
  end

  def generate string
    (raise "Abnormal formmat string #{string}!";return nil) unless /[0b|0d|0x]?[a-f|A-F|0-9|\:]*/.match(string)
    @content,@mode = mode(string)
    eights = formmat(@content,@mode)
    if checks(eights)
      @numbers = eights.clone
      @number = eval("0b"+to_b.gsub(':',''))
    else
      raise "Abnormal decimal string #{string}!";return nil
    end
    # just modify @content,@mode,@numbers, and @number
  end
  
  def initialize string
    generate string
  end
  
  #### performance ####
  def to_a
    @numbers
  end

  def to_d
    @numbers.collect{|n|n.to_s(10)}.join":"
  end
  
  def to_h
    @numbers.collect{|n|"%04x"%n}.join":"
  end
  
  def to_s # s = short
    IPAddr.new(@content).to_s
  end
  
  def to_b
    @numbers.collect{|n|"%016b"%n}.join":"
  end

  def + num
    @number += num
    generate(("%032x" % @number).unpack("a4a4a4a4a4a4a4a4").join(":"))
  end
  
  def - num
    @number -= num
    generate(("%032x" % @number).unpack("a4a4a4a4a4a4a4a4").join(":"))
  end

  def & another
    target = nil
    target = another if another.is_a?(IPv6)
    target = IPv6Mask.number(another) if another.is_a?(Integer)
    return self unless target
    newaddr = []
    self.numbers.each_with_index do|number, index|
      newaddr << "%04x"%(number & target.numbers[index])
    end
    result = IP.v6(newaddr.join(':'))
    return result
  end
  
  def delegation base_pref, sub_pref
    base_len = base_pref.is_a?(IPv6) ? base_pref.mask_counter : base_pref.is_a?(Integer) ? base_pref : nil
    sub_len  = sub_pref.is_a?(IPv6)  ? sub_pref.mask_counter  : sub_pref.is_a?(Integer)  ? sub_pref  : nil
    return [] unless base_len && sub_len
    return [] unless base_len < sub_len
    return [] unless base_len <= 128 && sub_len <= 128
    base = self & base_len
    pref = IPv6Mask.number sub_len
    return (0..(2**(sub_len - base_len)-1)).to_a.map do|i|
      new_subnet = base.clone
      new_subnet + (i << (128-sub_len))
      [new_subnet, pref]
    end
  end

  #### mask ####
  def mask_counter
    if is_mask?
      counter,msk = 0,to_b.gsub(':','')
      while msk[-1]=='0'; counter += 1; msk = msk[0..-2]; end
      return 128-counter
    else
      return nil
    end
  end
  
  def anti_mask_counter
    if is_anti_mask?
      counter,msk = 0,to_b.gsub(':','')
      while msk[-1]=='1'; counter += 1; msk = msk[0..-2]; end
      return counter
    else
      return nil
    end
  end
  
  def anti_mask
    if (counter = mask_counter)
      IPv6Mask.anti_number(counter)
    else
      warn "Not a net mask #{self}!";nil
    end
  end
  
  def mask
    if (counter = anti_mask_counter)
      IPv6Mask.number(counter)
    else
      warn "Not an anti-mask #{self}!";nil
    end
  end
  
  def is_mask?
    !to_b.gsub(':','').include?('01')
  end
  
  def is_anti_mask?
    !to_b.gsub(':','').include?('10')
  end
  
  #### network ####
  def network_with mask
    numbers = []
    mask.numbers.each_with_index do|num,index|
      numbers << (num & @numbers[index])
    end
    IPv6.new(numbers.collect{|n|"%0x"%n}.join(':'))
  end
  
  def range_with mask
    return self, self if mask.mask_counter.to_i == 128
    net = network_with(mask)
    (start_ip = net.clone) + 1
    (end_ip = net.clone) + (2**(128-mask.mask_counter.to_i) - 1)
    return start_ip,end_ip
  end
  
  def is_network_with? mask
    msk_counter,msk = 0,mask.to_b.gsub(':','')
    while msk[-1]=='0'
      msk_counter += 1
      msk = msk[0..-2]
    end
    nt_counter,nt = 0,to_b.gsub(':','')
    while nt[-1]=='0'
      nt_counter += 1
      nt = nt[0..-2]
    end
    return (nt_counter >= msk_counter) ? true : false
  end
  
  def prefix_with another_ip
    ip1 = self.to_b.gsub(':','')
    ip2 = another_ip.to_b.gsub(':','')
    count = 0
    count += 1 while ip1[count] == ip2[count] && count < 128
    return count
  end
end

class IPv6Mask
  def self.number num
    hex = "%032x"%eval("0b"+"1"*num+"0"*(128-num))
    str = hex.unpack("a4a4a4a4a4a4a4a4").join(":")
    IPv6.new(str)
  end

  def self.string str
    temp = IPv6.new(str)
    unless temp.is_mask?
      raise "Invalid net mask #{str}!"
      return nil
    else
      return temp
    end
  end
  
  def self.anti_number num
    hex = "%032x"%eval("0b"+"0"*num+"1"*(128-num))
    str = hex.unpack("a4a4a4a4a4a4a4a4").join(":")
    IPv6.new(str)
  end
  
  def self.anti_string str
    temp = IPv6.new(str)
    unless temp.is_anti_mask?
      raise "Invalid anti mask #{str}!"
      return nil
    else
      return temp
    end
  end
end

module IP
  def self.v6 string
    ip,msk = string.split("/")
    unless msk
      return IPv6.new(ip)
    else
      mask = msk.include?(':') ? IPv6Mask.string(msk) : IPv6Mask.number(msk.to_i)
      return IPv6.new(ip),mask
    end
  end
end
