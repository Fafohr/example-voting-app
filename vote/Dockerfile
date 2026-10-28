# Pin the base image to a digest for reproducible builds.
FROM python:3.11-slim@sha256:0a236bf8f0b6013383df04d1cd02cb0abe5fbfa1a7012141d7ff9202b7cb30a6 AS base

# Add curl for healthcheck.
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --system app && useradd --system --gid app --create-home --home-dir /home/app app

WORKDIR /usr/local/app

COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

FROM base AS dev
RUN pip install watchdog
ENV FLASK_ENV=development
USER app
CMD ["python", "app.py"]

FROM base AS final
COPY . .
RUN chown -R app:app /usr/local/app
USER app
EXPOSE 80
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
