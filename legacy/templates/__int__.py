#!/usr/bin/python3
""" import database """


from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os



app = Flask(__name__)

db_path = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'site.db')
app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{db_path}'

db = SQLAlchemy(app)

