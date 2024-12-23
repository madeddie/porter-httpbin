FROM python:3.12-slim AS base
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
