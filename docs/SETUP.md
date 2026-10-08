# Setup — Crypto API (Docker path)

## Prerequisites

1. Docker (Colima ok for lightweight)
2. Poetry (only for local non-Docker runs)

## Local (docker-compose-local.yml + bundled Postgres)

```bash
cp crypto-api/.env.sample crypto-api/.env  # fill per § Env
docker compose -f crypto-api/docker-compose-local.yml up --build
docker compose -f crypto-api/docker-compose-local.yml exec api python manage.py createsuperuser
docker compose -f crypto-api/docker-compose-local.yml exec api pytest
```

API: `http://localhost:8000/api/health/`, `/api/users/`, `/api/research/`.

## Dev / Prod

Dev and prod differ only by compose file + `.env`:

- local: `docker-compose-local.yml` (bundled `db=crypto_local`)
- dev/staging: `docker-compose.yml` (bundled db, production image)
- prod: `docker-compose.prod.yml` (external `DB_HOST`, no db service)

## Env

All vars in `crypto-api/.env.sample`. Required: `DJANGO_SECRET_KEY`, `DB_HOST/PORT/NAME/USER/PASSWORD`.

## Local without Docker (optional)

```bash
cd crypto-api
poetry install
cd api && poetry run python manage.py migrate
poetry run python manage.py runserver
```
Set `DB_HOST=localhost` and run Postgres locally.
