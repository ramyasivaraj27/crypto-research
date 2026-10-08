import pytest
from rest_framework.test import APIClient


@pytest.mark.django_db
def test_register_login_me_logout():
    client = APIClient()
    res = client.post(
        "/api/users/register/",
        {"username": "alice", "email": "alice@example.com", "name": "Alice", "password": "pass12345"},
        format="json",
    )
    assert res.status_code == 201, res.content
    token = res.data["token"]

    client.credentials(HTTP_AUTHORIZATION=f"Token {token}")
    me = client.get("/api/users/me/")
    assert me.status_code == 200
    assert me.data["username"] == "alice"

    out = client.post("/api/users/logout/")
    assert out.status_code == 204
