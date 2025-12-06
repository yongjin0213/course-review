# Course Review
Course-Review / Coursely is a full-stack app that lets you learn about Cornell courses and see reviews from multiple sources compiled together on our ios app.

The main entrypoint is a list of all of the courses in the database, as well as search. Each course has menus of reviews from the different sources in scripts, which is built to scale as we add more sources. The second tab contains saveable courses, and the final tab stores the user's profile, interests, and learning preferences

## Tech Stack

**Frontend**

- Swift / iOS
- Uses HTTP requests to talk to the Flask backend

**Backend**

- Flask
- SQLite (`coursereview.db`)
- Dockerfile / Docker Compose

## Project Structure
From the root, the Frontend and backend directories contain their respective code

## Backend 

### Setup
After cloning the repo, either use docker or manually run with python:
Docker-compose: (bash)
```
cd backend
docker-compose up -d
#from here you can run requests
```

DockerFile: (bash)
```
docker build -t course-review-backend ./backend
docker run -p 8000:8000 course-review-backend
```

Python: (bash)
```
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt 
python3 app.py
```

By default the app runs on port 8000

### API Spec/Reference

We've listed out the API spec on this google doc:
https://docs.google.com/document/d/1ei5mB8mGV_MjvtZhFHpPzJ1BjBDc4kmkx27oqZsDY9M/edit?usp=drivesdk

Data loading endpoint:
@app.route("/api/admin/retrieve-data", methods=["POST"])
This endpoint is an admin endpoint meant to load the scraped data from the scripts directory in backend. We have 3 implemented scripts to pull from the Rate My Professor (not implemented on frontend), CUReviews, and Class roster. Then this endpoint runs our loading pipeline and fills the SQLite database.

### General structure (backend)

We have 3 main parts of the backend: db.py, app.py, scripts/. DB and app have standard sqlite database and endpoint stuff. We have 3 classes for courses, reviews, and users. App.py supports most basic endpoints for the api plus the retriever (see above API spec section). Scripts holds the scraping scripts and is called on startup via the loader function.

### Contributors
@yongjin0213
@alexjoos11

## Front End

The frontend is a native iOS app built in Swift. It communicates with the Flask backend over HTTP and shows courses, users, saved courses, and course reviews.

The iOS app currently supports:

- Browsing all courses
  - Fetches from: GET /api/courses

- Viewing details for a specific course
  - Uses: GET /api/course/<course_id>
  - Shows course title, code, professor, term, credits, and AI summary (if available)

- Viewing reviews for a course
  - Uses:
      GET /api/reviews/<course_id>
      GET /api/reviews/<course_id>/<review_src> for source-specific reviews
  - Displays reviews from CUReviews / Class roster

- Saving and unsaving courses for a user

### Contributors
@drajthota9