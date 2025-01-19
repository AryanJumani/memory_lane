.PHONY: all run_backend run_frontend stop

all: run_backend run_frontend

run_backend:
	python backend/app.py &

run_frontend:
	cd frontend && flutter run && cd ..
stop:
	pkill -f "python backend/app.py"