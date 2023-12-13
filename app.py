#!/usr/bin/python3
""" debug app """

from flask import Flask, render_template


app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/create-event')
def create_event():
    return render_template('create_event.html')

@app.route('/event-created')
def event_created():
    return render_template('event_created.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
