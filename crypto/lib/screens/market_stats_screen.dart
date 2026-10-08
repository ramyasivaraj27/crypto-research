import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../models/market.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/coin_tile.dart';
import '../widgets/state_views.dart';

class MarketStatsScreen extends StatefulWidget {
  final bool showBack;
  const MarketStatsScreen({super.key, this.showBack = false});
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
        try {
          data = MarketOverview.fromJson((hit.data as Map).cast<String, dynamic>());
          savedAt = hit.savedAt;
          offline = true;
        } catch (_) {
          error = e.toString();
        }
      } else {
        error = e.toString();
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showBack ? AppBar(leading: const BackButton()) : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    if (loading) return const LoadingView();
    if (data == null) {
      if (error.contains('No market data')) {
        return const EmptyView(
            message: 'No market data yet. Ask the backend to sync, then pull to refresh.');
      }
      return ErrorView(
          message: error.isEmpty ? 'Failed to load market stats.' : error, onRetry: _load);
    }
    final m = data!;
    return ListView(
      children: [
        if (offline && savedAt != null) OfflineBadge(savedAgo: fmtAgo(savedAt)),
        const SectionTitle(text: 'Market Statistics'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Column(
                children: [
                  _row('Total Market Cap', fmtCompact(m.totalMcap)),
                  _row('24h Volume', fmtCompact(m.totalVolume)),
                  _row('BTC Dominance',
                      m.btcDom == null ? '—' : '${m.btcDom!.toStringAsFixed(1)}%', last: true),
                ],
              ),
            ),
          ),
        ),
        const SectionTitle(text: 'Top 10 by Market Cap'),
        ...[for (var i = 0; i < m.top.length; i++) CoinTile(coin: m.top[i], rank: i + 1)],
        const SizedBox(height: 16),
      ],
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
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
          if (!last) const Divider(height: 1),
        ],
      );
}
