#!/usr/bin/python3
""" start flask application """


from flask import Flask, render_template, request, redirect, url_for


app = Flask(__name__)

events = []

@app.route('/')
def home():
    """ return home page for the application """
    return render_template('index.html')

@app.route('/create-event', methods=['GET', 'POST'])
def create_event():
    """ return create event form """
    if request.method == 'POST':
        event_data = {
            'title': request.form.get('title'),
            'date': request.form.get('date'),
            'location': request.form.get('location'),
            'organizer': 'John Doe'
        }
        events.append(event_data)
        return redirect(url_for('event_created'))

    return render_template('create_event.html')

@app.route('/event-created')
def event_created():
    """ return events created """
    return render_template('event_created.html', events=events)

@app.route('/rsvp/<int:event_id>', methods=['GET', 'POST'])
def rsvp(event_id):
    """ allows rsvp """
    if request.method == 'POST':
        """ Process RSVP form data for the specified event """
        rsvp_data = {
            'name': request.form.get('name'),
            'email': request.form.get('email'),
            'guests': request.form.get('guests')
        }
        """Handle RSVP data for the event (you can store it as needed)"""
        return render_template('rsvp.html', event_id=event_id, rsvp_data=rsvp_data)

    return render_template('rsvp.html', event_id=event_id)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

