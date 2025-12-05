"""
pipeline_load_all.py
Runs ALL data ingestion steps in order:
1. Load Cornell Class Roster → populate Course table
2. Load CUReviews → populate Review table
3. Load RMP reviews → populate Review table
"""

from scripts.load_class_roster import load_courses
from scripts.load_cureviews import load_cureviews_to_db
from scripts.load_rmp import load_rmp_reviews_to_db


def run_pipeline():
    print("\n==============================")
    print("Starting Full Data Pipeline")
    print("==============================")

    print("\nSTEP 1: Loading Class Roster...")
    load_courses()

    print("\nSTEP 2: Loading CUReviews...")
    load_cureviews_to_db()

    print("\nSTEP 3: Loading RateMyProfessors...")
    load_rmp_reviews_to_db()

    print("\nPipeline complete.")


if __name__ == "__main__":
    run_pipeline()
    print("\n[SUCCESS] All ingestion pipelines completed!")
