from flask import Flask, request
import json
from db import db, Course, Review, User
import os
from scripts.pipeline_load_all import run_pipeline

app = Flask(__name__)
db_filename = "coursereview.db"
db_folder = "instance"

basedir = os.path.abspath(os.path.dirname(__file__))

app.config["SQLALCHEMY_DATABASE_URI"] = f"sqlite:///" + os.path.join(basedir, db_folder, db_filename)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

def success_response(data, code=200):
    return json.dumps(data), code

def failure_response(message, code=400):
    return json.dumps({"error": message}), code

db.init_app(app)
with app.app_context():
    db.create_all()

@app.route("/api/courses", methods=["GET"])
def get_all_courses():
    courses = Course.query.all()
    return {
        "courses": [c.serialize() for c in courses]
    }, 200

@app.route("/api/course/<int:course_id>")
def get_course_id(course_id):
    c = Course.query.get(course_id)
    if c is None:
        return failure_response("Course not found", 404)
    return success_response(c.serialize())

# Getting reviews
@app.route("/api/reviews")
def get_all_reviews():
    reviews = Review.query.all()
    return {
        "reviews" : [r.serialize() for r in reviews]
    }

@app.route("/api/reviews/<int:course_id>")
def get_course_reviews(course_id):
    reviews = Review.query.filter_by(course_id=course_id).all()
    return {
        "reviews": [r.serialize() for r in reviews]
    }

@app.route("/api/reviews/<int:course_id>/<int:review_src>")
def get_course_reviews_src(course_id, review_src):
    src = None
    if review_src == 1:
        src = "CUReviews"
    if review_src == 0:
        src = "RMP"
    reviews = Review.query.filter_by(course_id=course_id, source=src).all()

    return {
        "reviews": [r.serialize() for r in reviews]
    }

@app.route("/api/user", methods=["POST"])
def create_user():
    body = json.loads(request.data)
    name = body.get("name")
    netid = body.get("netid")

    new_user = User(
        name = name,
        netid = netid
    )

    db.session.add(new_user)
    db.session.commit()

    return success_response(
        new_user.serialize(), 201
    )

@app.route("/api/users")
def get_all_users():
    users = User.query.all()

    return success_response(
        {"users": [u.serialize_no_courses() for u in users]}
    )

@app.route("/api/users/<int:user_id>")
def get_user_id(user_id):
    user = User.query.get(user_id)

    if not user:
        return failure_response("Could not find the user you are searching for", 404)

    return success_response(
        {"user": user.serialize()}
    )

@app.route("/api/saved/<int:user_id>")
def get_user_saved(user_id):
    user = User.query.get(user_id)
    saved_courses = user.courses  

    return success_response(
        {"saved_courses": [c.serialize() for c in saved_courses]}, 200
    )

@app.route("/api/<int:user_id>/saved", methods=["POST"])
def create_user_saved(user_id):
    body = json.loads(request.data)
    course_id = body.get("course_id")

    course = Course.query.get(course_id)
    user = User.query.get(user_id)

    if not course:
        return failure_response(f"Could not find user with id {user_id}", 404)

    if not user:
        return failure_response(f"Could not find course with id {course_id}", 404)

    user.courses.append(course)

    db.session.commit()

    saved_courses = user.courses

    return success_response(
        {"saved_courses": [c.serialize_minimal() for c in saved_courses]}, 200
    )
    
@app.route("/api/<int:user_id>/saved", methods=["DELETE"])
def remove_user_saved(user_id):
    body = json.loads(request.data)
    course_id = body.get("course_id")

    course = Course.query.get(course_id)
    user = User.query.get(user_id)

    if not course:
        return failure_response(f"Could not find user with id {user_id}", 404)

    if not user:
        return failure_response(f"Could not find course with id {course_id}", 404)

    user.courses.remove(course)
    db.session.commit()

    saved_courses = user.courses

    return success_response(
        {"saved_courses": [c.serialize_minimal() for c in saved_courses]}, 200
    )

@app.route("/api/admin/retrieve-data", methods=["POST"])
def retrieve_data():
    try:
        run_pipeline()
        return {"ok": True, "message": "Data successfully retrieved."}, 200
    
    except Exception as e:
        return {"ok": False, "message": f"Pipeline failed: {e}"}, 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
