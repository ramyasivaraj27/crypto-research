import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/market.dart';
import '../providers/watchlist_provider.dart';
import '../screens/coin_detail_screen.dart';
import '../utils/format.dart';

class CoinTile extends StatelessWidget {
  final Coin coin;
  const CoinTile({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final up = (coin.change24h ?? 0) >= 0;
    final starred = context.select<WatchlistProvider, bool>((w) => w.starredIds.contains(coin.id));
    return ListTile(
      leading: coin.imageUrl.isNotEmpty
          ? Image.network(coin.imageUrl, width: 36, height: 36, errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin))
          : const CircleAvatar(child: Text('₿')),
      title: Text('${coin.name} (${coin.symbol})', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('MCap ${fmtCompact(coin.marketCap)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmtPrice(coin.price), style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(fmtPct(coin.change24h), style: TextStyle(color: up ? Colors.green : Colors.red)),
            ],
          ),
          IconButton(
            icon: Icon(starred ? Icons.star : Icons.star_border, color: starred ? Colors.amber : null),
            onPressed: () => context.read<WatchlistProvider>().toggle(coin.id),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CoinDetailScreen(coin: coin))),
    );
  }
}
