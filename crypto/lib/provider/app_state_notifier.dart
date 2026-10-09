import 'package:state_notifier/state_notifier.dart';

/// Thin generic StateNotifier base
abstract class AppStateNotifier<T> extends StateNotifier<T> {
  AppStateNotifier(super.state);

  T getState() => state;
}
