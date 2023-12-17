#!/usr/bin/python3
""" Start Flask application """
<<<<<<< HEAD

from flask import Flask, render_template, request, redirect, url_for, g
from flask_sqlalchemy import SQLAlchemy
=======


from flask import Flask, render_template, request, redirect, url_for, g
from flask_sqlalchemy import SQLAlchemy

>>>>>>> f41c80e25a03f11846dabbff102f310ca9e25543

app = Flask(__name__, static_folder='static', template_folder='templates')
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database/party.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
<<<<<<< HEAD

db = SQLAlchemy(app)

class Event(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    date = db.Column(db.String(10), nullable=False)
    location = db.Column(db.String(255), nullable=False)
    organizer = db.Column(db.String(255), nullable=False)

class RSVP(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)
    name = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), nullable=False)
    guests = db.Column(db.Integer, nullable=False)

=======

db = SQLAlchemy(app)

class Event(db.Model):
""" creating events db """
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    date = db.Column(db.String(10), nullable=False)
    location = db.Column(db.String(255), nullable=False)
    organizer = db.Column(db.String(255), nullable=False)

class RSVP(db.Model):
""" creating RSVP db """
    id = db.Column(db.Integer, primary_key=True)
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)
    name = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), nullable=False)
    guests = db.Column(db.Integer, nullable=False)

>>>>>>> f41c80e25a03f11846dabbff102f310ca9e25543
db.create_all()

@app.route('/')
def home():
    """ return home page for the application """
    return render_template('event_created.html')

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

        new_event = Event(**event_data)
        db.session.add(new_event)
        db.session.commit()

        return redirect(url_for('event_created'))

    return render_template('create_event.html')

@app.route('/event-created')
def event_created():
<<<<<<< HEAD
    """Return events created"""
    events = Event.query.all()

    """ Fetch RSVP counts for each event """
    rsvps_count = {}
    for event in events:
        rsvps_count[event.id] = RSVP.query.filter_by(event_id=event.id).count()

    return render_template('event_created.html', events=events, rsvps_count=rsvps_count)

=======
    """ return events created """
    events = Event.query.all()
    return render_template('event_created.html', events=events)

>>>>>>> f41c80e25a03f11846dabbff102f310ca9e25543
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

        event = Event.query.filter_by(title=title).first()
        if event:
            new_rsvp = RSVP(event_id=event.id, **rsvp_data)
            db.session.add(new_rsvp)
            db.session.commit()

        return redirect(url_for('event_created'))

    return render_template('rsvp.html', title=title)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

