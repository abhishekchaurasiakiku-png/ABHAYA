import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = 'A.B.H.A.Y.A';
  static const String sosMessage = 'I am in danger! Please help.';

  // Backend API
  // Reads RENDER_API_URL from frontend/.env file. If not found, defaults to Render URL.
  static String get baseUrl => dotenv.env['RENDER_API_URL'] ?? 'https://safeher-ai-backend.onrender.com';

  // Helplines
  static const String womenHelpline = '1091';
  static const String abuseHelpline = '181';
  static const String policeEmergency = '112';
  static const String ambulance = '108';

  // Safety Tips
  static const List<Map<String, String>> safetyTips = [
    {
      'title': 'Trust Your Intuition',
      'body': 'When travelling alone at night, share your live GPS coordinates with guardians and keep your hand near the SOS trigger.',
    },
    {
      'title': 'Stay Connected',
      'body': 'Always keep your phone charged and inform a trusted contact about your travel plans and expected arrival time.',
    },
    {
      'title': 'Know Your Exits',
      'body': 'In any new place, identify at least two exit routes. Awareness of your surroundings is your first line of defense.',
    },
    {
      'title': 'Use Well-Lit Routes',
      'body': 'Always prefer well-lit, populated streets when walking alone. Avoid shortcuts through isolated areas.',
    },
  ];
}
