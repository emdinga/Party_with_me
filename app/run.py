#!/usr/bin/python3
""" creating a migration of my db """

from app import app, db
from flask_migrate import Migrate


migrate = Migrate(app, db)
