import 'package:state_notifier/state_notifier.dart';

/// Thin generic StateNotifier base (mirrors balm's AppStateNotifier).
abstract class AppStateNotifier<T> extends StateNotifier<T> {
  AppStateNotifier(super.state);

  T getState() => state;
}
