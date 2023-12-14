#!/usr/bin/python3
""" start flask application """


from flask import Flask, render_template, request, redirect, url_for, g


app = Flask(__name__, static_folder='static', template_folder='templates')

events = [
    {'id': 1, 'title': 'Birthday celebration', 'date': '2024-01-01', 'location': 'Durban South Africa', 
        'organizer': 'Emdinga Mbhamali'},
    {'id': 2, 'title': 'Pens down', 'date': '2023-12-31', 'location': 'Beach front', 'organizer': 'Emdinga Mbhamali'}]

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
        g.title = event_data['title']
        return redirect(url_for('event_created'))

    return render_template('create_event.html')

@app.route('/event-created')
def event_created():
    """ return events created """
    """Iterate over events and set 'title' in the g context"""
    for event in events:
        g.title = event['title']

    return render_template('event_created.html', events=events)

@app.route('/rsvp/<title>', methods=['GET', 'POST'])
def rsvp(title):
    """ allows rsvp """
    if request.method == 'POST':
        """ Process RSVP form data for the specified event """
        rsvp_data = {
            'name': request.form.get('name'),
            'email': request.form.get('email'),
            'guests': request.form.get('guests')
        }
        """Handle RSVP data for the event (you can store it as needed)"""
        rsvps = g.get('rsvps', {})
        rsvps[title] = rsvps.get(title, 0) + int(rsvp_data['guests'])
        g.rsvps = rsvps

        return redirect(url_for('event_created'))

    return render_template('rsvp.html', title=title)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

