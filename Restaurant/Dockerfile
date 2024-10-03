# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Install necessary system dependencies for MSSQL
RUN apt-get update && \
    apt-get install -y curl apt-transport-https gnupg2 build-essential && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy the current directory contents into the container at /app
COPY . /app/

# Ensure that Gunicorn is installed
RUN pip install gunicorn

# Collect static files (optional, if you have static files)
RUN python manage.py collectstatic --noinput || echo "No static files to collect"

# Expose the port that the app runs on (internal port)
EXPOSE 8000

# Define the command to run the application
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "restaurant_project.wsgi:application"]
