
eval(DATA.read)

# snmpwalk -v 2c -c public 192.168.1.1 -O f 1.3.6.1.2.1.1 > walk.name.txt
# snmpwalk -v 2c -c public 192.168.1.1 -O n 1.3.6.1.2.1.1 > walk.oid.txt

mapping, document, report = SNMP::Resolve.construct(
	File.read('walk.name.txt').split("\n"), lambda{|n|n.include?('IF-MIB') && !n.include?('IF-MIB::ifNumber')},
	File.read('walk.oid.txt').split("\n"),  lambda{|n|n.include?('1.3.6.1.2.1.2.2.1')}
)

File.write 'reduce.mapping.json', JSON.pretty_generate(mapping)
File.write 'reduce.document.json', JSON.pretty_generate(document)
File.write 'reduce.report.json', JSON.pretty_generate(report)

__END__
require 'cc'
require 'network'
require 'json'

if_names = [ # "IF-MIB::ifNumber",
 "IF-MIB::ifIndex",
 "IF-MIB::ifDescr",
 "IF-MIB::ifType",
 "IF-MIB::ifMtu",
 "IF-MIB::ifSpeed",
 "IF-MIB::ifPhysAddress",
 "IF-MIB::ifAdminStatus",
 "IF-MIB::ifOperStatus",
 "IF-MIB::ifLastChange",
 "IF-MIB::ifInOctets",
 "IF-MIB::ifInUcastPkts",
 "IF-MIB::ifInDiscards",
 "IF-MIB::ifInErrors",
 "IF-MIB::ifInUnknownProtos",
 "IF-MIB::ifOutOctets",
 "IF-MIB::ifOutUcastPkts",
 "IF-MIB::ifOutDiscards",
 "IF-MIB::ifOutErrors"
]

if_oids = [ # "1.3.6.1.2.1.2.1.0",
 "1.3.6.1.2.1.2.2.1.1",
 "1.3.6.1.2.1.2.2.1.2",
 "1.3.6.1.2.1.2.2.1.3",
 "1.3.6.1.2.1.2.2.1.4",
 "1.3.6.1.2.1.2.2.1.5",
 "1.3.6.1.2.1.2.2.1.6",
 "1.3.6.1.2.1.2.2.1.7",
 "1.3.6.1.2.1.2.2.1.8",
 "1.3.6.1.2.1.2.2.1.9",
 "1.3.6.1.2.1.2.2.1.10",
 "1.3.6.1.2.1.2.2.1.11",
 "1.3.6.1.2.1.2.2.1.13",
 "1.3.6.1.2.1.2.2.1.14",
 "1.3.6.1.2.1.2.2.1.15",
 "1.3.6.1.2.1.2.2.1.16",
 "1.3.6.1.2.1.2.2.1.17",
 "1.3.6.1.2.1.2.2.1.19",
 "1.3.6.1.2.1.2.2.1.20"
]

module SNMP
	module Resolve
		module_function

		def contrast name_list, name_filter, oid_list, oid_filter
			name_filter = lambda{|n|true} if name_filter == :pass
			oid_filter  = lambda{|n|true} if oid_filter  == :pass
			names = name_list.map{|n|n.first.split('.').first}.uniq.select{|n|name_filter.call(n)}
			oids  = oid_list.map{|n|n.first.split('.')[0..-2].join('.')}.uniq.select{|n|oid_filter.call(n)}
			inst_list = name_list.select{|t|t.first.include?(names.first)}.map{|t|t.first.split('.').last}
			# inst_list2 = oid_list.select{|t|t.first.include?(oids.first+'.')}.map{|t|t.first.split('.').last} #=> inst_list.size == inst_list2.size
			return inst_list, names, oids
		end

		def instance insts, names, oids, name_dict, oid_dict
			mapping, document, report = {}, [], []
			insts.each do|inst|
				record = {}
				names.zip(oids) do|name, oid|
					field, index = "#{name}.#{inst}", "#{oid}.#{inst}"
					name_term = name_dict[field] || [] # p field if name_term.empty? # not all item have each attribute
					oid_term  = oid_dict[index]  || [] # p index if oid_term.empty?
					type = [name_term[1],oid_term[1]].uniq.join(',')
					value = [name_term[2],oid_term[2]].uniq.join(',')
					mapping[name] = [oid, type]
					document << [field, index, type, value ]
					record[name.split(':').last]=value
				end
				report << record
			end
			return mapping, document, report
		end

		def construct name_texts, name_filter, oid_texts, oid_filter
			name_list, name_dict = SNMP::Resolve.parse(name_texts, :all)
			oid_list, oid_dict = SNMP::Resolve.parse(oid_texts, :all)
			instances, if_names, if_oids = SNMP::Resolve.contrast(name_list, name_filter, oid_list, oid_filter)
			mapping, document, report = SNMP::Resolve.instance(instances, if_names, if_oids, name_dict, oid_dict)
			return mapping, document, report
		end
	end
end
