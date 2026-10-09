from django.contrib import admin

from .models import Coin, MarketSnapshot, PriceSnapshot, ResearchNote, Watchlist, WatchlistItem


@admin.register(Coin)
class CoinAdmin(admin.ModelAdmin):
    list_display = ["symbol", "name", "current_price_usd", "market_cap_usd", "last_synced_at"]
    search_fields = ["symbol", "name"]


@admin.register(Watchlist)
class WatchlistAdmin(admin.ModelAdmin):
    list_display = ["user", "name", "created_at"]


@admin.register(WatchlistItem)
class WatchlistItemAdmin(admin.ModelAdmin):
    list_display = ["watchlist", "coin", "added_at"]


@admin.register(ResearchNote)
class ResearchNoteAdmin(admin.ModelAdmin):
    list_display = ["user", "coin", "title", "created_at"]
    search_fields = ["title", "body"]


@admin.register(PriceSnapshot)
class PriceSnapshotAdmin(admin.ModelAdmin):
    list_display = ["coin", "price_usd", "recorded_at"]


@admin.register(MarketSnapshot)
class MarketSnapshotAdmin(admin.ModelAdmin):
    list_display = ["total_market_cap_usd", "btc_dominance_pct", "recorded_at"]
