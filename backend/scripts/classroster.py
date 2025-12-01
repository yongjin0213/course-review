import requests
import pandas as pd

BASE_URL_ROSTER = "https://classes.cornell.edu/api/2.0/search/classes.json"


def fetch_roster_course(roster: str, subject: str, number: str) -> dict | None:
    """
    Call Cornell roster API for a specific (roster, subject, number)
    """
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


def fetch_roster_course_row(roster: str, subject: str, number: str) -> dict | None:
    """
    Fetch a single class and return a flat dict representing one DataFrame row,
    including enroll-group, section, and meeting-level info.
    """
    c = fetch_roster_course(roster, subject, number)
    if c is None:
        return None

    roster = roster.strip()
    subject = subject.strip()
    number = str(number).strip()

    row: dict = {
        "roster": roster,
        "subject": subject,
        "number": number,
        "title": c.get("titleLong"),
        "description": (c.get("description") or "").strip(),
    }

    eg = None
    enroll_groups = c.get("enrollGroups", []) or []
    if enroll_groups:
        eg = enroll_groups[0]  # take first enroll group

    if eg:
        row["unitsMinimum"] = eg.get("unitsMinimum")
        row["unitsMaximum"] = eg.get("unitsMaximum")
        row["gradingBasis"] = eg.get("gradingBasis")
        row["gradingBasisShort"] = eg.get("gradingBasisShort")
        row["gradingBasisLong"] = eg.get("gradingBasisLong")
        row["sessionCode"] = eg.get("sessionCode")
        row["sessionBeginDt"] = eg.get("sessionBeginDt")
        row["sessionEndDt"] = eg.get("sessionEndDt")
        row["sessionLong"] = eg.get("sessionLong")
    else:
        row["unitsMinimum"] = None
        row["unitsMaximum"] = None
        row["gradingBasis"] = None
        row["gradingBasisShort"] = None
        row["gradingBasisLong"] = None
        row["sessionCode"] = None
        row["sessionBeginDt"] = None
        row["sessionEndDt"] = None
        row["sessionLong"] = None

    sec = None
    if eg:
        sections = eg.get("classSections", []) or []
        lec_sec = next((s for s in sections if s.get("ssrComponent") == "LEC"), None)
        sec = lec_sec or (sections[0] if sections else None)

    if sec:
        row["openStatus"] = sec.get("openStatus")
        row["campus"] = sec.get("campus")
        row["campusDescr"] = sec.get("campusDescr")
        row["maxEnroll"] = sec.get("maxEnroll")
        row["enrollCount"] = sec.get("enrollCount")
        row["waitCount"] = sec.get("waitCount")

        notes = sec.get("notes", []) or []
        note_texts = []
        for n in notes:
            txt = (n.get("descrlong") or "").strip()
            if txt:
                note_texts.append(txt)
        row["notes_descrlong"] = " | ".join(note_texts) if note_texts else None
    else:
        row["openStatus"] = None
        row["campus"] = None
        row["campusDescr"] = None
        row["maxEnroll"] = None
        row["enrollCount"] = None
        row["waitCount"] = None
        row["notes_descrlong"] = None

    meeting_days = None
    meeting_time = None
    meeting_location = None
    instructors_str = None

    if sec:
        meetings = sec.get("meetings", []) or []
        mtg = None
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

            loc = mtg.get("locationDescr") or mtg.get("facilityDescr")
            meeting_location = loc

            instrs = mtg.get("instructors", []) or []
            instr_names = []
            for instr in instrs:
                fname = instr.get("firstName") or ""
                lname = instr.get("lastName") or ""
                netid = instr.get("netid") or ""
                name_bits = " ".join(x for x in [fname, lname] if x)
                if netid:
                    if name_bits:
                        instr_names.append(f"{name_bits} ({netid})")
                    else:
                        instr_names.append(netid)
                elif name_bits:
                    instr_names.append(name_bits)
            instructors_str = ", ".join(instr_names) if instr_names else None

    row["meeting_days"] = meeting_days
    row["meeting_time"] = meeting_time
    row["meeting_location"] = meeting_location
    row["instructors"] = instructors_str

    return row


def build_roster_df(classes: list[tuple[str, str, str]]) -> pd.DataFrame:
    """
    Given a list like: [("SP26", "CS", "3110"), ("SP26", "CS", "2110"),...
    build a data frame with one row per unique (roster, subject, number)
    """
    rows_by_key: dict[tuple[str, str, str], dict] = {}

    for roster, subject, number in classes:
        key = (roster.strip(), subject.strip(), str(number).strip())
        if key in rows_by_key:
            continue

        row = fetch_roster_course_row(*key)
        if row is None:
            continue

        rows_by_key[key] = row

    if not rows_by_key:
        return pd.DataFrame(columns=["roster", "subject", "number", "title", "description"])

    df = pd.DataFrame(list(rows_by_key.values()))

    df = (
        df
        .drop_duplicates(subset=["roster", "subject", "number"], keep="last")
        .reset_index(drop=True)
    )

    return df


def main(
    classes: list[tuple[str, str, str]] | None = None,
    filename: str = "roster_courses.csv",
):
    """
    Build a roster CSV from a list of (roster, subject, number) tuples.
    TODO: this implemention always rewrites if time debug appending issues
    """
    if not classes:
        print("""
################################################################################
Usage:
    main(
        [("ROSTER", "SUBJECT", "NUMBER"), ...],
        filename="roster_courses.csv"
    )

Example:
    main([
        ("SP26", "CS", "3110"),
        ("SP26", "CS", "2110"),
    ])
################################################################################
        """)
        return

    df = build_roster_df(classes)
    df.to_csv(filename, index=False)

    print(f"[INFO] Wrote {len(df)} unique rows to '{filename}'")
    print(df)