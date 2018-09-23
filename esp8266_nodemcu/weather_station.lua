-- signal LED
cfg_led = 12

-- I2C pins
id  = 0
sda = 1
scl = 2
ret = 0

node_name = "weather_imp_1"

-- WiFi configuration
wifi_ssid = "HeadQuarters"
wifi_pass = "no_leaf_clover"
WIFI_SIGNAL_MODE = wifi.PHYMODE_N

-- MQTT
broker_addr = "192.168.1.11"
broker_port = 1883
node_id = "node1"
main_topic = "weather"
temp_topic = "temp"
pres_topic = "pres"
hum_topic = "hum"

m = nil
mytimer = nil

-- user defined function: read from reg_addr content of dev_addr
function read_reg(dev_addr, reg_addr)
    i2c.start(id)
    ack = i2c.address(id, dev_addr, i2c.TRANSMITTER)
    print("ACK:", ack)
    i2c.write(id, reg_addr)
    i2c.stop(id)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.RECEIVER)
    c = i2c.read(id, 1)
    i2c.stop(id)
    print("Raw:", c)
    return c
end

function sensor_read()
   
        local T, P, H= bme280.read()
        local T_str = ""
        local P_str = ""
        local H_str = ""
        
        if T ~= nill
        then
            local Tsgn = (T < 0 and -1 or 1); 
            T = Tsgn*T
            print(string.format("Temperature: %s%d.%02d °C", Tsgn<0 and "-" or "", T/100, T%100))
            T_str = tostring(T/100) .. "." .. tostring(T%100)
        end

        if P ~= nill
        then
            print(string.format("Pressure:    %d.%03d hPa", P/1000, P%1000))
            P_str = tostring(P/1000) .. "." .. tostring(P%1000)
        end   

        if H ~= nill
        then
            print("Humidity:", H)
            print(string.format("Humidity:    %d.%03d %%", H/1000, H%1000))
            H_str = tostring(H/1000) .. "." .. tostring(H%1000)
        end  

        return T_str, P_str, H_str
end

function loop()
    gpio.write(cfg_led, gpio.HIGH)
    print("IP and shit:", wifi.sta.getip())
    print("Status:", wifi.sta.status())
    
    T, P, H = sensor_read()
    
    if wifi.sta.status() == wifi.STA_GOTIP
    then
        print("Sending")
        m:publish(main_topic .. "/" .. node_id .. "/" .. temp_topic, T, 0, 0);
        m:publish(main_topic .. "/" .. node_id .. "/" .. pres_topic, P, 0, 0);
        m:publish(main_topic .. "/" .. node_id .. "/" .. hum_topic, H, 0, 0);
    end

    gpio.write(cfg_led, gpio.LOW)
end

function wifi_connected()
    print("IP and shit:", wifi.sta.getip())
    -- initialize i2c, set pin1 as sda, set pin2 as scl
    i2c.setup(id, sda, scl, i2c.SLOW)
    ret = bme280.setup()
    print("BMP280 setup:", ret)
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, mqtt_start)
end

function periodic_pub()
    mytimer = tmr.create()
    mytimer:register(3000, tmr.ALARM_AUTO, loop)
    mytimer:start()
end

function mqtt_start()
    m = mqtt.Client(node_name, 120)
    -- register message callback beforehand
    m:on("connect", function(client) print ("connected") end)
    m:on("offline", function(client) print ("offline") end)
    -- Connect to broker
    m:connect(broker_addr, broker_port, function(client) periodic_pub() end) 
end

function param_update()
    file_obj = file.open("conf.json", "r")

    if file_obj ~= nil 
    then
        file_data = file.read()
        data = sjson.decode(file_data)
        
        if data["wifi_ssid"] ~= nil
        then
            wifi_ssid = data["wifi_ssid"]
        end

        if data["wifi_pass"] ~= nil
        then
            wifi_pass = data["wifi_pass"]
        end

        if data["broker_addr"] ~= nil
        then
            broker_addr = data["broker_addr"]
        end

        if data["broker_port"] ~= nil
        then
            broker_port = tonumber(data["broker_port"])
        end

        if data["node_name"] ~= nil
        then
            node_id = data["node_name"]
        end

        print("WiFi SSID: ", wifi_ssid)
        print("WiFi password: ", wifi_pass)
        print("Broker address: ", broker_addr)
        print("Broker port: ", broker_port)
        print("Node ID: ", node_id)
    end
end

-- START !!!

param_update()

gpio.mode(cfg_led, gpio.OUTPUT)
gpio.write(cfg_led, gpio.LOW)

station_cfg={}
station_cfg.ssid=wifi_ssid
station_cfg.pwd=wifi_pass
station_cfg.save=true

wifi.setmode(wifi.STATION) 
wifi.setphymode(WIFI_SIGNAL_MODE)
wifi.sta.config(station_cfg) 
wifi.sta.connect(wifi_connected())

