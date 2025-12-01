import requests
import pandas as pd
import os
# from IPython.display import display #delete this if not using in colab

################################################################################
# Web Scraping Script for CUReviews
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


def fetch_course_reviews_df(subject: str, number: str) -> pd.DataFrame:
    """
    Fetch one course (subject + number) and return a DataFrame
    with one row per review, plus course metadata columns.
    """
    info = get_course_info(subject, number)
    course_id = info["_id"]
    title     = info.get("classTitle")
    full_name = info.get("classFull")

    reviews = get_reviews(course_id)

    rows = []
    for r in reviews:
      rows.append({
          "subject": subject,
          "number": number,
          "course_id": course_id,
          "course_title": title,
          "course_full": full_name,
          "review_id": r["_id"],
          "text": r.get('text'),
          "rating": r.get("rating"),
          "difficulty": r.get("difficulty"),
          "workload": r.get("workload"),
          "date": r.get("date"),
          "professors": ", ".join(r.get("professors", [])),
          "grade": r.get("grade"),
          "major": ", ".join(r.get("major", [])),
          "likes": r.get("likes", 0),
          "isCovid": r.get("isCovid", False),
      })

    return pd.DataFrame(rows)


def fetch_many_courses(courses: list[tuple[str, str]]) -> pd.DataFrame:
    """
    Given a list like [("CS", "3110"), ("CS", "2110"), ...],
    return a single DataFrame with all reviews stacked.
    """
    dfs = []
    for subject, number in courses:
        df_course = fetch_course_reviews_df(subject, number)
        dfs.append(df_course)
    if not dfs:
        return pd.DataFrame()
    return pd.concat(dfs, ignore_index=True)


def append_courses_to_df(existing_df: pd.DataFrame,
                         courses: list[tuple[str, str]]) -> pd.DataFrame:
    """
    Fetch reviews for the given list of (subject, number) tuples,
    append them to the existing dataframe, and drop duplicates by review_id.
    """
    new_df = fetch_many_courses(courses)
    frames = [df for df in (existing_df, new_df) if not df.empty]
    if frames:
        combined = pd.concat(frames, ignore_index=True)
    else:
        combined = existing_df.copy()
    combined = combined.drop_duplicates(subset=["review_id"], keep="first")
    return combined


def load_reviews(filename: str) -> pd.DataFrame:
    """
    Load an existing reviews CSV or initialize a clean empty DataFrame if
    missing or empty.
    """
    columns = [
        "review_id", "subject", "number", "course_id", "course_title",
        "course_full", "review_text", "rating", "difficulty",
        "workload", "professors", "date", "grade", "major",
        "likes", "isCovid"
    ]

    if not os.path.exists(filename):
        print(f"[INFO] File '{filename}' not found — creating new empty dataset.")
        return pd.DataFrame(columns=columns)
    
    if os.path.getsize(filename) == 0:
        print(f"[INFO] File '{filename}' is empty — initializing new DataFrame.")
        return pd.DataFrame(columns=columns)
    
    try:
        df = pd.read_csv(filename)
        if df.empty:
            print(f"[INFO] File '{filename}' had no rows — using empty template.")
            return pd.DataFrame(columns=columns)

        print(f"[INFO] Loaded existing file '{filename}' with {len(df)} rows.")
        return df

    except Exception as e:
        print(f"[WARN] Failed to load '{filename}' ({e}) — starting fresh.")
        return pd.DataFrame(columns=columns)


def main(courses: list[tuple[str, str]] | None = None,
         filename: str = "cureviews.csv"):
    """
    Fetch and append CUReviews data for the given list of (subject, number)
    course tuples, then save to CSV.
    """
    if courses is None or len(courses) == 0:
        print("""
################################################################################
Usage:
    main([("SUBJECT", "NUMBER"), ("SUBJECT", "NUMBER")], filename="cureviews.csv")

Example:
    main([
        ("CS", "3110"),
        ("INFO", "2950"),
        ("COMM", "2450")
    ])

Description:
    Pass a list of (subject, number) tuples. Each will be scraped via the API
    and appended to the dataframe stored in the CSV file.
################################################################################
        """)
        return
    
    df = load_reviews(filename)
    df = append_courses_to_df(df, courses)
    df.to_csv(filename, index=False)

    print(f"[INFO] Saved updated dataset with {len(df)} rows to '{filename}'")
    # display(df.head())
    print(df.head())

