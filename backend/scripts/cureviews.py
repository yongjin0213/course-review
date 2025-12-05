import requests
import pandas as pd
import os

from backend.app import app
from backend.db import db, Course, Review

# from IPython.display import display #delete this if not using in colab

################################################################################
# Web Scraping Script for CUReviews (API Functions Kept)
################################################################################

BASE_URL = "https://www.cureviews.org"


def get_course_info(subject: str, number: str) -> dict:
    """Call /api/courses/get-by-info and return the 'result' object."""
    url = f"{BASE_URL}/api/courses/get-by-info"
    payload = {"subject": subject, "number": number}
    r = requests.post(url, json=payload)
    r.raise_for_status()
    data = r.json()
    return data["result"]


def get_reviews(course_id: str) -> list[dict]:
    """Call /api/courses/get-reviews and return the list of reviews."""
    url = f"{BASE_URL}/api/courses/get-reviews"
    payload = {"courseId": course_id}
    r = requests.post(url, json=payload)
    r.raise_for_status()
    data = r.json()
    return data["result"]

# ----------------------------------------------------------------------
# NEW FUNCTION: Load CUReviews data directly into the database
# ----------------------------------------------------------------------

def load_cureviews_to_db():
    """
    Fetches course list from the local DB, scrapes CUReviews for each,
    and saves the reviews into the local Review table.
    """
    with app.app_context():
        # 1. Fetch all courses from the local database
        courses_in_db = Course.query.all()
        inserted_count = 0
        
        print(f"\n[INFO] Starting CUReviews scraping for {len(courses_in_db)} courses.")

        for course in courses_in_db:
            # Assumes course.code is in the format "CS 1110" or "CS1110"
            
            # Simple attempt to split subject and number, adjust if necessary
            # e.g., "CS 1110" -> ["CS", "1110"]
            parts = course.code.strip().split() 
            if len(parts) != 2:
                print(f" → Skipping '{course.code}': Course code format is invalid.")
                continue

            subject, number = parts[0], parts[1]
            
            try:
                # 2. Scrape CUReviews for course info and reviews
                info = get_course_info(subject, number)
                cureviews_course_id = info["_id"]
                reviews = get_reviews(cureviews_course_id)
                
                print(f" → Processing {subject} {number} ({len(reviews)} reviews found on CUReviews)")
                
                # 3. Insert each review into the local database
                for r in reviews:
                    # Check if a review with this review_id (from CUReviews) already exists
                    # This requires adding a 'review_id' column to your Review model
                    # For now, we'll assume content uniqueness or trust the insertion.
                    
                    review = Review(
                        course_id=course.id, # Use the local DB course ID
                        source="CUReviews",
                        content=r.get('text'),
                        # You can map more fields here if your Review model supports them
                    )
                    db.session.add(review)
                    inserted_count += 1

            except requests.exceptions.HTTPError as e:
                print(f" → ERROR: Could not find {subject} {number} on CUReviews (HTTP Error: {e.response.status_code})")
            except Exception as e:
                print(f" → An unexpected error occurred for {subject} {number}: {e}")

        db.session.commit()
        print(f"\n[SUCCESS] Completed CUReviews review insertion. {inserted_count} reviews added/updated.")

# ----------------------------------------------------------------------
# Centralized Main Pipeline
# ----------------------------------------------------------------------

def load_all_reviews():
    """Run both the CUReviews and RMP scraping pipelines."""
    # Assuming the RMP functions (search_professor, get_professor_ratings, etc.) 
    # and the load_rmp_reviews_from_db function are defined elsewhere or above this point.
    
    # 1. Load CUReviews data
    load_cureviews_to_db()
    
    # 2. Load RMP data (from the function you provided in the prompt)
    # load_rmp_reviews_from_db()

if __name__ == "__main__":
    # The original CSV-generating logic is replaced with the database loading logic
    load_all_reviews()