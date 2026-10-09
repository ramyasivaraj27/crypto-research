import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
///
/// The callback is deferred to a post-frame callback and the Android stretch
/// overscroll effect is disabled: firing a rebuild synchronously from a
/// scroll notification dispatched during layout trips Flutter's
/// "Build scheduled during frame" assertion in debug builds.
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
    // depth == 0: ignore nested scrollers (e.g. the trending strip).
    if (n.depth == 0 &&
        n is ScrollEndNotification &&
        n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
      SchedulerBinding.instance.addPostFrameCallback((_) => onLoadMore());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _NoStretchBehavior(),
      child: NotificationListener<ScrollNotification>(
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
      ),
    );
  }
}

/// Same as Material scroll behavior but without the stretch overscroll
/// effect (keeps the platform glow). The stretch controller's animation
/// calls setState during layout when content dimensions change mid-frame
/// (e.g. rows appended by infinite scroll), which asserts in debug builds.
class _NoStretchBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    switch (details.direction) {
      case AxisDirection.down:
      case AxisDirection.up:
        return GlowingOverscrollIndicator(
          axisDirection: details.direction,
          color: Theme.of(context).colorScheme.secondary,
          child: child,
        );
      case AxisDirection.left:
      case AxisDirection.right:
        return child;
    }
  }
}
