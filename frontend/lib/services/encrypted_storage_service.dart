import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptedStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _incidentsKey = 'encrypted_incidents_log';

  Future<void> saveIncidents(List<dynamic> incidents) async {
    final String jsonString = jsonEncode(incidents);
    await _storage.write(key: _incidentsKey, value: jsonString);
  }

  Future<List<dynamic>> loadIncidents() async {
    final String? jsonString = await _storage.read(key: _incidentsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return jsonDecode(jsonString) as List<dynamic>;
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
