import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme.dart';
import 'routes/app_routes.dart';
import 'services/shake_detection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const AbhayaApp());
}

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

class AbhayaApp extends StatefulWidget {
  const AbhayaApp({super.key});

  @override
  State<AbhayaApp> createState() => _AbhayaAppState();
}

class _AbhayaAppState extends State<AbhayaApp> {
  late ShakeDetectionService _shakeService;

  @override
  void initState() {
    super.initState();
    _shakeService = ShakeDetectionService(navigatorKey: globalNavigatorKey);
    _shakeService.startListening();
  }

  @override
  void dispose() {
    _shakeService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      title: 'A.B.H.A.Y.A',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
