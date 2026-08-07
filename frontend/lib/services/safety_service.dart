import 'api_service.dart';

class SafetyService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getNearbyZones(double lat, double lng, {int radius = 2000}) async {
    return await _api.get('/api/safety/zones?lat=$lat&lng=$lng&radius=$radius');
  }

  Future<Map<String, dynamic>> getSafeRoute(double fromLat, double fromLng, double toLat, double toLng) async {
    return await _api.get('/api/safety/route?fromLat=$fromLat&fromLng=$fromLng&toLat=$toLat&toLng=$toLng');
  }

  Future<Map<String, dynamic>> reportIncident(double lat, double lng, String type, String description) async {
    return await _api.post('/api/safety/report', {
      'location': {
        'type': 'Point',
        'coordinates': [lng, lat],
      },
      'type': type,
      'description': description,
    });
  }
}
