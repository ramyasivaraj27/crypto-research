import '../core/view_model/view_model.dart';
import '../model/app_state.dart';
import '../provider/app_state_notifier.dart';

/// Global UI state: bottom-tab index (mirrors balm's AppViewModel/AppState).
class AppViewModel extends AppStateNotifier<AppState> implements AppBaseViewModel {
  AppViewModel() : super(AppState());

  @override
  Future<void> init() async {}

  Future<void> bottomNavIndex({required int index}) async {
    state = state.rebuild((b) => b..activeIndex = index);
  }
}
