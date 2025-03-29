from flask import Flask, jsonify, request, session, send_from_directory
from flask_cors import CORS
from database import db, Users, Photos, Comments, Tags
from flask_session import Session
import os
from dotenv import load_dotenv
from sqlalchemy import text

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

    return jsonify(
        {"user_id": user.user_id, "username": user.username, "email": user.email}
    )


@app.route("/api/photos", methods=["POST"])
def upload_photo():
    user_id = request.form.get("user_id")
    latitude = request.form.get("latitude")
    longitude = request.form.get("longitude")
    photo_file = request.files.get("photo")

    if not user_id or not photo_file:
        return jsonify({"error": "Missing user ID or photo file"}), 400
    filename = f"user_{user_id}_{photo_file.filename}"
    filepath = os.path.join("uploads", filename)
    photo_file.save(filepath)
    db.session.execute(
        text("CALL UploadPhoto(:user_id, :photo_url, :latitude, :longitude)"),
        {
            "user_id": user_id,
            "photo_url": filepath,
            "latitude": latitude,
            "longitude": longitude,
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
    db.session.execute(
        text("CALL UpdateUser(:user_id, :username, :email, @status)"),
        {
            "user_id": user_id,
            "username": data.get("username"),
            "email": data.get("email"),
        },
    )

    status = db.session.execute("SELECT @status").scalar()
    if status == 404:
        return jsonify({"error": "User not found"}), 404
    db.session.commit()
    return jsonify({"message": "User updated!"}), 200


@app.route("/api/users/<int:user_id>", methods=["DELETE"])
def remove_user(user_id):
    db.session.execute(text("CALL RemoveUser(:user_id, @status)"), {"user_id": user_id})
    status = db.session.execute("SELECT @status").scalar()
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
                "timestamp": p.timestamp.isoformat(),
                "username": u.username,
            }
            for p, u in photos
        ]
    )


@app.route("/api/tags/<int:photo_id>", methods=["GET"])
def get_tags_of_photo(photo_id):
    tags = Tags.query.filter_by(photo_id=photo_id).all()
    if not tags:
        return jsonify({"message": "No tags found for this photo."}), 200

    return jsonify(
        [{"photo_id": t.photo_id, "tagged_user": t.tagged_user} for t in tags]
    )


@app.route("/api/photos/<int:photo_id>", methods=["DELETE"])
def delete_photo(photo_id):
    db.session.execute(
        text("CALL DeletePhoto(:photo_id, @status)"), {"photo_id": photo_id}
    )
    status = db.session.execute("SELECT @status").scalar()
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
    data = request.json
    result = db.session.execute(
        text(
            """
        CALL GetNearbyPhotos(:latitude, :longitude, :radius)
        """
        ),
        {
            "latitude": data["latitude"],
            "longitude": data["longitude"],
            "radius": data["radius"],
            # need to provide default val from flutter if no radius provided
        },
    )

    photos = result.fetchall()
    return jsonify(
        [
            {
                "photo_id": row[0],
                "user_id": row[1],
                "photo_url": row[2],
                "latitude": float(row[3]),
                "longitude": float(row[4]),
                "timestamp": row[5].isoformat(),
                "distance_km": float(row[6]),
            }
            for row in photos
        ]
    )


if __name__ == "__main__":
    app.run(debug=True)
