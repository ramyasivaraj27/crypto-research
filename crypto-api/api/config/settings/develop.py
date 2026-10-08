from .common import Common


class Develop(Common):
    ALLOWED_HOSTS = ["*"]
    DEBUG = True
    CORS_ALLOW_ALL_ORIGINS = True
