"""Thin CoinGecko free-API client (keyless, optional demo-key passthrough).

Endpoints used:
- GET /coins/markets (price, market cap, volume, supply, 24h change, image)
- GET /coins/{id}/market_chart (price history for charts)
- GET /global (global market totals)

Rate limits on the free tier are aggressive (~5-15 calls/min shared), so callers
must throttle (see services.SYNC_THROTTLE_SECONDS) and cache.
"""
import logging
import os

import requests

logger = logging.getLogger(__name__)

BASE_URL = os.getenv("COINGECKO_BASE_URL", "https://api.coingecko.com/api/v3")
TIMEOUT = int(os.getenv("COINGECKO_TIMEOUT", "10"))


class CoinGeckoError(Exception):
    pass


class CoinGeckoRateLimited(CoinGeckoError):
    pass


def _headers():
    key = os.getenv("COINGECKO_API_KEY", "")
    if key:
        return {"x-cg-demo-api-key": key}
    return {}


def _get(path, params=None):
    url = f"{BASE_URL}{path}"
    try:
        res = requests.get(url, params=params or {}, headers=_headers(), timeout=TIMEOUT)
    except requests.RequestException as exc:
        raise CoinGeckoError(f"Network error calling CoinGecko {path}: {exc}") from exc
    if res.status_code == 429:
        raise CoinGeckoRateLimited("CoinGecko rate limit hit (429)")
    if not res.ok:
        raise CoinGeckoError(f"CoinGecko {path} returned {res.status_code}")
    return res.json()


def fetch_markets(vs_currency="usd", per_page=50, page=1):
    """Returns list of market dicts for top coins by market cap."""
    return _get(
        "/coins/markets",
        {
            "vs_currency": vs_currency,
            "order": "market_cap_desc",
            "per_page": per_page,
            "page": page,
            "sparkline": "false",
            "price_change_percentage": "24h",
        },
    )


def fetch_market_chart(coingecko_id, days=7, vs_currency="usd"):
    """Returns {'prices': [[ts_ms, price], ...], ...}."""
    return _get(f"/coins/{coingecko_id}/market_chart", {"vs_currency": vs_currency, "days": days})


def fetch_global():
    return _get("/global")
