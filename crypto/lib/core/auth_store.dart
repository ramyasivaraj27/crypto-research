import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

/// Remembers the auth token on-device so login survives restarts.
class AuthStore extends ChangeNotifier {
  final ApiClient api;
  String? _token;
  Map<String, dynamic>? user;
  AuthStore(this.api);

  bool get isLoggedIn => _token != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('auth_token');
    if (t != null) {
      _token = t;
      api.token = t;
      notifyListeners();
    }
  }

  Future<void> _save(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove('auth_token');
    } else {
      await prefs.setString('auth_token', token);
    }
  }

  Future<String?> login(String username, String password) async {
    try {
      final data = await api.login(username, password);
      _token = data['token'] as String?;
      user = (data['user'] as Map).cast<String, dynamic>();
      api.token = _token;
      await _save(_token);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> register(String username, String email, String password) async {
    try {
      final data = await api.register(username, email, password);
      _token = data['token'] as String?;
      user = (data['user'] as Map).cast<String, dynamic>();
      api.token = _token;
      await _save(_token);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await api.logout();
    _token = null;
    user = null;
    api.token = null;
    await _save(null);
    notifyListeners();
  }
}
