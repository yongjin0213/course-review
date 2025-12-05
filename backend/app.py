from flask import Flask, request
import json
from db import db, Course, Review, User
import os

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

@app.route("/api/saved/<int:user_id>")
def get_user_saved(user_id):
    user = User.query.get(user_id)
    saved_courses = user.courses  

    return success_response(
        {"saved_courses": [c.serialize() for c in saved_courses]}, 200
    )

@app.route("/api/<int:user_id>/saved", methods=["POST"])
def create_user_saved(user_id):
    
    return {
    }
    
@app.route("/api/<int:user_id>/saved", methods=["DELETE"])
def remove_user_saved(user_id):
    return {}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
