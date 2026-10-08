from django.conf import settings
from django.db import models


class Coin(models.Model):
    symbol = models.CharField(max_length=20, unique=True, db_index=True)
    name = models.CharField(max_length=100)
    coingecko_id = models.CharField(max_length=100, blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["symbol"]

    def __str__(self):
        return self.symbol


class Watchlist(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="watchlists")
    name = models.CharField(max_length=100, default="Default")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [("user", "name")]
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.user} / {self.name}"


class WatchlistItem(models.Model):
    watchlist = models.ForeignKey(Watchlist, on_delete=models.CASCADE, related_name="items")
    coin = models.ForeignKey(Coin, on_delete=models.CASCADE, related_name="watchlist_items")
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [("watchlist", "coin")]


class ResearchNote(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="research_notes")
    coin = models.ForeignKey(Coin, on_delete=models.SET_NULL, null=True, blank=True, related_name="notes")
    title = models.CharField(max_length=200)
    body = models.TextField(blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["user", "-created_at"]),
            models.Index(fields=["coin", "-created_at"]),
        ]

    def __str__(self):
        return self.title


class PriceSnapshot(models.Model):
    coin = models.ForeignKey(Coin, on_delete=models.CASCADE, related_name="price_snapshots")
    price_usd = models.DecimalField(max_digits=20, decimal_places=8)
    market_cap = models.DecimalField(max_digits=24, decimal_places=2, null=True, blank=True)
    recorded_at = models.DateTimeField(db_index=True)

    class Meta:
        ordering = ["-recorded_at"]
        indexes = [
            models.Index(fields=["coin", "-recorded_at"]),
        ]
