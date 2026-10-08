import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../models/market.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/price_chart.dart';
import '../widgets/state_views.dart';

/// Coin detail in the reference style: icon + name, big price + pill,
/// green chart with MIN/MAX, range selector, Market Data card.
class CoinDetailScreen extends StatefulWidget {
  final Coin coin;
  const CoinDetailScreen({super.key, required this.coin});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

const _ranges = <String, int>{'24H': 1, '1W': 7, '1M': 30, '6M': 90, '1Y': 90, 'MAX': 90};

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  String range = '1W';
  List<PricePoint> points = [];
  bool loading = true;
  bool offline = false;
  String error = '';

  int get days => _ranges[range]!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<ApiClient>();
    final cache = context.read<CacheStore>();
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final raw = await api.history(widget.coin.id, days: days);
      points = [for (final row in raw) PricePoint.tryFromJson(row)].whereType<PricePoint>().toList();
      offline = false;
      await cache.save('history:${widget.coin.id}:$days', raw);
    } on ApiException catch (e) {
      error = e.message;
      final hit = await cache.load('history:${widget.coin.id}:$days');
      if (hit.data != null) {
        points = [for (final row in (hit.data as List)) PricePoint.tryFromJson(row)].whereType<PricePoint>().toList();
        offline = true;
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.coin;
    final starred = context.select<WatchlistProvider, bool>((w) => w.starredIds.contains(c.id));
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
            color: AppColors.chartLine,
            backgroundColor: AppColors.card,
          onRefresh: _load,
          child: ListView(
            children: [
              _topBar(starred),
              _header(c),
              _priceBlock(c),
              if (offline) const OfflineBadge(savedAgo: 'last sync'),
              if (loading)
                const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()))
              else if (error.isNotEmpty && points.isEmpty)
                ErrorView(message: error, onRetry: _load)
              else
                PriceChart(points: points),
              _rangeSelector(),
              const SectionTitle(text: 'Market Data'),
              _marketDataCard(c),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(bool starred) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.of(context).pop()),
            IconButton(
              icon: Icon(starred ? Icons.star : Icons.star_border,
                  color: starred ? Colors.amber : Colors.white),
              onPressed: () => context.read<WatchlistProvider>().toggle(widget.coin.id),
            ),
          ],
        ),
      );

  Widget _header(Coin c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            ClipOval(
              child: c.imageUrl.isNotEmpty
                  ? Image.network(c.imageUrl, width: 52, height: 52,
                      errorBuilder: (_, __, ___) => const _BigFallbackIcon())
                  : const _BigFallbackIcon(),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                Text(c.symbol, style: const TextStyle(color: AppColors.muted, fontSize: 15)),
              ],
            ),
          ],
        ),
      );

  Widget _priceBlock(Coin c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(fmtPrice(c.price),
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            ChangePill(change: c.change24h),
          ],
        ),
      );

  Widget _rangeSelector() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardPressed),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              for (final label in _ranges.keys) Expanded(child: _rangeChip(label)),
            ],
          ),
        ),
      );

  Widget _rangeChip(String label) {
    final selected = range == label;
    return GestureDetector(
      onTap: () {
        if (range == label) return;
        setState(() => range = label);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.selectedPill : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.muted)),
      ),
    );
  }

  Widget _marketDataCard(Coin c) {
    double? hi, lo;
    for (final p in points) {
      hi = hi == null || p.price > hi ? p.price : hi;
      lo = lo == null || p.price < lo ? p.price : lo;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Column(
            children: [
              _row('Market Cap', fmtCompact(c.marketCap)),
              _row('Trading Volume 24h', fmtCompact(c.volume24h)),
              _row('Highest Price ($range)', hi == null ? '—' : fmtPrice(hi)),
              _row('Lowest Price ($range)', lo == null ? '—' : fmtPrice(lo)),
              _row('Available Supply', '${fmtSupply(c.circulating)} ${c.symbol}', last: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool last = false}) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
          if (!last) const Divider(height: 1),
        ],
      );
}

class _BigFallbackIcon extends StatelessWidget {
  const _BigFallbackIcon();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(color: Color(0xFFF7931A), shape: BoxShape.circle),
      child: const Icon(Icons.currency_bitcoin, color: Colors.white, size: 34),
    );
  }
}
