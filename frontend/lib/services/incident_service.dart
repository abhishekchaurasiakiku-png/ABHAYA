import 'api_service.dart';

class IncidentService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getIncidents({int page = 1, int limit = 20}) async {
    return await _api.get('/api/incidents?page=$page&limit=$limit');
  }

  Future<Map<String, dynamic>> getIncidentDetail(String id) async {
    return await _api.get('/api/incidents/$id');
  }
}
