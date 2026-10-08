import os

import structlog
from configurations import Configuration
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class Common(Configuration):
    INSTALLED_APPS = [
        "django.contrib.admin",
        "django.contrib.auth",
        "django.contrib.contenttypes",
        "django.contrib.sessions",
        "django.contrib.messages",
        "whitenoise.runserver_nostatic",
        "django.contrib.staticfiles",
        "django_filters",
        "rest_framework",
        "rest_framework.authtoken",
        "corsheaders",
        # Local apps
        "users",
        "core",
        "research",
    ]

    MIDDLEWARE = [
        "django.middleware.security.SecurityMiddleware",
        "whitenoise.middleware.WhiteNoiseMiddleware",
        "django.contrib.sessions.middleware.SessionMiddleware",
        "corsheaders.middleware.CorsMiddleware",
        "django.middleware.common.CommonMiddleware",
        "django.middleware.csrf.CsrfViewMiddleware",
        "django.contrib.auth.middleware.AuthenticationMiddleware",
        "django.contrib.messages.middleware.MessageMiddleware",
        "django.middleware.clickjacking.XFrameOptionsMiddleware",
    ]

    ALLOWED_HOSTS = ["*"]
    ALLOWED_HOSTS.extend(
        filter(
            None,
            os.environ.get("DJANGO_ALLOWED_HOSTS", "").split(","),
        )
    )

    ROOT_URLCONF = "config.urls"
    SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY", "dev-insecure-secret-key-change-me")
    WSGI_APPLICATION = "config.wsgi.application"

    AUTHENTICATION_BACKENDS = [
        "django.contrib.auth.backends.ModelBackend",
    ]

    AUTH_USER_MODEL = "users.User"

    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql_psycopg2",
            "NAME": os.getenv("DB_NAME", "postgres"),
            "USER": os.getenv("DB_USER", "postgres"),
            "PASSWORD": os.getenv("DB_PASSWORD", "postgres"),
            "HOST": os.getenv("DB_HOST", "localhost"),
            "PORT": os.getenv("DB_PORT", 5432),
            "CONN_MAX_AGE": int(os.getenv("DB_CONN_MAX_AGE", 600)),
            "OPTIONS": {
                "connect_timeout": 10,
                "application_name": "crypto_api",
                "sslmode": os.getenv("DB_SSL_MODE", "prefer"),
            },
        }
    }

    # No Redis: local-memory cache + DB sessions
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
        }
    }
    SESSION_ENGINE = "django.contrib.sessions.backends.db"
    SESSION_COOKIE_AGE = 7 * 24 * 60 * 60
    SESSION_SAVE_EVERY_REQUEST = True
    SESSION_EXPIRE_AT_BROWSER_CLOSE = False
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SECURE = False
    SESSION_COOKIE_SAMESITE = "Lax"

    APPEND_SLASH = False
    TIME_ZONE = "UTC"
    LANGUAGE_CODE = "en-us"
    USE_I18N = False
    USE_TZ = True

    STATIC_ROOT = os.path.join(BASE_DIR, "staticfiles")
    STATICFILES_DIRS = [os.path.join(os.path.dirname(BASE_DIR), "static")]
    STATIC_URL = "/static/"
    STATICFILES_FINDERS = (
        "django.contrib.staticfiles.finders.FileSystemFinder",
        "django.contrib.staticfiles.finders.AppDirectoriesFinder",
    )

    MEDIA_ROOT = os.path.join(os.path.dirname(BASE_DIR), "media")
    MEDIA_URL = "/media/"

    TEMPLATES = [
        {
            "BACKEND": "django.template.backends.django.DjangoTemplates",
            "DIRS": [os.path.join(os.path.dirname(BASE_DIR), "templates")],
            "APP_DIRS": True,
            "OPTIONS": {
                "context_processors": [
                    "django.template.context_processors.debug",
                    "django.template.context_processors.request",
                    "django.contrib.auth.context_processors.auth",
                    "django.contrib.messages.context_processors.messages",
                ],
            },
        },
    ]

    DEBUG = os.environ.get("DJANGO_DEBUG", False) in ["True", "true", "TRUE", "1"]

    AUTH_PASSWORD_VALIDATORS = [
        {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
        {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
        {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
        {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
    ]

    DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

    REST_FRAMEWORK = {
        "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
        "PAGE_SIZE": int(os.getenv("DJANGO_PAGINATION_LIMIT", 25)),
        "DATETIME_FORMAT": "%Y-%m-%dT%H:%M:%S%z",
        "DEFAULT_RENDERER_CLASSES": (
            "rest_framework.renderers.JSONRenderer",
            "rest_framework.renderers.BrowsableAPIRenderer",
        ),
        "DEFAULT_PERMISSION_CLASSES": [
            "rest_framework.permissions.IsAuthenticated",
            "users.permissions.IsActiveUser",
        ],
        "DEFAULT_AUTHENTICATION_CLASSES": (
            "rest_framework.authentication.TokenAuthentication",
            "rest_framework.authentication.SessionAuthentication",
        ),
        "DEFAULT_FILTER_BACKENDS": (
            "django_filters.rest_framework.DjangoFilterBackend",
            "rest_framework.filters.SearchFilter",
            "rest_framework.filters.OrderingFilter",
        ),
    }

    FRONTEND_SITE_URL = os.getenv("FRONTEND_SITE_URL", "http://localhost:3000")
    CSRF_TRUSTED_ORIGINS = ["http://localhost:80", "http://localhost:8000", FRONTEND_SITE_URL]
    FRONTEND_LOGIN_URL = os.getenv("FRONTEND_LOGIN_URL", "http://localhost:3000/login")

    USE_X_FORWARDED_HOST = True
    USE_X_FORWARDED_PORT = True
    SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

    structlog.configure(
        processors=[
            structlog.stdlib.filter_by_level,
            structlog.stdlib.add_logger_name,
            structlog.stdlib.add_log_level,
            structlog.stdlib.PositionalArgumentsFormatter(),
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.UnicodeDecoder(),
            structlog.stdlib.ProcessorFormatter.wrap_for_formatter,
        ],
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        wrapper_class=structlog.stdlib.BoundLogger,
        cache_logger_on_first_use=True,
    )

    LOGGING = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "json_formatter": {
                "()": "structlog.stdlib.ProcessorFormatter",
                "processor": structlog.processors.JSONRenderer(),
                "foreign_pre_chain": [
                    structlog.stdlib.add_log_level,
                    structlog.stdlib.add_logger_name,
                    structlog.processors.TimeStamper(fmt="iso"),
                ],
            },
        },
        "handlers": {
            "console": {
                "class": "logging.StreamHandler",
                "formatter": "json_formatter",
            },
        },
        "root": {
            "handlers": ["console"],
            "level": "ERROR",
        },
    }
