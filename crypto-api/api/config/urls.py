import os

from django.contrib import admin
from django.urls import include, path

from core import views as core_views

urlpatterns = [
    path(os.environ.get("DJANGO_ADMIN_BASE_PATH", "admin/"), admin.site.urls),
    path("api/health/", core_views.health_check, name="health_check"),
    path("api/users/", include("users.urls")),
    path("api/research/", include("research.urls")),
]
