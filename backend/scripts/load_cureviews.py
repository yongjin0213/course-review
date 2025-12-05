import requests
import os

from flask import current_app
from db import db, Course, Review

BASE_URL = "https://www.cureviews.org"


# ----------------------------------------------------------
# CUReviews API helper functions
# ----------------------------------------------------------

def get_course_info(subject: str, number: str) -> dict:
    """Returns CUReviews course info object."""
    url = f"{BASE_URL}/api/courses/get-by-info"
    payload = {"subject": subject, "number": number}

    r = requests.post(url, json=payload, timeout=10)
    r.raise_for_status()
    return r.json()["result"]


def get_reviews(course_id: str) -> list[dict]:
    """Returns list of CUReviews review objects."""
    url = f"{BASE_URL}/api/courses/get-reviews"
    payload = {"courseId": course_id}

    r = requests.post(url, json=payload, timeout=10)
    r.raise_for_status()
    return r.json()["result"]


# ----------------------------------------------------------
# Database insertion pipeline (NO pandas)
# ----------------------------------------------------------

def load_cureviews_to_db():
    """Fetch courses from our DB, scrape CUReviews, store reviews locally."""
    with current_app.app_context():

        courses = Course.query.all()
        print(f"[INFO] Starting CUReviews scraping for {len(courses)} courses.")

        inserted_count = 0

        for course in courses:
            # expected format: "CS 1110"
            parts = course.code.strip().replace("  ", " ").split()

            if len(parts) != 2:
                print(f" → [SKIP] Invalid course code format: '{course.code}'")
                continue

            subject, number = parts

            try:
                info = get_course_info(subject, number)
                cu_id = info["_id"]
                reviews = get_reviews(cu_id)

                print(f" → {subject} {number}: {len(reviews)} reviews found")

                for r in reviews:
                    review = Review(
                        course_id=course.id,
                        source="CUReviews",
                        content=r.get("text", "").strip()
                    )
                    db.session.add(review)
                    inserted_count += 1

            except requests.exceptions.HTTPError as http_err:
                print(f" → [ERROR] CUReviews did not return {subject} {number}. "
                      f"HTTP {http_err.response.status_code}")
            except Exception as err:
                print(f" → [ERROR] Unexpected error for {subject} {number}: {err}")

        # Commit once at the end (more efficient)
        db.session.commit()

        print(f"\n[SUCCESS] {inserted_count} CUReviews reviews inserted into database.")


# ----------------------------------------------------------
# Wrapper for additional review sources
# ----------------------------------------------------------

def load_all_reviews():
    """Runs all external review loaders (CUReviews + optional RMP)."""
    load_cureviews_to_db()
    # load_rmp_reviews_from_db()  # Uncomment when implemented


if __name__ == "__main__":
    load_all_reviews()
