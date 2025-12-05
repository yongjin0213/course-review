import requests
from flask import current_app
from db import db, Course

BASE_URL_ROSTER = "https://classes.cornell.edu/api/2.0/search/classes.json"


# ---------------------------------------------------------
# Fetch a single class from Cornell roster API
# ---------------------------------------------------------
def fetch_roster_course(roster: str, subject: str, number: str) -> dict | None:
    params = {
        "roster": roster,
        "subject": subject,
        "q": number,
    }

    r = requests.get(BASE_URL_ROSTER, params=params, timeout=10)
    r.raise_for_status()
    data = r.json()

    classes = data.get("data", {}).get("classes", [])
    matches = [
        c for c in classes
        if c.get("subject") == subject and c.get("catalogNbr") == str(number)
    ]

    if not matches:
        print(f"[WARN] No class found for {roster} {subject} {number}")
        return None

    return matches[0]


# ---------------------------------------------------------
# Flatten and extract useful fields into one row dict
# ---------------------------------------------------------
def extract_row(c: dict, roster: str, subject: str, number: str) -> dict:
    row = {
        "roster": roster.strip(),
        "subject": subject.strip(),
        "number": str(number),
        "title": c.get("titleLong"),
        "description": (c.get("description") or "").strip(),
    }

    # Use first enrollment group
    eg = (c.get("enrollGroups") or [None])[0]

    if eg:
        row["unitsMinimum"] = eg.get("unitsMinimum")
        row["gradingBasisShort"] = eg.get("gradingBasisShort")
    else:
        row["unitsMinimum"] = 0
        row["gradingBasisShort"] = None

    # Choose LEC or first section
    sec = None
    if eg:
        sections = eg.get("classSections", []) or []
        sec = next((s for s in sections if s.get("ssrComponent") == "LEC"), None)
        if not sec and sections:
            sec = sections[0]

    instructors_str = None
    meeting_days = None
    meeting_time = None
    meeting_location = None

    if sec:
        meetings = sec.get("meetings", []) or []
        mtg = None

        # Pick a meeting with actual info
        for m in meetings:
            if m.get("pattern") or m.get("timeStart") or m.get("timeEnd"):
                mtg = m
                break
        if not mtg and meetings:
            mtg = meetings[0]

        if mtg:
            meeting_days = mtg.get("pattern")
            start = mtg.get("timeStart") or ""
            end = mtg.get("timeEnd") or ""
            meeting_time = f"{start}-{end}" if (start or end) else None
            meeting_location = mtg.get("locationDescr") or mtg.get("facilityDescr")

            # Build instructor string
            instrs = mtg.get("instructors", []) or []
            formatted = []
            for instr in instrs:
                fname = instr.get("firstName") or ""
                lname = instr.get("lastName") or ""
                netid = instr.get("netid") or ""
                full = " ".join(x for x in [fname, lname] if x)
                if netid:
                    formatted.append(f"{full} ({netid})" if full else netid)
                elif full:
                    formatted.append(full)

            instructors_str = ", ".join(formatted) if formatted else None

    row["meeting_days"] = meeting_days
    row["meeting_time"] = meeting_time
    row["meeting_location"] = meeting_location
    row["instructors"] = instructors_str or "Unknown"

    return row


# ---------------------------------------------------------
# Insert data directly into database
# ---------------------------------------------------------
def insert_course_row(row: dict):
    course = Course(
        title=row["title"],
        code=f"{row['subject']} {row['number']}",
        professor=row["instructors"],
        term=row["roster"],
        credit=row["unitsMinimum"] or 0,
        ai_review="",
    )

    db.session.add(course)


# ---------------------------------------------------------
# Main entry point
# ---------------------------------------------------------
def load_courses():
    classes = [
        ("SP26", "CS", "1110"),
        ("SP26", "CS", "1998"),
        ("SP26", "CS", "2110"),
        ("SP26", "CS", "2800"),
        ("SP26", "CS", "3110"),
        ("SP26", "CS", "3410"),
        ("SP26", "CS", "4410"),
        ("SP26", "ECE", "2300"),
    ]

    with current_app.app_context():
        for roster, subject, number in classes:
            raw = fetch_roster_course(roster, subject, number)
            if not raw:
                continue

            row = extract_row(raw, roster, subject, number)
            insert_course_row(row)
            print(f"[OK] Inserted {subject} {number} ({roster})")

        db.session.commit()

    print("[SUCCESS] All courses inserted.")


# ---------------------------------------------------------
# Run script directly
# ---------------------------------------------------------
if __name__ == "__main__":
    classes_to_fetch = [
        ("SP26", "CS", "1110"),
        ("SP26", "CS", "1998"),
        ("SP26", "CS", "2110"),
        ("SP26", "CS", "2800"),
        ("SP26", "CS", "3110"),
        ("SP26", "CS", "3410"),
        ("SP26", "CS", "4410"),
        ("SP26", "ECE", "2300"),
    ]

    load_courses(classes_to_fetch)
