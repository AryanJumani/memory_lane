from flask import Flask, jsonify, request, session, send_from_directory
from flask_cors import CORS
from database import db, Users, Photos, Comments, Tags
from flask_session import Session
import os
from dotenv import load_dotenv
from sqlalchemy import text
import requests


load_dotenv()

app = Flask(__name__)
CORS(app, supports_credentials=True)

app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

app.config["SESSION_TYPE"] = "filesystem"
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_USE_SIGNER"] = True
app.config["SECRET_KEY"] = "supersecretkey"
db.init_app(app)
Session(app)


@app.route("/api/users", methods=["GET"])
def get_users():
    users = Users.query.all()
    return jsonify(
        [
            {"user_id": u.user_id, "username": u.username, "email": u.email}
            for u in users
        ]
    )


@app.route("/api/users/<int:user_id>", methods=["GET"])
def get_user(user_id):
    user = Users.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404
    return (
        jsonify(
            {
                "user_id": user.user_id,
                "username": user.username,
                "email": user.email,
                "password_hash": user.password_hash,
            }
        ),
        200,
    )


@app.route("/api/photos", methods=["POST"])
def upload_photo():
    user_id = request.form.get("user_id")
    latitude = request.form.get("latitude")
    longitude = request.form.get("longitude")
    photo_file = request.files.get("photo")

    if not user_id or not photo_file:
        return jsonify({"error": "Missing user ID or photo file"}), 400
    landmark_info = get_closest_landmark(latitude, longitude)
    landmark = landmark_info.get("landmark", None)
    filename = f"user_{user_id}_{photo_file.filename}"
    filepath = os.path.join("uploads", filename)
    photo_file.save(filepath)
    db.session.execute(
        text("CALL UploadPhoto(:user_id, :photo_url, :latitude, :longitude, :landmark)"),
        {
            "user_id": user_id,
            "photo_url": filepath,
            "latitude": latitude,
            "longitude": longitude,
            "landmark": landmark,
        },
    )
    db.session.commit()
    return jsonify({"message": "Photo uploaded!"}), 201


@app.route("/api/users", methods=["POST"])
def add_user():
    data = request.json
    try:
        db.session.execute(
            text("CALL AddUser(:username, :email, :password_hash)"),
            {
                "username": data["username"],
                "email": data["email"],
                "password_hash": data["password"],
            },
        )
        db.session.commit()
        return jsonify({"message": "User added!"}), 201
    except Exception as e:
        db.session.rollback()
        print("Registration error:", e)
        return jsonify({"error": "Internal server error" + data}), 500


@app.route("/api/login", methods=["POST"])
def login():
    data = request.json
    user = Users.query.filter_by(username=data["username"]).first()

    if not user or user.password_hash != data["password"]:
        return jsonify({"error": "Invalid username or password"}), 401  # Unauthorized

    session["user_id"] = user.user_id  # Store user ID in session
    session["username"] = user.username
    return jsonify({"message": "Login successful!", "user_id": user.user_id}), 200


@app.route("/api/logout", methods=["POST"])
def logout():
    session.clear()  # Clears user session
    return jsonify({"message": "Logged out successfully"}), 200


@app.route("/api/check_auth", methods=["GET"])
def check_auth():
    if "user_id" in session:
        return jsonify(
            {
                "authenticated": True,
                "user_id": session["user_id"],
                "username": session["username"],
            }
        )
    print(session)
    return jsonify({"authenticated": False}), 401


@app.route("/api/users/<int:user_id>", methods=["PUT"])
def update_user(user_id):
    data = request.json
    user = None if data.get("username") == "" else data.get("username")
    email = None if data.get("email") == "" else data.get("email")
    pwd_hash = None if data.get("password") == "" else data.get("password")
    db.session.execute(
        text("CALL UpdateUser(:user_id, :username, :email, :password_hash, @status)"),
        {
            "user_id": user_id,
            "username": user,
            "email": email,
            "password_hash": pwd_hash,
        },
    )

    status = db.session.execute(text("SELECT @status")).scalar()
    if status == 404:
        return jsonify({"error": "User not found"}), 404
    db.session.commit()
    return jsonify({"message": "User updated!"}), 200


@app.route("/api/users/<int:user_id>", methods=["DELETE"])
def remove_user(user_id):
    db.session.execute(text("CALL RemoveUser(:user_id, @status)"), {"user_id": user_id})
    status = db.session.execute(text("SELECT @status")).scalar()
    if status == 404:
        return jsonify({"error": "User not found"}), 404
    db.session.commit()
    return jsonify({"message": "User removed!"}), 200


@app.route("/api/comments", methods=["POST"])
def add_comment():
    data = request.json
    db.session.execute(
        text("CALL AddComment(:photo_id, :user_id, :comment)"),
        {
            "photo_id": data["photo_id"],
            "user_id": data["user_id"],
            "comment": data["comment"],
        },
    )
    db.session.commit()
    return jsonify({"message": "Comment added!"}), 201


@app.route("/api/comments/<int:comment_id>", methods=["DELETE"])
def remove_comment(comment_id):
    db.session.execute(
        text("CALL RemoveComment(:comment_id, @status)"), {"comment_id": comment_id}
    )
    status = db.session.execute("SELECT @status").scalar()
    if status == 404:
        return jsonify({"error": "Comment not found"}), 404
    db.session.commit()
    return jsonify({"message": "Comment removed!"}), 200


