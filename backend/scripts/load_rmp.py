# Note: this script fetches course information from the database, finds the professor's name,
# queries the data into the Rate My Professor GraphQL endpoint, and filters the reviews by
# the course that the user is searching for, and saves it into the database. 

import requests
from backend.app import app
from backend.db import db, Course, Review

RMP_URL = "https://www.ratemyprofessors.com/graphql"
HEADERS = {"Content-Type": "application/json", "User-Agent": "Mozilla/5.0"}


# ------------------------
# RMP GraphQL Functions
# ------------------------

def search_professor(name):
    query = {
        "query": """
        query SearchTeacher($query: TeacherSearchQuery!) {
          newSearch {
            teachers(query: $query) {
              edges {
                node { id firstName lastName school { name } }
              }
            }
          }
        }""",
        "variables": { "query": { "text": name } }
    }
    res = requests.post(RMP_URL, json=query, headers=HEADERS).json()
    edges = res["data"]["newSearch"]["teachers"]["edges"]
    if not edges:
        return None
    return edges[0]["node"]["id"]


def get_professor_ratings(teacher_id):
    query = {
        "query": """
        query GetRatings($id: ID!) {
          node(id: $id) {
            ... on Teacher {
              ratings(first: 100) {
                edges {
                  node {
                    class
                    comment
                    qualityRating
                    difficultyRating
                    date
                    wouldTakeAgain
                  }
                }
              }
            }
          }
        }""",
        "variables": { "id": teacher_id }
    }

    res = requests.post(RMP_URL, json=query, headers=HEADERS).json()
    try:
        return res["data"]["node"]["ratings"]["edges"]
    except:
        return []


# ------------------------
# Filtering Logic
# ------------------------

def normalize(code):
    return code.replace(" ", "").upper()


def filter_reviews_for_course(reviews, course_code):
    target = normalize(course_code)
    return [
        r["node"] for r in reviews
        if r["node"]["class"] and target in normalize(r["node"]["class"])
    ]


# ------------------------
# Main Pipeline
# ------------------------

def load_rmp_reviews_from_db():
    with app.app_context():
        courses = Course.query.all()

        for course in courses:
            course_code = course.code
            professor = course.professor

            print(f"\n[INFO] Processing {course_code} (Instructor: {professor})")

            teacher_id = search_professor(professor)
            if not teacher_id:
                print(" → Instructor not found on RMP.")
                continue

            ratings = get_professor_ratings(teacher_id)
            filtered = filter_reviews_for_course(ratings, course_code)

            print(f" → {len(filtered)} matching reviews found.")

            for r in filtered:
                review = Review(
                    course_id=course.id,
                    source="RMP",
                    content=r["comment"]
                )
                db.session.add(review)

        db.session.commit()
        print("\n[SUCCESS] All RMP reviews inserted.")


if __name__ == "__main__":
    load_rmp_reviews_from_db()
