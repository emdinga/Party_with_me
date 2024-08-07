#!/usr/bin/python3
""" Start Flask application """

import os
from itsdangerous import URLSafeTimedSerializer
from werkzeug.utils import secure_filename
from flask import Flask, render_template, request, redirect, url_for, g, flash, session, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from werkzeug.security import generate_password_hash, check_password_hash
from models import Event, RSVP, db, User, PasswordResetToken, Feedback
from flask_login import login_required, current_user
from flask_mail import Mail, Message
from datetime import datetime

app = Flask(__name__)
app.config['MAIL_SERVER'] = 'smtp.your-email-provider.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = 'your-email@example.com'
app.config['MAIL_PASSWORD'] = 'your-email-password'
app.config['UPLOAD_FOLDER'] = 'static/uploads'
app.secret_key = '123456789'

mail = Mail(app)

"""SQLite DB configuration"""
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///party_with_me.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

"""Initialize the database"""
db.init_app(app)
migrate = Migrate(app, db)

"""Define the upload folder"""
UPLOAD_FOLDER = 'static/uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

"""Create tables if they don't exist"""
@app.before_first_request
def create_tables():
    db.create_all()

@app.route('/about')
def about():
    """ defining the about page"""
    return render_template("about.html")

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    """ Define signup page """
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']
        confirm_password = request.form['confirm-password']

        """Check if passwords match"""
        if password != confirm_password:
            flash('Passwords do not match')
            return redirect(url_for('signup'))

        """Check if email already exists"""
        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            flash('Email already registered. Please use a different email.')
            return redirect(url_for('signup'))

        """Proceed with creating the new user"""
        hashed_password = generate_password_hash(password, method='sha256')
        new_user = User(username=username, email=email, password=hashed_password)
        db.session.add(new_user)
        db.session.commit()
        return redirect(url_for('login'))

    return render_template('signup.html')
@app.route('/login', methods=['GET', 'POST'])
def login():
    """ defining login page"""
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')

        if not email or not password:
            flash('Please provide both email and password')
            return redirect(url_for('login'))

        user = User.query.filter_by(email=email).first()

        if user and check_password_hash(user.password, password):
            """Store the username in the session"""
            session['username'] = user.username  
            return redirect(url_for('members_home'))
        else:
            flash('Invalid credentials')
            return redirect(url_for('login'))

    return render_template('login.html')

@app.route('/forgot_password', methods=['GET', 'POST'])
def forgot_password():
    if request.method == 'POST':
        email = request.form.get('email')
        user = User.query.filter_by(email=email).first()

        if user:
            s = URLSafeTimedSerializer(app.config['SECRET_KEY'])
            token = s.dumps(email, salt='password-reset-salt')
            expiration = datetime.utcnow() + datetime.timedelta(hours=1)
            
            reset_token = PasswordResetToken(email=email, token=token, expiration=expiration)
            db.session.add(reset_token)
            db.session.commit()
            
            reset_link = url_for('reset_password', token=token, _external=True)
            msg = Message("Password Reset Request",
                          sender="noreply@example.com",
                          recipients=[email])
            msg.body = f"To reset your password, visit the following link: {reset_link}\nIf you did not make this request then simply ignore this email and no changes will be made."
            mail.send(msg)

        flash('If there is an account with that email, you will receive a password reset email shortly.')
        return redirect(url_for('login'))

    return render_template('forgot_password.html')

@app.route('/reset_password/<token>', methods=['GET', 'POST'])
def reset_password(token):
    try:
        s = URLSafeTimedSerializer(app.config['SECRET_KEY'])
        email = s.loads(token, salt='password-reset-salt', max_age=3600)
    except Exception:
        flash('The reset link is invalid or has expired.')
        return redirect(url_for('forgot_password'))

    if request.method == 'POST':
        password = request.form.get('password')
        confirm_password = request.form.get('confirm-password')

        if password == confirm_password:
            user = User.query.filter_by(email=email).first()
            if user:
                user.password = generate_password_hash(password, method='sha256')
                db.session.commit()
                flash('Your password has been updated!')
                return redirect(url_for('login'))
        else:
            flash('Passwords do not match.')

    return render_template('reset_password.html', token=token)

@app.before_request
def before_request():
    g.rsvps_count = {}
    events = Event.query.all()
    for event in events:
        g.rsvps_count[event.id] = RSVP.query.filter_by(event_id=event.id).count()

@app.route('/')
def home():
    """ Landing page: Show only public events """
    events = Event.query.filter_by(privacy='public').all()
    return render_template('index.html', events=events)

