"""Sync CoinGecko market data into the DB with throttle + graceful degradation."""
import logging
import os
from datetime import timedelta
from decimal import Decimal, InvalidOperation

from django.core.cache import cache
from django.utils import timezone

from . import coingecko
from .models import Coin, MarketSnapshot, PriceSnapshot

logger = logging.getLogger(__name__)

SYNC_THROTTLE_SECONDS = int(os.getenv("CRYPTO_SYNC_THROTTLE_SECONDS", "300"))
CACHE_TTL = int(os.getenv("CRYPTO_CACHE_TTL", "300"))
LAST_SYNC_CACHE_KEY = "crypto:last_market_sync"


def _dec(value):
    if value is None:
        return None
    try:
        return Decimal(str(value))
    except (InvalidOperation, ValueError, TypeError):
        return None


def is_stale(dt, ttl_seconds=SYNC_THROTTLE_SECONDS):
    if dt is None:
        return True
    return timezone.now() - dt > timedelta(seconds=ttl_seconds)


def _throttled():
    return cache.get(LAST_SYNC_CACHE_KEY) is not None


def _mark_synced():
    cache.set(LAST_SYNC_CACHE_KEY, True, SYNC_THROTTLE_SECONDS)


def sync_markets(per_page=50, force=False):
    """Fetch /coins/markets and upsert Coins + PriceSnapshots. Returns (synced, stale)."""
    if not force and _throttled():
        return False, True
    try:
        rows = coingecko.fetch_markets(per_page=per_page)
    except coingecko.CoinGeckoRateLimited:
        logger.warning("CoinGecko rate limited; serving stale data")
        return False, True
    except coingecko.CoinGeckoError as exc:
        logger.warning("CoinGecko sync failed: %s", exc)
        return False, True

    now = timezone.now()
    for row in rows:
        coin, _ = Coin.objects.update_or_create(
            symbol=(row.get("symbol") or "").upper(),
            defaults={
                "name": row.get("name") or "",
                "coingecko_id": row.get("id") or "",
                "image_url": row.get("image") or "",
                "current_price_usd": _dec(row.get("current_price")),
                "price_change_24h_pct": _dec(row.get("price_change_percentage_24h")),
                "volume_24h_usd": _dec(row.get("total_volume")),
                "market_cap_usd": _dec(row.get("market_cap")),
                "circulating_supply": _dec(row.get("circulating_supply")),
                "total_supply": _dec(row.get("total_supply")),
                "last_synced_at": now,
            },
        )
        PriceSnapshot.objects.create(
            coin=coin,
            price_usd=_dec(row.get("current_price")) or Decimal("0"),
            market_cap=_dec(row.get("market_cap")),
            volume_24h_usd=_dec(row.get("total_volume")),
            recorded_at=now,
        )
    try:
        g = coingecko.fetch_global()
        data = (g or {}).get("data", {})
        totals = data.get("total_market_cap", {}) or {}
        volumes = data.get("total_volume", {}) or {}
        dominance = data.get("market_cap_percentage", {}) or {}
        MarketSnapshot.objects.create(
            total_market_cap_usd=_dec(totals.get("usd")),
            total_volume_24h_usd=_dec(volumes.get("usd")),
            btc_dominance_pct=_dec(dominance.get("btc")),
        )
    except coingecko.CoinGeckoError as exc:
        logger.warning("CoinGecko /global failed: %s", exc)
    _mark_synced()
    return True, False


SEED_COINS = [
    ("BTC", "Bitcoin", "bitcoin", 67000, 2.5, 35_000_000_000, 1_320_000_000_000, 19_700_000, 21_000_000),
    ("ETH", "Ethereum", "ethereum", 3500, 3.1, 18_000_000_000, 420_000_000_000, 120_300_000, None),
    ("SOL", "Solana", "solana", 170, 5.4, 4_200_000_000, 78_000_000_000, 460_000_000, None),
    ("BNB", "BNB", "binancecoin", 600, 1.2, 1_800_000_000, 89_000_000_000, 147_000_000, 200_000_000),
    ("XRP", "XRP", "ripple", 0.62, -0.8, 1_200_000_000, 34_000_000_000, 55_000_000_000, 100_000_000_000),
    ("DOGE", "Dogecoin", "dogecoin", 0.16, 4.2, 900_000_000, 23_000_000_000, 143_000_000_000, None),
    ("ADA", "Cardano", "cardano", 0.45, -1.5, 400_000_000, 16_000_000_000, 35_600_000_000, 45_000_000_000),
    ("AVAX", "Avalanche", "avalanche-2", 36, 2.1, 500_000_000, 13_500_000_000, 377_000_000, 720_000_000),
    ("LINK", "Chainlink", "chainlink", 14.5, 3.8, 380_000_000, 8_500_000_000, 587_000_000, 1_000_000_000),
    ("DOT", "Polkadot", "polkadot", 7.2, -0.5, 250_000_000, 9_400_000_000, 1_300_000_000, None),
]


def seed_mock():
    """Deterministic offline seed: 10 coins + 30 daily snapshots each + market snapshot."""
    from datetime import timedelta as td

    now = timezone.now()
    for i, (sym, name, cg_id, price, chg, vol, mcap, circ, total) in enumerate(SEED_COINS):
        coin, _ = Coin.objects.update_or_create(
            symbol=sym,
            defaults={
                "name": name,
                "coingecko_id": cg_id,
                "current_price_usd": Decimal(str(price)),
                "price_change_24h_pct": Decimal(str(chg)),
                "volume_24h_usd": Decimal(str(vol)),
                "market_cap_usd": Decimal(str(mcap)),
                "circulating_supply": Decimal(str(circ)) if circ else None,
                "total_supply": Decimal(str(total)) if total else None,
                "last_synced_at": now,
            },
        )
        if not coin.price_snapshots.exists():
            base = Decimal(str(price))
            for d in range(30, 0, -1):
                drift = Decimal("1") + Decimal(str((i - d) * 0.002))
                PriceSnapshot.objects.create(
                    coin=coin,
                    price_usd=(base * drift).quantize(Decimal("0.00000001")),
                    market_cap=Decimal(str(mcap)),
                    volume_24h_usd=Decimal(str(vol)),
                    recorded_at=now - td(days=d),
                )
    if not MarketSnapshot.objects.exists():
        MarketSnapshot.objects.create(
            total_market_cap_usd=Decimal("2350000000000"),
            total_volume_24h_usd=Decimal("85000000000"),
            btc_dominance_pct=Decimal("54.2"),
        )
    return len(SEED_COINS)
