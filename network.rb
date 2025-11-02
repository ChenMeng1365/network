#coding:utf-8

[
  'ipv4_address',
  'ipv6_address',
  'mac_address',
  'netmerge',
  'route',
  'whitelist'
].each{|mod|require "utility/#{mod}"}

[
  'snmp'
].each{|mod|require "support/#{mod}"}

[
  'document'
].each{|mod|require "document/#{mod}"}

[
  'open-uri'
].each{|mod|require mod}

module Network
  VERSION = '1.1.28'
end