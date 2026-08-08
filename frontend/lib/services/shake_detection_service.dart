import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'sos_service.dart';
import 'location_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Configurable thresholds for background detection (optimized for speed)
  double shakeThresholdGravity = 2.0; // Lowered to trigger faster with normal shakes
  int minimumShakes = 3;
  Duration timeWindow = const Duration(seconds: 2);

  final SosService sosService = SosService();
  final LocationService locationService = LocationService();
  
  List<DateTime> shakeTimestamps = [];
  bool isProcessingSos = false;

  accelerometerEventStream().listen((AccelerometerEvent event) async {
    if (isProcessingSos) return;

    double gX = event.x / 9.80665;
    double gY = event.y / 9.80665;
    double gZ = event.z / 9.80665;
    double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

    if (gForce > shakeThresholdGravity) {
      final now = DateTime.now();
      shakeTimestamps.removeWhere((timestamp) => now.difference(timestamp) > timeWindow);
      
      if (shakeTimestamps.isNotEmpty && now.difference(shakeTimestamps.last) < const Duration(milliseconds: 200)) {
        return;
      }
      
      shakeTimestamps.add(now);
      
      if (shakeTimestamps.length >= minimumShakes) {
        shakeTimestamps.clear();
        isProcessingSos = true;
        
        // Let the UI know it was triggered
        service.invoke('sos_triggered');

        try {
          // Add a strict timeout to location fetch so SOS isn't delayed if GPS is slow indoors
          final position = await locationService.getCurrentLocation().timeout(
            const Duration(seconds: 2), 
            onTimeout: () => null,
          );
          double lat = position?.latitude ?? 0.0;
          double lng = position?.longitude ?? 0.0;
          
          await sosService.triggerSos(
            triggerType: 'Motion (Background)',
            latitude: lat,
            longitude: lng,
          );
          
          await sosService.openNativeSms(lat, lng, isSos: true);
        } catch (e) {
          debugPrint("Failed to send SOS in background: $e");
          isProcessingSos = false;
        }
      }
    }
  });
}

class ShakeDetectionService {
  static final ShakeDetectionService _instance = ShakeDetectionService._internal();
  factory ShakeDetectionService() => _instance;
  ShakeDetectionService._internal();

  Future<void> initializeBackgroundService(GlobalKey<NavigatorState> navigatorKey) async {
    final service = FlutterBackgroundService();
    
    // Notifications required for Android Foreground Service
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'abhaya_safety_channel',
      'ABHAYA Safety Service',
      description: 'Constantly monitoring for emergency gestures',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    // Handle permissions on Android 13+
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'abhaya_safety_channel',
        initialNotificationTitle: 'ABHAYA Safety Guard Active',
        initialNotificationContent: 'Monitoring for SOS gestures',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: (ServiceInstance service) {
          return true; // iOS background handler
        },
      ),
    );

    service.startService();

    // Listen to background isolate trigger to update UI
    service.on('sos_triggered').listen((event) {
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushNamed('/sos_activated');
      }
    });
  }
}
