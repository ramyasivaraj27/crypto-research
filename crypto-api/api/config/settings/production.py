import os

from .common import Common

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class Production(Common):
    DEBUG = False
    REST_FRAMEWORK = Common.REST_FRAMEWORK

    ALLOWED_HOSTS = []
    ALLOWED_HOSTS.extend(
        filter(
            None,
            os.environ.get("DJANGO_ALLOWED_HOSTS", "localhost,127.0.0.1").split(","),
        )
    )
    if not ALLOWED_HOSTS:
        ALLOWED_HOSTS = ["localhost", "127.0.0.1"]

    CORS_ALLOW_ALL_ORIGINS = True
    CORS_ALLOW_CREDENTIALS = True

    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = "Lax"
    CSRF_COOKIE_SECURE = True
    CSRF_COOKIE_SAMESITE = "Lax"
    SECURE_SSL_REDIRECT = False

    USE_X_FORWARDED_HOST = True
    USE_X_FORWARDED_PORT = True

    FRONTEND_SITE_URL = Common.FRONTEND_SITE_URL
    os.environ.setdefault("DJANGO_CONFIGURATION", "Production")

    STORAGES = {
        "default": {
            "BACKEND": "django.core.files.storage.FileSystemStorage",
        },
        "staticfiles": {
            "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
        },
    }
    STATIC_ROOT = os.path.join(BASE_DIR, "staticfiles_prod")
    CSRF_TRUSTED_ORIGINS = [FRONTEND_SITE_URL]

    LOG_DIR = os.getenv("LOG_DIR", os.path.join(os.path.dirname(BASE_DIR), "logs"))
    os.makedirs(LOG_DIR, exist_ok=True)
