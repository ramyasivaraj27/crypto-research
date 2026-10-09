import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Bottom-of-list footer for infinite scroll.
/// Hidden when there is nothing left to load.
class LoadMoreFooter extends StatelessWidget {
  final bool hasNext;
  final bool loadingMore;
  final String pageError;
  final VoidCallback onRetry;
  const LoadMoreFooter({
    super.key,
    required this.hasNext,
    required this.loadingMore,
    required this.pageError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasNext && pageError.isEmpty) return const SizedBox(height: 16);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: loadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : pageError.isNotEmpty
                ? TextButton(
                    onPressed: onRetry,
                    child: const Text("Couldn't load more - tap to retry",
                        style: TextStyle(color: AppColors.muted)),
                  )
                : const SizedBox(height: 16),
      ),
    );
  }
}

/// ListView that fires [onLoadMore] when scrolled near the bottom.
/// Callers guard duplicates via their own `loadingMore` flag.
class PagedListView extends StatelessWidget {
  final Future<void> Function() onLoadMore;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final List<Widget> prefix;
  final List<Widget> suffix;
  const PagedListView({
    super.key,
    required this.onLoadMore,
    required this.itemCount,
    required this.itemBuilder,
    this.prefix = const [],
    this.suffix = const [],
  });

  bool _onEdge(ScrollNotification n) {
    if (n is ScrollEndNotification &&
        n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
      onLoadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onEdge,
      child: ListView.builder(
        itemCount: prefix.length + itemCount + suffix.length,
        itemBuilder: (ctx, i) {
          if (i < prefix.length) return prefix[i];
          final j = i - prefix.length;
          if (j < itemCount) return itemBuilder(ctx, j);
          return suffix[j - itemCount];
        },
      ),
    );
  }
}
