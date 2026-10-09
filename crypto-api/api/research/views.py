from django.core.cache import cache
from django.utils import timezone
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response

from . import coingecko
from .models import Coin, MarketSnapshot, PriceSnapshot, ResearchNote, Watchlist, WatchlistItem
from .serializers import (
    CoinSerializer,
    MarketSnapshotSerializer,
    PriceSnapshotSerializer,
    ResearchNoteSerializer,
    WatchlistItemSerializer,
    WatchlistSerializer,
)
from .services import CACHE_TTL, sync_markets


class CoinViewSet(viewsets.ModelViewSet):
    queryset = Coin.objects.all()
    serializer_class = CoinSerializer
    permission_classes = [permissions.AllowAny]
    filterset_fields = ["symbol"]
    search_fields = ["symbol", "name"]
    ordering_fields = ["market_cap_usd", "current_price_usd", "price_change_24h_pct", "volume_24h_usd", "symbol"]
    ordering = ["-market_cap_usd"]

    # NOTE: reads never touch the network. Data comes from the last
    # `sync_crypto --live` run (or --seed). Use POST /coins/refresh/
    # for an explicit throttled live refresh.
    @action(detail=False, methods=["post"], url_path="refresh")
    def refresh(self, request):
        """Throttled live refresh from CoinGecko. Never fails the request:
        on throttle/upstream failure returns the stored data state."""
        try:
            synced, stale = sync_markets()
        except Exception:
            synced, stale = False, True
        return Response(
            {"synced": synced, "stale": stale},
            status=status.HTTP_200_OK,
        )

    @action(detail=True, methods=["get"])
    def history(self, request, pk=None):
        coin = self.get_object()
        try:
            days = int(request.query_params.get("days", "7"))
        except ValueError:
            days = 7
        days = days if days in (1, 7, 30, 90) else 7
        cache_key = f"crypto:history:{coin.id}:{days}"
        points = cache.get(cache_key)
        if points is None:
            qs = coin.price_snapshots.order_by("recorded_at")
            if days <= 31:
                cutoff = timezone.now() - timezone.timedelta(days=days)
                qs = qs.filter(recorded_at__gte=cutoff)
            points = [{"t": int(p.recorded_at.timestamp() * 1000), "price": str(p.price_usd)} for p in qs[:2000]]
            if not points and coin.coingecko_id:
                try:
                    data = coingecko.fetch_market_chart(coin.coingecko_id, days=days)
                    points = [{"t": int(t), "price": str(pr)} for t, pr in (data.get("prices") or [])[:2000]]
                except coingecko.CoinGeckoError:
                    points = []
            cache.set(cache_key, points, CACHE_TTL)
        return Response({"coin": coin.symbol, "days": days, "points": points})


@api_view(["GET"])
@permission_classes([permissions.AllowAny])
def market_overview(request):
    snap = MarketSnapshot.objects.first()
    if snap is None:
        return Response({"detail": "No market data yet. Run sync_crypto --live/--seed."}, status=status.HTTP_404_NOT_FOUND)
    top = Coin.objects.exclude(market_cap_usd__isnull=True).order_by("-market_cap_usd")[:10]
    return Response({
        "market": MarketSnapshotSerializer(snap).data,
        "top_coins": CoinSerializer(top, many=True).data,
    })


class WatchlistViewSet(viewsets.ModelViewSet):
    serializer_class = WatchlistSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Watchlist.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=["post"], url_path="toggle")
    def toggle(self, request):
        """Star/unstar a coin in the default watchlist. Body: {coin: <id>}."""
        coin_id = request.data.get("coin")
        if not coin_id:
            return Response({"detail": "coin is required."}, status=status.HTTP_400_BAD_REQUEST)
        try:
            coin = Coin.objects.get(pk=coin_id)
        except Coin.DoesNotExist:
            return Response({"detail": "Coin not found."}, status=status.HTTP_404_NOT_FOUND)
        watchlist, _ = Watchlist.objects.get_or_create(user=request.user, name="Default")
        item = WatchlistItem.objects.filter(watchlist=watchlist, coin=coin).first()
        if item:
            item.delete()
            return Response({"starred": False, "coin": coin_id})
        WatchlistItem.objects.create(watchlist=watchlist, coin=coin)
        return Response({"starred": True, "coin": coin_id}, status=status.HTTP_201_CREATED)


class WatchlistItemViewSet(viewsets.ModelViewSet):
    serializer_class = WatchlistItemSerializer

    def get_queryset(self):
        return WatchlistItem.objects.filter(watchlist__user=self.request.user).select_related("coin")


class ResearchNoteViewSet(viewsets.ModelViewSet):
    serializer_class = ResearchNoteSerializer
    filterset_fields = ["coin"]

    def get_queryset(self):
        return ResearchNote.objects.filter(user=self.request.user).select_related("coin")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class PriceSnapshotViewSet(viewsets.ModelViewSet):
    queryset = PriceSnapshot.objects.select_related("coin").all()
    serializer_class = PriceSnapshotSerializer
    permission_classes = [permissions.AllowAny]
    filterset_fields = ["coin"]
    ordering = ["-recorded_at"]
