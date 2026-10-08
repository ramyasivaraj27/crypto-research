import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../models/market.dart';
import '../providers/watchlist_provider.dart';
import '../utils/format.dart';
import '../widgets/price_chart.dart';
import '../widgets/state_views.dart';

class CoinDetailScreen extends StatefulWidget {
  final Coin coin;
  const CoinDetailScreen({super.key, required this.coin});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  int days = 7;
  List<PricePoint> points = [];
  bool loading = true;
  bool offline = false;
  String error = '';

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
      points = raw.cast<Map<String, dynamic>>().map(PricePoint.fromJson).toList();
      offline = false;
      await cache.save('history:${widget.coin.id}:$days', raw);
    } on ApiException catch (e) {
      error = e.message;
      final hit = await cache.load('history:${widget.coin.id}:$days');
      if (hit.data != null) {
        points = (hit.data as List).cast<Map<String, dynamic>>().map(PricePoint.fromJson).toList();
        offline = true;
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.coin;
    final up = (c.change24h ?? 0) >= 0;
    final starred = context.select<WatchlistProvider, bool>((w) => w.starredIds.contains(c.id));
    return Scaffold(
      appBar: AppBar(
        title: Text('${c.name} (${c.symbol})'),
        actions: [
          IconButton(
            icon: Icon(starred ? Icons.star : Icons.star_border, color: starred ? Colors.amber : null),
            onPressed: () => context.read<WatchlistProvider>().toggle(c.id),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            if (offline) const OfflineBadge(savedAgo: 'last sync'),
            if (c.isStale || offline)
              Container(
                width: double.infinity,
                color: Colors.orange.shade100,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: const Text('Live data delayed — showing saved prices', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fmtPrice(c.price), style: Theme.of(context).textTheme.headlineMedium),
                  Text(fmtPct(c.change24h), style: TextStyle(fontSize: 18, color: up ? Colors.green : Colors.red)),
                  const SizedBox(height: 12),
                  _stat('Market cap', fmtCompact(c.marketCap)),
                  _stat('24h volume', fmtCompact(c.volume24h)),
                  _stat('Circulating supply', '${fmtSupply(c.circulating)} ${c.symbol}'),
                  _stat('Total supply', c.total == null ? '—' : '${fmtSupply(c.total)} ${c.symbol}'),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [7, 30].map((d) => ChoiceChip(label: Text('${d}d'), selected: days == d, onSelected: (_) {
                    setState(() => days = d);
                    _load();
                  })).toList(),
            ),
            if (loading)
              const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()))
            else if (error.isNotEmpty && points.isEmpty)
              ErrorView(message: error, onRetry: _load)
            else
              PriceChart(points: points),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))],
        ),
      );
}
