mode_switch = 5
cfg_led = 12

gpio.mode(cfg_led, gpio.OUTPUT)
gpio.write(cfg_led, gpio.LOW)

gpio.mode(mode_switch, gpio.INPUT)

if gpio.read(mode_switch) == 0 then
    dofile("weather_station.lua")
end

if gpio.read(mode_switch) == 1 then
    dofile("configurator.lua")
end
