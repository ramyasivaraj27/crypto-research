import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../core/view_model/view_model.dart';
import '../model/auth_state.dart';
import '../provider/app_state_notifier.dart';

/// Session store: token persistence + register/login/logout.
/// Replaces the old ChangeNotifier AuthStore.
class AuthViewModel extends AppStateNotifier<AuthState> implements AppBaseViewModel {
  final ApiClient api;
  AuthViewModel(this.api) : super(AuthState());

  bool get isLoggedIn => state.isLoggedIn;

  @override
  Future<void> init() => load();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('auth_token');
    final u = prefs.getString('auth_username');
    if (t != null) {
      state = state.rebuild((b) => b
        ..token = t
        ..username = u);
      api.token = t;
    }
  }

  Future<void> _save(String? token, String? username) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove('auth_token');
      await prefs.remove('auth_username');
    } else {
      await prefs.setString('auth_token', token);
      if (username != null) await prefs.setString('auth_username', username);
    }
  }

  Future<String?> login(String username, String password) async {
    try {
      final data = await api.login(username, password);
      final token = data['token'] as String?;
      final user = (data['user'] as Map).cast<String, dynamic>();
      state = state.rebuild((b) => b
        ..token = token
        ..username = user['username']?.toString());
      api.token = token;
      await _save(token, state.username);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> register(String username, String email, String password) async {
    try {
      final data = await api.register(username, email, password);
      final token = data['token'] as String?;
      final user = (data['user'] as Map).cast<String, dynamic>();
      state = state.rebuild((b) => b
        ..token = token
        ..username = user['username']?.toString());
      api.token = token;
      await _save(token, state.username);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await api.logout();
    state = state.rebuild((b) => b
      ..token = null
      ..username = null);
    api.token = null;
    await _save(null, null);
  }
}
