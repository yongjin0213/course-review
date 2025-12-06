FROM python:3.10.5-slim

RUN mkdir usr/app
WORKDIR usr/app

COPY . .

RUN mkdir -p instance

RUN pip3 install -r requirements.txt
CMD python app.py