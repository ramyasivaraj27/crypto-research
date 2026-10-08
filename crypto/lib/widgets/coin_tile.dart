import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/market.dart';
import '../providers/watchlist_provider.dart';
import '../screens/coin_detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Rounded dark card row: icon, name, rank + symbol, price + change pill.
class CoinTile extends StatelessWidget {
  final Coin coin;
  final int rank;
  const CoinTile({super.key, required this.coin, this.rank = 0});

  @override
  Widget build(BuildContext context) {
    final starred = context.select<WatchlistProvider, bool>((w) => w.starredIds.contains(coin.id));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CoinDetailScreen(coin: coin))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _icon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coin.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (rank > 0) ...[RankBadge(rank: rank), const SizedBox(width: 6)],
                          Text(coin.symbol, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(fmtPrice(coin.price),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    ChangePill(change: coin.change24h),
                  ],
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(starred ? Icons.star : Icons.star_border,
                      color: starred ? Colors.amber : AppColors.muted),
                  onPressed: () => context.read<WatchlistProvider>().toggle(coin.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    if (coin.imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(coin.imageUrl, width: 44, height: 44,
            errorBuilder: (_, __, ___) => const _FallbackIcon()),
      );
    }
    return const _FallbackIcon();
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(color: Color(0xFFF7931A), shape: BoxShape.circle),
      child: const Icon(Icons.currency_bitcoin, color: Colors.white, size: 28),
    );
  }
}
