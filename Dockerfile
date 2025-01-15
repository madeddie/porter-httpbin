FROM python:3.13-slim@sha256:23a81be7b258c8f516f7a60e80943cace4350deb8204cf107c7993e343610d47 AS base
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
