FROM python:3.7-slim-buster

# set work directory
WORKDIR /app


# dependencies for psycopg2
RUN apt-get update && \
    apt-get install --no-install-recommends -y dnsutils libpq-dev python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1


# Install dependencies
RUN python -m pip install --no-cache-dir pip==23.3.1
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt || { echo 'Pip install failed'; exit 1; }


# copy project
COPY . /app/


# install pygoat
EXPOSE 8000


RUN python3 /app/manage.py migrate
WORKDIR /app/pygoat/
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers","6", "pygoat.wsgi"]
