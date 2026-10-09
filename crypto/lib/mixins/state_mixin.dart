import 'package:flutter/material.dart';

/// Per-action loading flags + snack/error helpers for screens.
/// Mirrors balm's `StateMixin` (views/widgets/mixins.dart).
mixin StateMixin<T extends StatefulWidget> on State<T> {
  final Map<String, bool> _loading = {};

  bool isLoading([String key = 'default']) => _loading[key] ?? false;

  void setLoading(bool value, [String key = 'default']) {
    if (!mounted) return;
    setState(() => _loading[key] = value);
  }

  void resetLoading() {
    if (!mounted) return;
    setState(_loading.clear);
  }

  void showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shared error path: surfaces the message; returns false so callers can
  /// branch to cache-fallback logic.
  bool handleError(Object e) {
    final message = e.toString().replaceFirst('Exception: ', '');
    showSnack(message);
    return false;
  }
}
