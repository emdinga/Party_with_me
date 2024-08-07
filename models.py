from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from flask_login import UserMixin

db = SQLAlchemy()

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), unique=True, nullable=False)
    email = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(150), nullable=False)

class Event(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(150), nullable=False)
    date = db.Column(db.Date, nullable=False)
    location = db.Column(db.String(255), nullable=False)
    privacy = db.Column(db.String(50), nullable=False)
    poster = db.Column(db.String(255), nullable=True) 
    announcements = db.Column(db.Text, nullable=True)
    rsvp_limit = db.Column(db.Integer, nullable=True)
    owner_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    owner = db.relationship('User', backref=db.backref('events', lazy=True))


class RSVP(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)
    name = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(150), nullable=False)
    guests = db.Column(db.Integer, nullable=True)
    event = db.relationship('Event', backref=db.backref('rsvps', lazy=True))

class PasswordResetToken(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(150), nullable=False)
    token = db.Column(db.String(200), nullable=False)
    expiration = db.Column(db.DateTime, nullable=False)

class Feedback(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    event_attended = db.Column(db.String(50), nullable=False)
    feedback = db.Column(db.Text, nullable=False)
    user_name = db.Column(db.String(100), nullable=False)

    def __repr__(self):
        return f'<Feedback {self.id}>'