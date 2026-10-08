from decimal import Decimal
from unittest.mock import patch

import pytest
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient

from research.models import Coin, MarketSnapshot


def _authed_client():
    User = get_user_model()
    user = User.objects.create_user(username="ramya", email="ramya@example.com", password="pass12345")
    token, _ = Token.objects.get_or_create(user=user)
    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")
    return client


@pytest.mark.django_db
def test_research_crud():
    client = _authed_client()

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


FAKE_MARKETS = [
    {
        "id": "bitcoin", "symbol": "btc", "name": "Bitcoin",
        "image": "https://img/btc.png", "current_price": 67000,
        "price_change_percentage_24h": 2.5, "total_volume": 35_000_000_000,
        "market_cap": 1_320_000_000_000, "circulating_supply": 19_700_000,
        "total_supply": 21_000_000,
    },
    {
        "id": "ethereum", "symbol": "eth", "name": "Ethereum",
        "image": "https://img/eth.png", "current_price": 3500,
        "price_change_percentage_24h": -1.2, "total_volume": 18_000_000_000,
        "market_cap": 420_000_000_000, "circulating_supply": 120_300_000,
        "total_supply": None,
    },
]
FAKE_GLOBAL = {"data": {"total_market_cap": {"usd": 2_350_000_000_000}, "total_volume": {"usd": 85_000_000_000}, "market_cap_percentage": {"btc": 54.2}}}


@pytest.mark.django_db
def test_sync_markets_upserts_coins_and_snapshots():
    from research.services import sync_markets

    with patch("research.coingecko.fetch_markets", return_value=FAKE_MARKETS), patch(
        "research.coingecko.fetch_global", return_value=FAKE_GLOBAL
    ):
        synced, stale = sync_markets(force=True)
    assert synced is True and stale is False
    btc = Coin.objects.get(symbol="BTC")
    assert btc.current_price_usd == Decimal("67000")
    assert btc.market_cap_usd == Decimal("1320000000000")
    assert btc.price_snapshots.count() == 1
    assert MarketSnapshot.objects.count() == 1


@pytest.mark.django_db
def test_sync_rate_limited_serves_stale():
    from research import coingecko
    from research.services import sync_markets

    with patch("research.coingecko.fetch_markets", side_effect=coingecko.CoinGeckoRateLimited("429")):
        synced, stale = sync_markets(force=True)
    assert synced is False and stale is True


@pytest.mark.django_db
def test_coin_list_is_public():
    Coin.objects.create(symbol="BTC", name="Bitcoin", market_cap_usd=Decimal("100"))
    client = APIClient()  # no credentials
    res = client.get("/api/research/coins/")
    assert res.status_code == 200
    assert res.data["count"] == 1


@pytest.mark.django_db
def test_coin_search_and_ordering():
    Coin.objects.create(symbol="BTC", name="Bitcoin", market_cap_usd=Decimal("100"), current_price_usd=Decimal("1"))
    Coin.objects.create(symbol="ETH", name="Ethereum", market_cap_usd=Decimal("200"), current_price_usd=Decimal("2"))
    client = _authed_client()

    res = client.get("/api/research/coins/?search=bit")
    assert res.status_code == 200
    assert res.data["count"] == 1

    res = client.get("/api/research/coins/?ordering=-market_cap_usd")
    assert res.status_code == 200
    assert res.data["results"][0]["symbol"] == "ETH"


@pytest.mark.django_db
def test_history_and_market_endpoints():
    from django.utils import timezone

    from research.models import PriceSnapshot

    coin = Coin.objects.create(symbol="BTC", name="Bitcoin", coingecko_id="bitcoin", current_price_usd=Decimal("67000"), market_cap_usd=Decimal("1320000000000"))
    PriceSnapshot.objects.create(coin=coin, price_usd=Decimal("67000"), recorded_at=timezone.now())
    client = _authed_client()

    res = client.get(f"/api/research/coins/{coin.id}/history/?days=7")
    assert res.status_code == 200
    assert len(res.data["points"]) == 1

    assert client.get("/api/research/market/").status_code == 404  # no snapshot yet
    MarketSnapshot.objects.create(total_market_cap_usd=Decimal("100"), btc_dominance_pct=Decimal("50"))
    res = client.get("/api/research/market/")
    assert res.status_code == 200
    assert res.data["market"]["btc_dominance_pct"] == "50.000"
    assert res.data["top_coins"][0]["symbol"] == "BTC"


@pytest.mark.django_db
def test_watchlist_toggle():
    coin = Coin.objects.create(symbol="BTC", name="Bitcoin")
    client = _authed_client()

    res = client.post("/api/research/watchlists/toggle/", {"coin": coin.id}, format="json")
    assert res.status_code == 201
    assert res.data["starred"] is True

    items = client.get("/api/research/watchlist-items/")
    assert items.data["count"] == 1

    res = client.post("/api/research/watchlists/toggle/", {"coin": coin.id}, format="json")
    assert res.status_code == 200
    assert res.data["starred"] is False


@pytest.mark.django_db
def test_refresh_endpoint_syncs_and_throttles():
    from django.core.cache import cache

    cache.clear()
    client = _authed_client()
    with patch("research.coingecko.fetch_markets", return_value=FAKE_MARKETS), patch(
        "research.coingecko.fetch_global", return_value=FAKE_GLOBAL
    ):
        res = client.post("/api/research/coins/refresh/")
    assert res.status_code == 200
    assert res.data["synced"] is True
    assert Coin.objects.filter(symbol="BTC").exists()

    # Second call within throttle window: skipped, still 200
    res = client.post("/api/research/coins/refresh/")
    assert res.status_code == 200
    assert res.data["synced"] is False
    assert res.data["stale"] is True


@pytest.mark.django_db
def test_refresh_endpoint_survives_upstream_failure():
    from research import coingecko

    client = _authed_client()
    with patch("research.coingecko.fetch_markets", side_effect=coingecko.CoinGeckoRateLimited("429")):
        res = client.post("/api/research/coins/refresh/")
    assert res.status_code == 200
    assert res.data == {"synced": False, "stale": True}


@pytest.mark.django_db
def test_coin_list_does_not_hit_network():
    Coin.objects.create(symbol="BTC", name="Bitcoin", market_cap_usd=Decimal("100"))
    client = APIClient()  # public, no credentials
    with patch("research.views.sync_markets") as mock_sync:
        res = client.get("/api/research/coins/")
    assert res.status_code == 200
    mock_sync.assert_not_called()