@app.route("/api/comments/<int:photo_id>", methods=["GET"])
def get_comments_of_photo(photo_id):
    comments = Comments.query.filter_by(photo_id=photo_id).all()
    if not comments:
        return jsonify({"message": "No comments found for this photo."}), 200

    return jsonify(
        [
            {
                "comment_id": c.comment_id,
                "user_id": c.user_id,
                "comment": c.comment,
                "timestamp": c.timestamp,
            }
            for c in comments
        ]
    )


@app.route("/uploads/<path:filename>")
def get_photo(filename):
    return send_from_directory("uploads", filename)


@app.route("/api/photos/user/<int:user_id>", methods=["GET"])
def get_photos_of_user(user_id):
    photos = (
        db.session.query(Photos, Users)
        .join(Users, Photos.user_id == Users.user_id)
        .filter(Photos.user_id == user_id)
        .all()
    )
    if not photos:
        return jsonify({"message": "No photos found for this user."}), 200

    return jsonify(
        [
            {
                "photo_id": p.photo_id,
                "photo_url": p.photo_url,
                "latitude": float(p.latitude) if p.latitude else None,
                "longitude": float(p.longitude) if p.longitude else None,
                "landmark": p.landmark,
                "timestamp": p.timestamp.isoformat(),
                "username": u.username,
            }
            for p, u in photos
        ]
    )


@app.route("/api/tags/<int:photo_id>", methods=["GET"])
def get_tags_of_photo(photo_id):
    tags = (
        db.session.query(Tags, Users.username)
        .join(Users, Tags.tagged_user == Users.user_id)
        .filter(Tags.photo_id == photo_id)
        .all()
    )
    return jsonify([
        {"username": username, "photo_id": t.photo_id}
        for t, username in tags
    ])

@app.route("/api/users/lookup", methods=["GET"])
def lookup_user():
    username = request.args.get("username")
    if not username:
        return jsonify({"error": "Missing username"}), 400

    user = Users.query.filter(Users.username==username.strip()).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    return jsonify({"user_id": user.user_id, "username": user.username}), 200

@app.route("/api/photos/<int:photo_id>", methods=["DELETE"])
def delete_photo(photo_id):
    db.session.execute(
        text("CALL DeletePhoto(:photo_id, @status)"), {"photo_id": photo_id}
    )
    status = db.session.execute(text("SELECT @status")).scalar()
    if status == 404:
        return jsonify({"error": "Photo not found"}), 404
    db.session.commit()
    return jsonify({"message": "Photo deleted!"}), 200


@app.route("/api/tags", methods=["POST"])
def add_tag():
    data = request.json
    db.session.execute(
        text("CALL AddTag(:photo_id, :tagged_user)"),
        {"photo_id": data["photo_id"], "tagged_user": data["tagged_user"]},
    )
    db.session.commit()
    return jsonify({"message": "User tagged in photo!"}), 201


@app.route("/api/tags", methods=["DELETE"])
def remove_tag():
    data = request.json
    db.session.execute(
        text("CALL RemoveTag(:photo_id, :tagged_user, @status)"),
        {"photo_id": data["photo_id"], "tagged_user": data["tagged_user"]},
    )
    status = db.session.execute("SELECT @status").scalar()
    if status == 404:
        return jsonify({"error": "Tag not found"}), 404
    db.session.commit()
    return jsonify({"message": "Tag removed!"}), 200


@app.route("/api/photos/nearby", methods=["GET"])
def get_nearby_photos():
    latitude = request.args.get("latitude", type=float)
    longitude = request.args.get("longitude", type=float)
    radius = request.args.get("radius", default=10.0, type=float)
    if latitude is None or longitude is None:
        return jsonify({"error": "Latitude and longitude are required"}), 400
    if radius < 0:
        radius = 10

    conn = db.engine.raw_connection()
    try:
        cursor = conn.cursor()
        cursor.callproc("GetNearbyPhotos", [latitude, longitude, radius])

        results = []
        for result in cursor.stored_results():
            rows = result.fetchall()
            for row in rows:
                results.append(
                    {
                        "photo_id": row[0],
                        "user_id": row[1],
                        "photo_url": row[2],
                        "latitude": float(row[3]),
                        "longitude": float(row[4]),
                        "timestamp": row[5].isoformat(),
                        "distance_km": float(row[6]),
                        "username": row[7],
                        "landmark": row[8],
                    }
                )

        return jsonify(results)
    finally:
        cursor.close()
        conn.close()


@app.route("/api/health")
def health():
    return {"status": "ok"}

def get_closest_landmark(lat, long):
    try:
        username = os.getenv("GEONAMES_USERNAME")
        if not username:
            print("❌ GEONAMES_USERNAME not set in .env")
            return {"landmark": None}
        url = f"http://api.geonames.org/findNearbyWikipediaJSON?lat={lat}&lng={long}&username={username}"
        response = requests.get(url, timeout=5)
        if response.status_code != 200:
            print(f"❌ GeoNames API error: {response.status_code}")
            return {"landmark": None}
        data = response.json()
        if "geonames" in data and len(data["geonames"]) > 0:
            return {"landmark": data["geonames"][0]["title"]}

        return {"landmark": None}
    except Exception as e:
        print("⚠️ Error in get_closest_landmark:", e)
        return {"landmark": None}



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
