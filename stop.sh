#!/bin/bash

if [ -f backend/flask.pid ]; then
  PID=$(cat backend/flask.pid)
  echo "stop server with pid $PID"
  kill "$PID"
  rm backend/flask.pid
else
  echo "server process not found"
fi
