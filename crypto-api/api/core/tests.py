import pytest
from django.urls import reverse
from rest_framework.test import APIClient


@pytest.mark.django_db
def test_health_check():
    client = APIClient()
    res = client.get("/api/health/")
    assert res.status_code == 200
    assert res.data["healthy"] is True
