import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class JwtTokenManager {
  JwtTokenManager(this._prefs);

  final SharedPreferences _prefs;
  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    final payload = _decodePayload(token);
    final expiresAt = payload['exp'] as int?;
    await _prefs.setString(_tokenKey, token);
    if (expiresAt != null) {
      await _prefs.setInt('${_tokenKey}_exp', expiresAt);
    }
  }

  Future<String?> getToken() async {
    final token = _prefs.getString(_tokenKey);
    final expiresAt = _prefs.getInt('${_tokenKey}_exp');
    if (token == null) {
      return null;
    }
    if (expiresAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (now > expiresAt) {
        await clear();
        return null;
      }
    }
    return token;
  }

  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove('${_tokenKey}_exp');
  }

  Map<String, dynamic> _decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return <String, dynamic>{};
    }
    final normalized = base64.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(payload) as Map<String, dynamic>;
  }
}
