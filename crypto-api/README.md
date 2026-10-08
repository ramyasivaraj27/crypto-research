# Crypto API

Django + DRF + Postgres backend for crypto research. TokenAuth, no Celery/Redis.

## Project structure

`api/` is the Django project root (`manage.py` inside):

- `config/` — URLs, WSGI/ASGI, `settings/common|develop|production.py`
- `users/` — custom User, Token register/login/logout/me, roles
- `research/` — Coin, Watchlist, ResearchNote, PriceSnapshot
- `core/` — health check

## Setup

```bash
cp crypto-api/.env.sample crypto-api/.env  # fill per docs/SETUP.md
docker compose -f crypto-api/docker-compose-local.yml up --build
docker compose -f crypto-api/docker-compose-local.yml exec api python manage.py createsuperuser
```

API: `http://localhost:8000/api/health/`, `/api/users/`, `/api/research/`.

## Tests

```bash
docker compose -f crypto-api/docker-compose-local.yml exec api pytest
```

## Auth

TokenAuth only. `POST /api/users/register/` → `{user, token}`, `POST /api/users/login/` → `{user, token}`, use `Authorization: Token <key>`.