@app.route('/create_event', methods=['GET', 'POST'])
def create_event():
    if request.method == 'POST':
        title = request.form.get('title')
        date_str = request.form.get('date')
        location = request.form.get('location')
        poster = request.files.get('poster')
        privacy = request.form.get('privacy') 

        errors = []

        """Validate form inputs"""
        if not title:
            errors.append("Title is required.")
        if not date_str:
            errors.append("Date is required.")
        if not location:
            errors.append("Location is required.")
        if not privacy:
            errors.append("Privacy setting is required.")

        if errors:
            return render_template('create_event.html', errors=errors)

        """Ensure the upload directory exists"""
        if not os.path.exists(app.config['UPLOAD_FOLDER']):
            os.makedirs(app.config['UPLOAD_FOLDER'])

        filename = None
        if poster:
            filename = secure_filename(poster.filename)
            poster_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            poster.save(poster_path)

        """Convert date string to date object"""
        try:
            date = datetime.strptime(date_str, '%Y-%m-%d').date()
        except ValueError:
            errors.append("Invalid date format.")
            return render_template('create_event.html', errors=errors)

        """Save the event to the database"""
        new_event = Event(title=title, date=date, location=location, poster=filename, privacy=privacy)
        db.session.add(new_event)
        db.session.commit()

        return redirect(url_for('members_home'))

    return render_template('create_event.html')

@app.route('/event-created')
def event_created():
    events = Event.query.all()
    rsvps_count = {event.id: RSVP.query.filter_by(event_id=event.id).count() for event in events}
    return render_template('event_created.html', events=events, rsvps_count=rsvps_count)

@app.route('/rsvp/<title>', methods=['GET', 'POST'])
def rsvp(title):
    if request.method == 'POST':
        """Collect data from the form"""
        rsvp_data = {
            'name': request.form.get('name'),
            'email': request.form.get('email'),
            'guests': request.form.get('guests')
        }

        """Retrieve the event based on the title """
        event = Event.query.filter_by(title=title).first()
        if event:
            """Create a new RSVP and save to the database"""
            new_rsvp = RSVP(event_id=event.id, **rsvp_data)
            db.session.add(new_rsvp)
            db.session.commit()

        """Redirect to a different page after processing"""
        return redirect(url_for('event_created'))

    """Render the RSVP form template"""
    return render_template('rsvp.html', title=title)

def get_event_and_rsvps(event_id):
    event = Event.query.get(event_id)
    if event:
        rsvps = RSVP.query.filter_by(event_id=event.id).all()
        return event, rsvps
    return None, None

@app.route('/event_details/<int:event_id>')
@login_required
def event_details_view(event_id):
    """ View details of the event """
    event = Event.query.get_or_404(event_id)
    if event.owner_id != current_user.id:
        return redirect(url_for('index'))
    rsvps = RSVP.query.filter_by(event_id=event.id).all()
    return render_template('event_details.html', event=event, rsvps=rsvps)

@app.route('/event/<int:event_id>/update', methods=['POST'])
@login_required
def update_event(event_id):
    """ Update event details """
    event = Event.query.get_or_404(event_id)
    if event.owner_id != current_user.id:
        return redirect(url_for('index'))

    """Update event details from form"""
    event.title = request.form.get('title')
    event.date = request.form.get('date')
    event.location = request.form.get('location')
    event.rsvp_limit = request.form.get('rsvp_limit')
    event.announcements = request.form.get('announcements')
    """Handle file upload for poster image if needed"""
    db.session.commit()

    return redirect(url_for('event_details_view', event_id=event_id))

@app.route('/event/<int:event_id>/delete', methods=['POST'])
@login_required
def delete_event(event_id):
    """ Delete an event """
    event = Event.query.get_or_404(event_id)
    if event.owner_id != current_user.id:
        return redirect(url_for('index'))

    db.session.delete(event)
    db.session.commit()
    return redirect(url_for('index'))

@app.route('/event/<int:event_id>/rsvps')
@login_required
def view_rsvps(event_id):
    """ View RSVPs for an event """
    event = Event.query.get_or_404(event_id)
    if event.owner_id != current_user.id:
        return redirect(url_for('index'))

    rsvps = RSVP.query.filter_by(event_id=event_id).all()
    return render_template('rsvps.html', event=event, rsvps=rsvps)

@app.route('/about_members')
def about_members():
    """ About members page """
    return render_template("about_members.html")

@app.route('/logout')
def logout():
    """ Logout the user """
    session.pop('username', None) 
    return redirect(url_for('login'))

@app.route('/members_home')
def members_home():
    """ Members home page: Show only public events and user testimonials """
    events = Event.query.filter_by(privacy='public').all()
    future_events = [event for event in events if event.date >= datetime.now().date()]
    testimonials = Feedback.query.all()
    return render_template('members_home.html', events=future_events, testimonials=testimonials)


@app.route('/uploads/<filename>')
def uploaded_file(filename):
    """ Handle file uploads """
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

from flask import request, redirect, url_for, flash

@app.route('/submit_feedback', methods=['POST'])
def submit_feedback():
    """ handle feedback"""
    event_attended = request.form.get('event_attended')
    feedback = request.form.get('feedback')
    user_name = request.form.get('user_name')
    
    """Store feedback in the database"""
    new_feedback = Feedback(event_attended=event_attended, feedback=feedback, user_name=user_name)
    db.session.add(new_feedback)
    db.session.commit()
    
    flash('Thank you for your feedback!', 'success')
    return redirect(url_for('members_home'))


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000, debug=True)
