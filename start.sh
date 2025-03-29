#!/bin/bash

cd backend || exit
export FLASK_APP=app.py

echo "server start"
source venv/bin/activate
flask run &> flask.log &

echo $! > flask.pid

