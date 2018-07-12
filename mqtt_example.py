import paho.mqtt.client as mqtt
import os
from flask import Flask,render_template, request,json

broker_address = "127.0.0.1"

temp = 0
pres = 0
hum = 0

def on_message(client, userdata, message):
	global temp
	global pres
	global hum
    # print("message received " ,str(message.payload.decode("utf-8")))
    # print("message topic=",message.topic)
    # print("message qos=",message.qos)
    # print("message retain flag=",message.retain)
	if message.topic == "weather/node1/temp":
		print "Temperature: ", str(message.payload.decode("utf-8"))
		temp = message.payload.decode("utf-8")

	if message.topic == "weather/node1/pres":
		print "Pressure: ", str(message.payload.decode("utf-8"))
		pres = message.payload.decode("utf-8")

	if message.topic == "weather/node1/hum":
		print "Humidity: ", str(message.payload.decode("utf-8"))
		hum = message.payload.decode("utf-8")

app = Flask(__name__)

client = mqtt.Client("P1")

client.on_message=on_message
client.connect(broker_address)

client.loop_start()
client.subscribe("weather/#")

@app.route("/")
def hello():
    return "Welcome to Python Flask!"

@app.route('/signUp')
def signUp():
    return render_template('signUp.html')

@app.route('/signUpUser', methods=['POST'])
def signUpUser():
    user =  request.form['username'];
    password = request.form['password'];
    return json.dumps({'status':'OK','user':"jebach",'pass':password});    

@app.route('/gumbek', methods=['POST'])
def gumbek():
	print "AJAX Temperature: ", temp
	return json.dumps({'temp':temp, 'pres':pres, 'hum':hum})

if __name__ == "__main__":
    app.run(host='0.0.0.0')
