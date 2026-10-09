# Base stage with system dependencies
FROM python:3.12.4-slim AS system-deps

ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    netcat-openbsd \
    libpq-dev \
    ca-certificates \
    curl && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

# Python dependencies stage
FROM system-deps AS python-deps

ENV POETRY_VERSION=1.8.3
ENV POETRY_NO_INTERACTION=1
ENV POETRY_VIRTUALENVS_CREATE=false
ENV POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

RUN pip install --no-cache-dir poetry==$POETRY_VERSION

COPY pyproject.toml poetry.lock* ./

ARG ENVIRONMENT=dev

RUN poetry config virtualenvs.create false --local && \
    if [ "$ENVIRONMENT" = "dev" ]; then \
        poetry install --with dev --no-root; \
    else \
        poetry install --only main --no-root; \
    fi && \
    rm -rf $POETRY_CACHE_DIR

# Runtime stage
FROM system-deps AS runtime

COPY --from=python-deps /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=python-deps /usr/local/bin /usr/local/bin

RUN adduser \
        --disabled-password \
        --no-create-home \
        django-user

RUN apt-get purge -y --auto-remove build-essential && \
    rm -rf /var/lib/apt/lists/* /root/.cache

WORKDIR /app

COPY run-dev.sh run.sh ./
RUN chmod a+x /app/run-dev.sh /app/run.sh

COPY --chown=django-user:django-user api /app/api
COPY --chown=django-user:django-user gunicorn.conf.py /app/gunicorn.conf.py

RUN mkdir -p /vol/web/media /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol && \
    mkdir -p /app/logs && \
    chown -R django-user:django-user /app/logs

WORKDIR /app/api
ENV PYTHONPATH=/app/api
EXPOSE 8000

FROM runtime AS dev
USER django-user
CMD ["/bin/sh", "/app/run-dev.sh"]

FROM runtime AS production
USER django-user
RUN mkdir -p /app/api/config/staticfiles && \
    chmod -R 755 /app/api/config/staticfiles
EXPOSE 8000
CMD ["/bin/sh", "/app/run.sh"]
