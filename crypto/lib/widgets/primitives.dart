import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Small solid pill for 24h change, e.g. [+2.50%].
class ChangePill extends StatelessWidget {
  final double? change;
  const ChangePill({super.key, required this.change});

  @override
  Widget build(BuildContext context) {
    final up = (change ?? 0) >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: up ? AppColors.gain : AppColors.loss,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        fmtPct(change),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

/// Rank number badge, e.g. [1] next to the symbol.
class RankBadge extends StatelessWidget {
  final int rank;
  const RankBadge({super.key, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: AppColors.rankBadge, borderRadius: BorderRadius.circular(7)),
      child: Text('$rank',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

/// Section heading, e.g. "Trending Coins".
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// Dark card of label/value rows with dividers, e.g. Market Data.
/// Takes preformatted (label, value) pairs.
class StatCard extends StatelessWidget {
  final List<(String, String)> rows;
  const StatCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rows[i].$1,
                          style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                      Text(rows[i].$2,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
                if (i < rows.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Coin icon with orange fallback. Single shared avatar widget.
class CoinAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  const CoinAvatar({super.key, required this.imageUrl, this.size = 44});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(imageUrl, width: size, height: size,
            errorBuilder: (_, __, ___) => _fallback()),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: Color(0xFFF7931A), shape: BoxShape.circle),
        child: Icon(Icons.currency_bitcoin, color: Colors.white, size: size * 0.64),
      );
}

/// Pull-to-refresh pre-styled with theme colors.
class AppRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  const AppRefreshIndicator({super.key, required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.chartLine,
      backgroundColor: AppColors.card,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

/// Offline banner that renders nothing when online.
/// Pass [savedAt] when known; otherwise [fallbackLabel] is shown.
class MaybeOfflineBadge extends StatelessWidget {
  final bool offline;
  final DateTime? savedAt;
  final String fallbackLabel;
  const MaybeOfflineBadge({super.key, required this.offline, this.savedAt, this.fallbackLabel = 'last sync'});

  @override
  Widget build(BuildContext context) {
    if (!offline) return const SizedBox.shrink();
    return _OfflineBadge(savedAgo: savedAt == null ? fallbackLabel : fmtAgo(savedAt));
  }
}

class _OfflineBadge extends StatelessWidget {
  final String savedAgo;
  const _OfflineBadge({required this.savedAgo});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF4A3F1E),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text('Offline • saved $savedAgo',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Color(0xFFFFD54F))),
    );
  }
}

/// Dark text field with icon, shared by login/search forms.
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
