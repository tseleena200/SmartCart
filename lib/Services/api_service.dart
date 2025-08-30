// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  const ApiService(this.baseUrl);

  Future<Map<String, dynamic>> checkHealth() async {
    final r = await http.get(Uri.parse('$baseUrl/health'));
    _ensureOk(r);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listRecs({int limit = 200}) async {
    final r = await http.get(Uri.parse('$baseUrl/admin/recs?limit=$limit'));
    _ensureOk(r);
    final list = jsonDecode(r.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getUserRec(String userId) async {
    final r = await http.get(Uri.parse('$baseUrl/admin/recs/$userId'));
    _ensureOk(r);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<void> refreshAll() async {
    final r = await http.post(Uri.parse('$baseUrl/admin/recs/refresh_all'));
    _ensureOk(r);
  }

  Future<void> refreshUser(String userId) async {
    final r = await http.post(Uri.parse('$baseUrl/admin/recs/refresh_user/$userId'));
    _ensureOk(r);
  }

  Future<void> deleteUser(String userId) async {
    final r = await http.delete(Uri.parse('$baseUrl/admin/recs/$userId'));
    _ensureOk(r);
  }

  void _ensureOk(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }
}
