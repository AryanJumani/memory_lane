from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)


@app.route("/api/data")
def hello():
    return jsonify({"data": "Hello World!"})


if __name__ == "__main__":
    app.run(debug=True)
