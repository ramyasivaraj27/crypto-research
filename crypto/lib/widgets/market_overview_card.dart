import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../model/market_overview.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../views/market_stats_screen.dart';

/// Compact global-stats card on the home tab; taps through to full stats.
class MarketOverviewCard extends StatefulWidget {
  const MarketOverviewCard({super.key});
  @override
  State<MarketOverviewCard> createState() => _MarketOverviewCardState();
}

class _MarketOverviewCardState extends State<MarketOverviewCard> {
  MarketOverview? data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<ApiClient>();
    final cache = context.read<CacheStore>();
    try {
      final raw = await api.market();
      if (!mounted) return;
      setState(() => data = MarketOverview.fromJson(raw));
      await cache.save('market', raw);
    } catch (_) {
      try {
        final hit = await cache.load('market');
        if (hit.data != null && mounted) {
          setState(() => data = MarketOverview.fromJson((hit.data as Map).cast<String, dynamic>()));
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = data;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const MarketStatsScreen(showBack: true))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: m == null
                ? const Text('Market overview', style: TextStyle(color: AppColors.muted))
                : Row(
                    children: [
                      Expanded(child: _cell('Market Cap', fmtCompact(m.totalMcap))),
                      Expanded(child: _cell('24h Vol', fmtCompact(m.totalVolume))),
                      Expanded(
                          child: _cell('BTC Dom',
                              m.btcDom == null ? '—' : '${m.btcDom!.toStringAsFixed(1)}%')),
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _cell(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      );
}
