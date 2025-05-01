from flask_sqlalchemy import SQLAlchemy

import os

db = SQLAlchemy()


class Users(db.Model):
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)


class Photos(db.Model):
    photo_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.user_id"), nullable=False)
    photo_url = db.Column(db.String(255), nullable=False)
    latitude = db.Column(db.Numeric(9, 6))
    longitude = db.Column(db.Numeric(9, 6))
    landmark = db.Column(db.String(255))
    timestamp = db.Column(db.DateTime, default=db.func.current_timestamp())


class Comments(db.Model):
    comment_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    photo_id = db.Column(db.Integer, db.ForeignKey("photo.photo_id"), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey("user.user_id"), nullable=False)
    comment = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, default=db.func.current_timestamp())


class Tags(db.Model):
    photo_id = db.Column(db.Integer, db.ForeignKey("photo.photo_id"), primary_key=True)
    tagged_user = db.Column(db.Integer, db.ForeignKey("user.user_id"), primary_key=True)
