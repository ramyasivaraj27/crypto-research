from rest_framework import serializers

from .models import Coin, MarketSnapshot, PriceSnapshot, ResearchNote, Watchlist, WatchlistItem


class CoinSerializer(serializers.ModelSerializer):
    is_stale = serializers.SerializerMethodField()

    class Meta:
        model = Coin
        fields = [
            "id", "symbol", "name", "coingecko_id", "image_url",
            "current_price_usd", "price_change_24h_pct", "volume_24h_usd",
            "market_cap_usd", "circulating_supply", "total_supply",
            "last_synced_at", "is_stale", "created_at",
        ]
        read_only_fields = ["id", "created_at", "last_synced_at", "is_stale"]

    def get_is_stale(self, obj):
        from .services import is_stale

        return is_stale(obj.last_synced_at)


class WatchlistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Watchlist
        fields = ["id", "name", "created_at"]
        read_only_fields = ["id", "created_at"]


class WatchlistItemSerializer(serializers.ModelSerializer):
    coin = CoinSerializer(read_only=True)
    coin_id = serializers.PrimaryKeyRelatedField(queryset=Coin.objects.all(), source="coin", write_only=True)

    class Meta:
        model = WatchlistItem
        fields = ["id", "watchlist", "coin", "coin_id", "added_at"]
        read_only_fields = ["id", "added_at"]


class ResearchNoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = ResearchNote
        fields = ["id", "coin", "title", "body", "created_at", "updated_at"]
        read_only_fields = ["id", "created_at", "updated_at"]


class PriceSnapshotSerializer(serializers.ModelSerializer):
    class Meta:
        model = PriceSnapshot
        fields = ["id", "coin", "price_usd", "market_cap", "volume_24h_usd", "recorded_at"]
        read_only_fields = ["id"]


class PricePointSerializer(serializers.Serializer):
    """Lightweight chart point: [timestamp_ms, price]."""

    t = serializers.IntegerField()
    price = serializers.DecimalField(max_digits=20, decimal_places=8)


class MarketSnapshotSerializer(serializers.ModelSerializer):
    is_stale = serializers.SerializerMethodField()

    class Meta:
        model = MarketSnapshot
        fields = [
            "id", "total_market_cap_usd", "total_volume_24h_usd",
            "btc_dominance_pct", "recorded_at", "is_stale",
        ]

    def get_is_stale(self, obj):
        from .services import is_stale

        return is_stale(obj.recorded_at)
