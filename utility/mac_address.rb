#coding:utf-8

class MacAddress
  attr_reader :numbers,:number
  
  def full? sequence
    (sequence.size!=3 && sequence.size!=6) ? false : true
  end

  def overflow? sequence,unit
    max = 0
    max = 65535 if sequence.size==3
    max = 255 if sequence.size==6
    return false if unit.to_i>max
    return true
  end

  def valid? sequence
    return "MAC地址长度错误(#{sequence.join('-')})!" unless full?(sequence)
    sequence.each do|unit|
      if unit.instance_of?(Numeric)
        overflow = overflow?(sequence,unit)
        return "MAC地址超出范围(#{sequence.join('-')})!" unless overflow
      else
        unit.to_s.each_char do|char|
          return "MAC地址含有不合法字符(#{sequence.join('-')})!" unless /[A-F|a-f|0-9]/.match(char)
        end
      end
    end
    return "合法MAC地址"
  end
  
  def calculate sequence
    size = (sequence.size==3) ? (4):(2)
    optr,result = "%0#{size}x",[]
    sequence.each do|unit|
      result << ( optr % eval("0x"+unit) ) if unit.is_a?(String)
      result << ( optr % unit ) if unit.is_a?(Numeric)
    end
    result
  end
  
  def == another
    @number == another.number
  end
  
  def initialize sequence
    @numbers = []
    valid = valid?(sequence)
    if valid =="合法MAC地址"
      @numbers = calculate(sequence)
      @number = eval("0x"+@numbers.join)
    else
      warn valid
    end
  end
  
  def writing number=3,splitter='-'
    number = 6 if number>=6
    @numbers.each_slice(6/number.to_i).collect{|pile|pile.join}.join(splitter)
  end

end

module MAC
  def self.address sequence,def_splt='-'
    seq = if sequence.is_a?(String)
      splitter = '-' if sequence.include?('-')
      splitter = '.' if sequence.include?('.')
      splitter = def_splt unless def_splt==splitter
      sequence.split(splitter)
    else
      sequence
    end
    MacAddress.new(seq)
  end
end
