data = "submit?wifi_ssid=&wifi_pass=&broker_addr=&broker_port=&node_name= HTTP/1.1"

a = string.match(data, "?(.-%s)")
print(a)

for i in string.gmatch(a,'&') do
   print(i)
end
