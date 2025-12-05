import os
import pandas as pd

# Import app + db + models from backend
from backend.app import app
from backend.db import db
from backend.db import Course


CSV_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "roster_courses.csv")


def load_roster_data():
    print(f"[INFO] Loading CSV from: {CSV_PATH}")

    df = pd.read_csv(CSV_PATH)
    print(f"[INFO] CSV loaded. Rows: {len(df)}")

    with app.app_context():
        for _, row in df.iterrows():
            course = Course(
                title=row.get("title"),
                code=f"{row.get('subject')} {row.get('number')}",
                professor=row.get("instructors") or "Unknown",
                term=row.get("roster"),
                credit=row.get("unitsMinimum") or 0,
                ai_review="",
            )

            db.session.add(course)

        db.session.commit()

    print("[SUCCESS] Roster data inserted into the database.")


if __name__ == "__main__":
    load_roster_data()
