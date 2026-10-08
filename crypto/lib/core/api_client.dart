import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Single HTTP layer. Base URL from --dart-define=API_BASE_URL (default localhost).
/// Throws [ApiException] with user-friendly messages for error states.
class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

class ApiClient {
  static const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
  String? token;
  final http.Client _http = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      };

  Future<dynamic> _get(Uri uri) async {
    http.Response res;
    try {
      res = await _http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException('Request timed out. Check your connection and retry.');
    } catch (_) {
      throw ApiException("Can't reach server. Start the backend and retry.");
    }
    return _decode(res);
  }

  Future<dynamic> _post(Uri uri, Object body) async {
    http.Response res;
    try {
      res = await _http.post(uri, headers: _headers, body: jsonEncode(body)).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException('Request timed out. Check your connection and retry.');
    } catch (_) {
      throw ApiException("Can't reach server. Start the backend and retry.");
    }
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode == 401) throw ApiException('Session expired. Please log in again.', 401);
    if (res.statusCode == 429) throw ApiException('Server is busy (rate limited). Showing saved data.', 429);
    if (res.statusCode >= 500) throw ApiException('Server error. Showing saved data if available.');
    if (res.statusCode >= 400) {
      String detail = 'Request failed (${res.statusCode}).';
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['detail'] != null) detail = body['detail'].toString();
      } catch (_) {}
      throw ApiException(detail, res.statusCode);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> coins({String search = '', String ordering = '-market_cap_usd', int page = 1}) async {
    final uri = Uri.parse('$baseUrl/api/research/coins/').replace(queryParameters: {
      if (search.isNotEmpty) 'search': search,
      'ordering': ordering,
      'page': '$page',
    });
    final data = await _get(uri);
    return (data['results'] as List).cast<dynamic>();
  }

  Future<Map<String, dynamic>> coinDetail(int id) async {
    final data = await _get(Uri.parse('$baseUrl/api/research/coins/$id/'));
    return (data as Map).cast<String, dynamic>();
  }

  Future<List<dynamic>> history(int id, {int days = 7}) async {
    final uri = Uri.parse('$baseUrl/api/research/coins/$id/history/').replace(queryParameters: {'days': '$days'});
    final data = await _get(uri);
    return (data['points'] as List).cast<dynamic>();
  }

  Future<Map<String, dynamic>> market() async {
    final data = await _get(Uri.parse('$baseUrl/api/research/market/'));
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final data = await _post(Uri.parse('$baseUrl/api/users/register/'),
        {'username': username, 'email': email, 'password': password});
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final data = await _post(Uri.parse('$baseUrl/api/users/login/'), {'username': username, 'password': password});
    return (data as Map).cast<String, dynamic>();
  }

  Future<void> logout() async {
    try {
      await _post(Uri.parse('$baseUrl/api/users/logout/'), {});
    } catch (_) {}
  }

  Future<List<dynamic>> watchlistItems() async {
    final data = await _get(Uri.parse('$baseUrl/api/research/watchlist-items/'));
    return (data['results'] as List).cast<dynamic>();
  }

  Future<Map<String, dynamic>> toggleStar(int coinId) async {
    final data = await _post(Uri.parse('$baseUrl/api/research/watchlists/toggle/'), {'coin': coinId});
    return (data as Map).cast<String, dynamic>();
  }
}
