FROM python:3.10-slim-buster

WORKDIR /app

COPY . /app

# Install git so pip can pull dependencies from GitHub repositories
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install the dependencies
RUN pip install -r requirements.txt

# (The rest of your Dockerfile remains the same...)