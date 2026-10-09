import 'package:flutter/material.dart';

import '../mixins/state_mixin.dart';
import '../provider/provider_utils.dart';

/// Shared market actions for tiles and screens
/// scoped to starring + list refresh. Requires [StateMixin].
mixin MarketActionsMixin<T extends StatefulWidget> on State<T>, StateMixin<T> {
  Future<void> toggleStar(int coinId) async {
    setLoading(true, 'star-$coinId');
    try {
      await context.watchlistViewModel.toggle(coinId);
    } catch (e) {
      handleError(e);
    } finally {
      setLoading(false, 'star-$coinId');
    }
  }

  bool isStarLoading(int coinId) => isLoading('star-$coinId');
}
