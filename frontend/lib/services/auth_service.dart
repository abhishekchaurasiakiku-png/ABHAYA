import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> register(String name, String email, String password, {String phone = ''}) async {
    final result = await _api.post('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
    });
    await _api.setToken(result['token']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', result['refreshToken'] ?? '');
    await prefs.setString('user_name', result['user']?['name'] ?? name);
    await prefs.setString('user_email', result['user']?['email'] ?? email);
    await prefs.setString('user_phone', result['user']?['phone'] ?? phone);
    return result;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _api.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    await _api.setToken(result['token']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', result['refreshToken'] ?? '');
    await prefs.setString('user_name', result['user']?['name'] ?? '');
    await prefs.setString('user_email', result['user']?['email'] ?? email);
    await prefs.setString('user_phone', result['user']?['phone'] ?? '');
    return result;
  }

  Future<bool> isLoggedIn() async {
    final token = await _api.token;
    return token != null && token.isNotEmpty;
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'User';
  }

  Future<void> logout() async {
    await _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
  }
}
