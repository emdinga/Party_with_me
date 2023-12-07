#!/usr/bin/python3
""" Start Flask and include route to home"""

from flask import render_template, request, jsonify
from app import app


@app.route('/')
def home():
    """ return home page """
    return render_template('index.html')

@app.route('/create_event', methods=['GET', 'POST'])
def create_event():
    """ create event """
    if request.method == 'POST':
        """ Process the event creation form data"""
        event_data = {
            'title': request.form.get('title'),
            'date': request.form.get('date'),
            'location': request.form.get('location'),
            'organizer': 'John Doe'
        }

        return render_template('event_created.html', event_data=event_data)

    return render_template('create_event.html')

@app.route('/api/sample')
def sample_api():
    """ sample endpoint """
    data = {'message': 'Hello, this is a sample API endpoint!'}
    return jsonify(data)

