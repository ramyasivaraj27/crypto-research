from rest_framework.routers import DefaultRouter

from .views import (
    CoinViewSet,
    PriceSnapshotViewSet,
    ResearchNoteViewSet,
    WatchlistItemViewSet,
    WatchlistViewSet,
)

router = DefaultRouter()
router.register("coins", CoinViewSet, basename="coin")
router.register("watchlists", WatchlistViewSet, basename="watchlist")
router.register("watchlist-items", WatchlistItemViewSet, basename="watchlist-item")
router.register("notes", ResearchNoteViewSet, basename="note")
router.register("prices", PriceSnapshotViewSet, basename="price")

urlpatterns = router.urls
