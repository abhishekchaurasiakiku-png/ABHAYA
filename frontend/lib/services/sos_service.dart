import 'api_service.dart';

class SosService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> triggerSos({
    required String triggerType,
    required double latitude,
    required double longitude,
    int? batteryLevel,
  }) async {
    return await _api.post('/api/sos/trigger', {
      'triggerType': triggerType,
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> resolveSos(String id, {String? notes}) async {
    return await _api.put('/api/sos/$id/resolve', {
      'status': 'Resolved',
      'resolvedAt': DateTime.now().toIso8601String(),
      if (notes != null) 'notes': notes,
    });
  }

  Future<Map<String, dynamic>> getActiveSos() async {
    return await _api.get('/api/sos/active');
  }
}
