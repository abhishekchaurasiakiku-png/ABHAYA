import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';
import '../screens/contacts_screen.dart';
import '../screens/sos_activated_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      '/': (context) => const SplashScreen(),
      '/login': (context) => const LoginScreen(),
      '/main': (context) => const MainShell(),
      '/contacts': (context) => const ContactsScreen(),
      '/sos_activated': (context) => const SosActivatedScreen(),
    };
  }
}
