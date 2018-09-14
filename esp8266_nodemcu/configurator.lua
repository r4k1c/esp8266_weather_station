node_name = "weather_imp_1"

cfg_led = 12

-- WiFi configuration
wifi_ssid = "HeadQuarters"
wifi_pass = "no_leaf_clover"

-- MQTT
broker_address = "192.168.1.11"
broker_port = 1883
node_id = "node1"

function split_string(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function print_table(table)
    for i,t in ipairs(b) do
        print(t)
    end
end

function SendHTML(sck) -- Send LED on/off HTML page
    file.open("configurator.html")
    htmlstring = file.read()
    sck:send(htmlstring)
end

function handle_submit(sck, data)
    print(data)
end

function save_to_json(data)
    a = {}

-- what if pass contains =
    for i,t in ipairs(data) do
        b = split_string(t, '=')
        a[b[1]] = b[2]
    end

    print("Dick: ", a)

    json = sjson.encode(a)
    print(json)
end

function receiver(sck, data)
    a = string.match(data, "?(.-%s)")
    if a ~= nil
    then
        b = split_string(a,'&')
        print_table(b)
        save_to_json(b)
    end
    SendHTML(sck)
end

wifi.setmode(wifi.SOFTAP)   -- set AP parameter
config = {}
config.ssid = "WS_configurator"
config.pwd = "12345678"
wifi.ap.config(config)

config_ip = {}  -- set IP,netmask, gateway
config_ip.ip = "192.168.2.1"
config_ip.netmask = "255.255.255.0"
config_ip.gateway = "192.168.2.1"
wifi.ap.setip(config_ip)

gpio.mode(cfg_led, gpio.OUTPUT)
gpio.write(cfg_led, gpio.HIGH)

server = net.createServer(net.TCP) -- create TCP server

b = split_string("jebeno,kaj,koji,kurac", ',')
print_table(b)

if server then
  server:listen(80, function(conn)-- listen to the port 80
  conn:on("receive", receiver)
  end)
end

