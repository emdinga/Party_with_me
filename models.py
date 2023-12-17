#!/usr/bin/python3
<<<<<<< HEAD
=======
""" creating models """

>>>>>>> f41c80e25a03f11846dabbff102f310ca9e25543

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Event(db.Model):
<<<<<<< HEAD
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    date = db.Column(db.String(20), nullable=False)
    location = db.Column(db.String(255), nullable=False)
    organizer = db.Column(db.String(255), nullable=False)

class RSVP(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), nullable=False)
    guests = db.Column(db.Integer, nullable=False)
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)
    event = db.relationship('Event', backref=db.backref('rsvps', lazy=True))

=======
	""" creating event database"""
	id = db.Column(db.Integer, primary_key=True)
	title = db.Column(db.String(255), nullable=False)
	date = db.Column(db.String(20), nullable=False)
	location = db.Column(db.String(255), nullable=False)
	organizer = db.Column(db.String(255), nullable=False)

class RSVP(db.Model):
	""" creating rsvp database """
	id = db.Column(db.Integer, primary_key=True)
	name = db.Column(db.String(255), nullable=False)
	email = db.Column(db.String(255), nullable=False)
	guests = db.Column(db.Integer, nullable=False)
	event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)
	event = db.relationship('Event', backref=db.backref('rsvps', lazy=True))
>>>>>>> f41c80e25a03f11846dabbff102f310ca9e25543
