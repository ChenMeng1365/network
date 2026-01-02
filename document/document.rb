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

module Doc
  module_function
  def build paths, option={} 
    # custom: :active, runtime: :runtime|:static, select: @sign
    params  = {custom: nil, runtime: :runtime, dir: nil}.merge(option)
    custom  = params[:custom]  # if custom then {custom: :active} else do nothing
    runtime = params[:runtime] # if runtime then {runtime: :runtime} else {runtime: :static}
    build   = ""
    @sign   = []
    paths.each do|path|
      codes = path.refine(custom) 
      codes.run{|code|eval(code)} if runtime==:runtime
      codes.map{|code|build<<code+"\n\n"} if runtime==:static
      if params[:dir] && runtime==:static
        Dir.mkdir('document') unless File.exist?('document')
        File.write path.gsub('.md','.rb'), codes.join("\n\n") 
      end
    end
    warning = $VERBOSE
    $VERBOSE = nil
    @sign.map{|ms|(eval "::#{ms[0].gsub('-','_')} = #{ms[0].gsub('-','_')}")}
    $VERBOSE = warning
    File.write "build.rb", build if !params[:dir] && runtime==:static
    return @sign
  end

  def load paths
    File.write "_@sign_.rb","@sign = []"
    require './_@sign_'
    File.delete "./_@sign_.rb"
    Kernel.instance_variable_set(:@sign,[])
    if paths.is_a?(Array)
      paths.each{|path|require "./"+path.gsub('.md','.rb')}
    else
      require "./"+paths.gsub('.md','.rb')
    end
    return @sign
  end

  def reload option={
      # runtime: :static, if use runtime: :runtime, wont make doc files
      # config: 'document.txt', each line is a path of reference module file
      # document: [], path set of original module files
      # expansion: [], path set of extension module files
    }
    parameters = {runtime: :static, config: 'document.txt'}.merge(option)
    if File.exist?(parameters[:config])
      paths = File.read(parameters[:config]).split("\n")
      Doc.build paths, runtime: :static, dir: :yes
      Doc.load paths
    end
    if parameters[:document] && File.exist?(parameters[:document])
      paths = parameters[:document]
      Doc.build paths, runtime: :static, dir: :yes
      Doc.load paths
    end
    if parameters[:expansion] && File.exist?(parameters[:expansion])
      paths = parameters[:expansion]
      Doc.build paths, custom: :active, runtime: :static, dir: :yes
      Doc.load paths
    end
  end

  def path
    Dir["#{$_DOC_PATH_}/document/*.md"].map{|d|d.split('/')[-2..-1].join("/")}
  end
end

$_DOC_PATH_ = Pathname.new(__FILE__).realpath.join('..', '..')
