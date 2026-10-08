from rest_framework import permissions, viewsets

from .models import Coin, PriceSnapshot, ResearchNote, Watchlist, WatchlistItem
from .serializers import (
    CoinSerializer,
    PriceSnapshotSerializer,
    ResearchNoteSerializer,
    WatchlistItemSerializer,
    WatchlistSerializer,
)


class CoinViewSet(viewsets.ModelViewSet):
    queryset = Coin.objects.all()
    serializer_class = CoinSerializer
    filterset_fields = ["symbol"]
    search_fields = ["symbol", "name"]


class WatchlistViewSet(viewsets.ModelViewSet):
    serializer_class = WatchlistSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Watchlist.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class WatchlistItemViewSet(viewsets.ModelViewSet):
    serializer_class = WatchlistItemSerializer

    def get_queryset(self):
        return WatchlistItem.objects.filter(watchlist__user=self.request.user)


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
    filterset_fields = ["coin"]
    ordering = ["-recorded_at"]
