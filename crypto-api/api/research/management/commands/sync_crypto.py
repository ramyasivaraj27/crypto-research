from django.core.management.base import BaseCommand

from research.services import seed_mock, sync_markets


class Command(BaseCommand):
    help = "Sync crypto market data. --live hits CoinGecko, --seed loads offline mock data."

    def add_arguments(self, parser):
        parser.add_argument("--live", action="store_true", help="Fetch live data from CoinGecko")
        parser.add_argument("--seed", action="store_true", help="Load deterministic mock data (offline)")
        parser.add_argument("--per-page", type=int, default=50)
        parser.add_argument("--force", action="store_true", help="Bypass the sync throttle")

    def handle(self, *args, **opts):
        if opts["seed"]:
            n = seed_mock()
            self.stdout.write(self.style.SUCCESS(f"Seeded {n} mock coins"))
            return
        if opts["live"]:
            synced, stale = sync_markets(per_page=opts["per_page"], force=opts["force"])
            if synced:
                self.stdout.write(self.style.SUCCESS("Live sync complete"))
            else:
                self.stdout.write(self.style.WARNING("Sync skipped (throttled) or upstream failed; serving stored data"))
            return
        self.stdout.write("Pass --live or --seed")
