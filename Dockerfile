FROM python:3.13-slim@sha256:a658ec9b0f7df10fd2bd6f8f3a05a248f2580f105d08b89eaa359b9d4ddf0588 AS base
LABEL org.opencontainers.image.name=europe-west3-docker.pkg.dev/zeitonline-engineering/docker-zon/httpbin
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --no-deps -r requirements.txt

FROM base AS testing
ENV PYTHONDONTWRITEBYTECODE=1

FROM base AS production
COPY httpbin httpbin
COPY setup.py .
RUN pip install --no-cache-dir --no-deps -e .

ENTRYPOINT ["python", "-m", "gunicorn", "-b", "0.0.0.0:8080", "httpbin:app", "-k", "gevent"]
