import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../models/market.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
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
            color: AppColors.chartLine,
            backgroundColor: AppColors.card,
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
        _shareChart(m),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Horizontal market-share bars in the style of the reference diagram:
  /// coin label left, proportional bar with % on it, percentage axis below.
  /// Colors stay in the app's dark theme.
  Widget _shareChart(MarketOverview m) {
    final total = m.totalMcap ?? 0;
    final shares = [
      for (final c in m.top)
        (coin: c, pct: total > 0 && (c.marketCap ?? 0) > 0 ? c.marketCap! / total * 100 : 0.0),
    ];
    if (shares.isEmpty) {
      return const EmptyView(message: 'No coins to chart yet.');
    }
    final maxPct = shares.map((s) => s.pct).reduce((a, b) => a > b ? a : b);
    final axisMax = (maxPct <= 0 ? 10 : ((maxPct / 10).ceil() * 10)).toDouble();
    final ticks = [for (var v = 0; v <= axisMax; v += (axisMax / 5).round()) v];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            children: [
              ...shares.map((s) => _shareRow(s.coin.name, s.coin.symbol, s.pct, axisMax)),
              const SizedBox(height: 8),
              _axis(ticks, axisMax),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shareRow(String name, String symbol, double pct, double axisMax) {
    final frac = axisMax <= 0 ? 0.0 : (pct / axisMax).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
                Text(symbol, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (_, box) => Stack(
                children: [
                  Container(
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.cardPressed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 26,
                    width: (box.maxWidth * frac).clamp(28.0, box.maxWidth),
                    decoration: BoxDecoration(
                      color: AppColors.gain,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 6),
                    child: Text('${pct.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _axis(List<int> ticks, double axisMax) {
    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 4),
        Row(
          children: [
            const SizedBox(width: 126),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final t in ticks)
                    Text('$t%', style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool last = false}) => Column(        children: [
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
