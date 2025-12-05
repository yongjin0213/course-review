from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

association_table = db.Table(
    "association_table",
    db.Model.metadata,
    db.Column("course_id", db.Integer, db.ForeignKey("course.id"), primary_key=True),
    db.Column("user_id", db.Integer, db.ForeignKey("user.id"), primary_key=True)
)

class Course(db.Model):
    """
    SQL table for Cornell courses
    """
    __tablename__ = "course"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    title = db.Column(db.String, nullable=False) # Course title (e.g. "Introduction to Backend Development")
    code = db.Column(db.String, nullable=False) # Course code (e.g. "CS 1998")
    professor = db.Column(db.String, nullable=False)
    term = db.Column(db.String, nullable=False) # Semester offered
    credit = db.Column(db.Integer, nullable=False)
    ai_review = db.Column(db.String, nullable=True)

    reviews = db.relationship("Review", cascade="delete")
    users = db.relationship("User", secondary=association_table, back_populates="courses")

    def serialize(self):
        return {
            "id": self.id,
            "title": self.title,
            "code": self.code,
            "professor": self.professor,
            "term": self.term,
            "credit": self.credit,
            "ai_review": self.ai_review,
            "reviews": [r.serialize_no_course() for r in self.reviews]
        }

    def serialize_minimal(self):
        return {
            "id": self.id,
            "title": self.title,
            "code": self.code,
        }

class Review(db.Model):
    """
    SQL table for reviews of courses
    """
    __tablename__ = "review"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    source = db.Column(db.String, nullable=False) # CU Review, Rate My Prof, etc
    content = db.Column(db.String, nullable=False) # The review itself (e.g. "Backend dev was so fun and productive!")
    course_id = db.Column(db.Integer, db.ForeignKey("course.id"), nullable=False)

    course = db.relationship("Course")

    def serialize(self):
        return {
            "id": self.id,
            "source": self.source,
            "content": self.content,
            "course": self.course_id
        }

class User(db.Model):
    """
    SQL table for users of the platform
    """
    __tablename__  = "user"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String, nullable=False)
    netid = db.Column(db.String, nullable=False)

    courses = db.relationship("Course", secondary=association_table, back_populates="users") # List of courses that the user "saved"

    def serialize(self):
        return {
            "id": self.id,
            "name": self.name,
            "netid": self.netid,
            "courses": [c.serialize_minimal() for c in self.courses]
        }
    
    def serialize_no_courses(self):
        return {
            "id": self.id,
            "name": self.name,
            "netid": self.netid
        }
