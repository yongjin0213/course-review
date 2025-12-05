from flask import Flask, request
import json
from db import db, Course, Review, User

app = Flask(__name__)
db_filename = "coursereview.db"

app.config["SQLALCHEMY_DATABASE_URI"] = f"sqlite:///{db_filename}"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db.init_app(app)
with app.app_context():
    db.create_all()

@app.route("/courses", methods=["GET"])
def get_all_courses():
    courses = Course.query.all()
    return {
        "courses": [c.serialize() for c in courses]
    }, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
