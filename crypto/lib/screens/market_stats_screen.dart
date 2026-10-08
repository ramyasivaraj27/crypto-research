import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../models/market.dart';
import '../utils/format.dart';
import '../widgets/coin_tile.dart';
import '../widgets/state_views.dart';

class MarketStatsScreen extends StatefulWidget {
  const MarketStatsScreen({super.key});
  @override
  State<MarketStatsScreen> createState() => _MarketStatsScreenState();
}

class _MarketStatsScreenState extends State<MarketStatsScreen> {
  MarketOverview? data;
  bool loading = true;
  bool offline = false;
  String error = '';
  DateTime? savedAt;

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
      final raw = await api.market();
      data = MarketOverview.fromJson(raw);
      offline = false;
      savedAt = DateTime.now();
      await cache.save('market', raw);
    } catch (e) {
      final hit = await cache.load('market');
      if (hit.data != null) {
        data = MarketOverview.fromJson((hit.data as Map).cast<String, dynamic>());
        savedAt = hit.savedAt;
        offline = true;
      } else {
        error = e.toString();
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (loading) return const LoadingView();
    if (data == null) {
      if (error.contains('404')) {
        return const EmptyView(message: 'No market data yet. Ask the backend to sync, then pull to refresh.');
      }
      return ErrorView(message: error.isEmpty ? 'Failed to load market stats.' : error, onRetry: _load);
    }
    final m = data!;
    return ListView(
      children: [
        if (offline && savedAt != null) OfflineBadge(savedAgo: fmtAgo(savedAt)),
        if (m.isStale)
          Container(
            width: double.infinity,
            color: Colors.orange.shade100,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: const Text('Live data delayed — showing saved totals', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _big('Total market cap', fmtCompact(m.totalMcap)),
              _big('24h volume', fmtCompact(m.totalVolume)),
              _big('BTC dominance', m.btcDom == null ? '—' : '${m.btcDom!.toStringAsFixed(1)}%'),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Top 10 by market cap', style: TextStyle(fontWeight: FontWeight.bold))),
        ...m.top.map((c) => CoinTile(coin: c)),
      ],
    );
  }

  Widget _big(String label, String value) => Card(
        child: ListTile(title: Text(label, style: const TextStyle(color: Colors.grey)), trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      );
}
