#!/bin/bash

cd backend || exit
export FLASK_APP=app.py
export FLASK_ENV=development

echo "server start"
flask run &> flask.log &

echo $! > flask.pid

