import os

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.develop")
os.environ.setdefault("DJANGO_CONFIGURATION", "Develop")

from configurations import importer  # noqa: E402

importer.install()
