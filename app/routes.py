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


@app.route('/event_created')
def event_created():
    """ return data for created events """
    event_data = {
        'title': 'Sample Event',
        'date': '2023-12-31',
        'location': 'Sample Location',
        'organizer': 'John Doe'
    }

    return render_template('event_created.html', event_data=event_data)


@app.route('/rsvp', methods=['GET', 'POST'])
def rsvp():
    """ RSVP to the event """
    if request.method == 'POST':
        """ Process the RSVP form data """
        rsvp_data = {
            'name': request.form.get('name'),
            'email': request.form.get('email'),
            'guests': request.form.get('guests')
        }

        return render_template('rsvp.html', rsvp_data=rsvp_data)

    return render_template('rsvp.html')


@app.route('/api/sample')
def sample_api():
    """ sample endpoint """
    data = {'message': 'Hello, this is a sample API endpoint!'}
    return jsonify(data)

