#coding:utf-8

module SNMP
  module Resolve
    module_function

    def file path, rtype=:tree
      self.parse(File.read(path).split("\n"), rtype)
    end

    def parse texts, rtype=:tree
      list = texts.reduce([])do|list, line|
        if line.include?('=') && line.include?(': ')
          list << line
        else
          list[-1] += "\n#{line}"
        end
        list
      end
      result_list = list.map do|line|
        head, tail = line.split('=')
        type, val  = tail.to_s.split(': ')
        [(head[0]=='.' ? head[1..-1] : head).strip, type.to_s.strip, val.to_s.strip]
      end
      return result_list if rtype==:list
      result_tree = result_list.reduce({}){|tree,term|tree[term.first]=term;tree}
      if rtype==:tree
        return result_tree
      elsif rtype==:all
        return result_list, result_tree
      else
        return [], {}
      end
    end
  end
end