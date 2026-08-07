import 'api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getProfile() async {
    return await _api.get('/api/users/profile');
  }

  Future<Map<String, dynamic>> updateProfile({String? name, String? phone}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    return await _api.put('/api/users/profile', body);
  }

  Future<Map<String, dynamic>> updateContacts(List<Map<String, dynamic>> contacts) async {
    return await _api.put('/api/users/contacts', {'emergencyContacts': contacts});
  }
}
