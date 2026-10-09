#!/bin/bash
set -e

echo "Starting API in production mode..."

export ENVIRONMENT=production
export DJANGO_CONFIGURATION=Production
export DJANGO_SETTINGS_MODULE=config.settings.production

: "${GUNICORN_LOG_STDOUT:=false}"

mkdir -p /app/logs

echo "Waiting for database..."
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 0.1
done
echo "Database started"

echo "Running database migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn..."
exec gunicorn config.wsgi:application --config /app/gunicorn.conf.py
