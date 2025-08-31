// lib/services/recs_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Tiny helper to call your FastAPI "instant recs" endpoint.
/// - Change [baseUrl] to your server URL.
/// - Call RecsApi.refreshUserInstant(uid) after favorite/purchase/review actions.
class RecsApi {
  /// ⚠️ Change this to your FastAPI host.
  /// For Android emulator use http://10.0.2.2:8000
  /// For iOS simulator or web use http://127.0.0.1:8000 (if server runs locally)
  static const String baseUrl = "http://127.0.0.1:8000";

  /// Optional: add a shared secret header if you secure the API.
  static const Map<String, String> _baseHeaders = {
    "Content-Type": "application/json",
    // "x-api-key": "<YOUR_SECRET_IF_ANY>",
  };

  /// Ask the backend to recompute recommendations for this user NOW.
  /// If the server writes to Firestore (write=true), your app can just
  /// rely on the Recommendations/{uid} stream to update the UI.
  static Future<Map<String, dynamic>> refreshUserInstant(String uid,
      {bool write = true, Duration timeout = const Duration(seconds: 8)}) async {
    final uri = Uri.parse("$baseUrl/recs/instant/$uid?write=$write");

    final res = await http.post(uri, headers: _baseHeaders).timeout(timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Instant recs failed: ${res.statusCode} ${res.body}");
    }

    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      // Backend returns JSON, but if it doesn't, return an empty map
      return {};
    }
  }
}
