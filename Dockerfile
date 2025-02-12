FROM python:3.13-slim@sha256:ae9f9ac89467077ed1efefb6d9042132d28134ba201b2820227d46c9effd3174 AS base
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
