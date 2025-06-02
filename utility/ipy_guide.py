#coding:utf-8
# pip install IPy
import IPy

# Submodules
print(dir(IPy))

# IP Protocol Version
print(IPy.IP('0.0.0.0/0').version(),
  IPy.IP('::1/128').version() )

# Range, length, netmask, prefix, broadcast
ip_range = IPy.IP('192.168.1.0/25')
print(len(ip_range), ip_range.netmask(), ip_range.prefixlen(), ip_range.broadcast() )
for ip in ip_range:
  print(ip, ip.reverseName(), ip.strBin(), ip.strHex(), ip.strDec(), ip.v46map() )
print(IPy.IP('127.0.0.1').make_net('255.0.0.0'))
print(IPy.IP("192.168.1.0-192.168.1.255",make_net=True))
print(IPy.IP("192.168.1.1/255.255.255.0",make_net=True))

# Range print
# 0: single ip, 1: slash number, 2: full ip, 3: first-last
print(IPy.IP("192.168.10.0/24").strNormal())
for i in (0,1,2,3):
  print(IPy.IP("192.168.10.0/24").strNormal(i))

# include, overlap
print("192.168.101.1" in IPy.IP("192.168.100.0/24"),
  IPy.IP("192.168.100.0/23").overlaps("192.168.100.0/24") )
