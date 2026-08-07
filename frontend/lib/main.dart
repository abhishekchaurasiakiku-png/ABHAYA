import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const AbhayaApp());
}

class AbhayaApp extends StatelessWidget {
  const AbhayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A.B.H.A.Y.A',
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
