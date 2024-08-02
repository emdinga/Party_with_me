#!/usr/bin/python3
""" Start Flask application """

from flask import Flask, render_template, request, redirect, url_for, g, flash
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from werkzeug.security import generate_password_hash, check_password_hash
from models import Event, RSVP, User

app = Flask(__name__)
app.secret_key = '123456789'

""" SQLite DB Configuration"""
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///party_with_me.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

"""Initialize database and migration tool"""
db = SQLAlchemy(app)
migrate = Migrate(app, db)

@app.before_first_request
def create_tables():
    """Create database tables if they don't exist."""
    db.create_all()

@app.before_request
def before_request():
    """Generate RSVP counts before handling each request."""
    g.rsvps_count = {}
    events = Event.query.all()
    for event in events:
        g.rsvps_count[event.id] = RSVP.query.filter_by(event_id=event.id).count()

@app.route('/')
def home():
    """Return home page for the application."""
    events = Event.query.all()
    return render_template('index.html', events=events)

@app.route('/create-event', methods=['GET', 'POST'])
def create_event():
    """Handle event creation form."""
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
    """Display created events."""
    events = Event.query.all()
    rsvps_count = {event.id: RSVP.query.filter_by(event_id=event.id).count() for event in events}
    return render_template('event_created.html', events=events, rsvps_count=rsvps_count)

@app.route('/rsvp/<title>', methods=['GET', 'POST'])
def rsvp(title):
    """Handle RSVP form."""
    if request.method == 'POST':
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

@app.route('/event_details/<int:event_id>')
def event_details(event_id):
    """Display event details and RSVPs."""
    event, rsvps = get_event_and_rsvps(event_id)
    return render_template('event_details.html', event=event, rsvps=rsvps)

def get_event_and_rsvps(event_id):
    """Retrieve event and its RSVPs."""
    event = Event.query.get(event_id)
    if event:
        rsvps = RSVP.query.filter_by(event_id=event.id).all()
        return event, rsvps
    return None, None

@app.route('/about')
def about():
    """Display about page."""
    return render_template('about.html')

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    """Handle user signup."""
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']
        confirm_password = request.form['confirm-password']

        if password == confirm_password:
            hashed_password = generate_password_hash(password, method='sha256')
            new_user = User(username=username, email=email, password=hashed_password)
            db.session.add(new_user)
            db.session.commit()
            return redirect(url_for('login'))
    return render_template('signup.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Handle user login."""
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')

        if not email or not password:
            flash('Please provide both email and password')
            return redirect(url_for('login'))

        user = User.query.filter_by(email=email).first()
        if user and check_password_hash(user.password, password):
            return redirect(url_for('Members_home'))
        else:
            flash('Invalid credentials')
            return redirect(url_for('login'))
    return render_template('login.html')

@app.route('/forgot_password', methods=['GET', 'POST'])
def forgot_password():
    """Display forgot password page."""
    return render_template('forgot_password.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
