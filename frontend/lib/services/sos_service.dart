import 'package:url_launcher/url_launcher.dart';
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

  Future<Map<String, dynamic>> updateSosLocation(String id, double latitude, double longitude) async {
    return await _api.put('/api/sos/$id/location', {
      'coordinates': [longitude, latitude],
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

  Future<Map<String, dynamic>> shareLiveLocation(double latitude, double longitude) async {
    return await _api.post('/api/sos/share-location', {
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      }
    });
  }

  Future<void> openNativeSms(double latitude, double longitude, {bool isSos = false}) async {
    final mapsUrl = 'https://maps.google.com/?q=$latitude,$longitude';
    final message = isSos 
      ? '🚨 SOS ALERT! I need immediate help. My live location: $mapsUrl'
      : '📍 Here is my live location: $mapsUrl';
      
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '',
      queryParameters: <String, String>{
        'body': message,
      },
    );
    
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }
}
