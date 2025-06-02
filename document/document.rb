#coding:utf-8
uses 'CasetDown/casetdown','uuid', 'pathname'

class String
  def refine *flags,&cond
    path = self[-3..-1]=='.md' ? self : self+'.md'
    unless flags.include?(:active)
      gem_path = Pathname.new(__FILE__).realpath.join('..', '..')
      path = gem_path.join('.', path)
    end
    if File.exist?(path)
      cds = CasetDown.load path
    else
      warn "File #{path} not exist.";exit
    end
    codes = CasetDown::Check.all(cds).select{|segment|segment[:name]=='code' && segment[:class]=='ruby' && (cond ? cond.call(segment[:code]) : true) }
    return codes.map{|s|s[:code].gsub("&lt;",'<').gsub('&gt;','>').gsub('&amp;','&')}
  end
end

class Array
  def run &proc
    self.each do|code|
      proc.call code
    end
  end
end