from rest_framework import serializers

from .models import Coin, PriceSnapshot, ResearchNote, Watchlist, WatchlistItem


class CoinSerializer(serializers.ModelSerializer):
    class Meta:
        model = Coin
        fields = ["id", "symbol", "name", "coingecko_id", "created_at"]
        read_only_fields = ["id", "created_at"]


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
        fields = ["id", "coin", "price_usd", "market_cap", "recorded_at"]
        read_only_fields = ["id"]
