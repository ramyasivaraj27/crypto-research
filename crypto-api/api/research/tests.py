import pytest
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient


@pytest.mark.django_db
def test_research_crud():
    User = get_user_model()
    user = User.objects.create_user(username="bob", email="bob@example.com", password="pass12345")
    token, _ = Token.objects.get_or_create(user=user)
    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")

    coin = client.post("/api/research/coins/", {"symbol": "BTC", "name": "Bitcoin"}, format="json")
    assert coin.status_code == 201, coin.content

    wl = client.post("/api/research/watchlists/", {"name": "Long term"}, format="json")
    assert wl.status_code == 201, wl.content

    note = client.post(
        "/api/research/notes/",
        {"coin": coin.data["id"], "title": "Thesis", "body": "Scarce asset"},
        format="json",
    )
    assert note.status_code == 201, note.content

    listing = client.get("/api/research/notes/")
    assert listing.status_code == 200
    assert listing.data["count"] == 1
