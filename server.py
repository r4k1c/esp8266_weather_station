import os
from flask import Flask,render_template, request,json

app = Flask(__name__)
 
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
	return json.dumps({'jebacina':20})

if __name__ == "__main__":
    app.run()