FROM python:3.13-slim@sha256:6544e0e002b40ae0f59bc3618b07c1e48064c4faed3a15ae2fbd2e8f663e8283 AS base
LABEL org.opencontainers.image.name=europe-west3-docker.pkg.dev/zeitonline-engineering/docker-zon/httpbin

COPY --from=ghcr.io/astral-sh/uv:0.7.21@sha256:a64333b61f96312df88eafce95121b017cbff72033ab2dbc6398edb4f24a75dd /uv /usr/bin/
ENV UV_NO_MANAGED_PYTHON=1 \
    UV_NO_CACHE=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_FROZEN=1 \
    UV_INDEX_PYPI_ZON_USERNAME="oauth2accesstoken"

WORKDIR /app
RUN groupadd --gid=10000 app && \
    useradd --uid=10000 --gid=app --no-user-group \
    --create-home --home-dir /app app && \
    chown -R app:app /app
USER app
RUN uv venv --allow-existing /app
ENV PATH=/app/bin:$PATH \
    UV_PROJECT_ENVIRONMENT=/app

COPY pyproject.toml uv.lock ./
COPY httpbin httpbin
RUN --mount=type=secret,id=GCLOUD_TOKEN,env=UV_INDEX_PYPI_ZON_PASSWORD \
    uv sync --group deploy

ENTRYPOINT ["python", "-m", "gunicorn", "-b", "0.0.0.0:8080", "httpbin:app", "-k", "gevent"]

# Security updates run last, to intentionally bust the docker cache.
USER root
RUN apt-get update && apt-get -y upgrade && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
USER app
