import 'package:flutter/material.dart';

/// Dark CoinGecko-style theme from the reference design.
class AppColors {
  static const background = Color(0xFF121214);
  static const card = Color(0xFF2A2A2E);
  static const cardPressed = Color(0xFF333338);
  static const rankBadge = Color(0xFF1C1C1F);
  static const gain = Color(0xFF5DBB63);
  static const loss = Color(0xFFE05252);
  static const chartLine = Color(0xFF7DFF7A);
  static const muted = Color(0xFF9E9EA3);
  static const selectedPill = Color(0xFF3A3A3F);
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.selectedPill,
      shape: const StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      prefixIconColor: AppColors.muted,
      hintStyle: const TextStyle(color: AppColors.muted),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF3A3A3F), thickness: 1),
    textTheme: base.textTheme.apply(
      displayColor: Colors.white,
      bodyColor: Colors.white,
    ),
  );
}

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
        _text(change),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  String _text(double? v) {
    if (v == null) return '—';
    final sign = v >= 0 ? '+' : '';
    return '$sign${v.toStringAsFixed(2)}%';
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
      child: Text('$rank', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
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
