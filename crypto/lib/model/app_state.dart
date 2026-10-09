import 'package:built_value/built_value.dart';

part 'app_state.g.dart';

/// Global UI state ( scoped to tab index).
abstract class AppState implements Built<AppState, AppStateBuilder> {
  int get activeIndex;

  AppState._();
  factory AppState([void Function(AppStateBuilder)? updates]) = _$AppState;

  static void _initializeBuilder(AppStateBuilder b) {
    b.activeIndex = 0;
  }
}
