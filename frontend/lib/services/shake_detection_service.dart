import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';
import 'sos_service.dart';
import 'location_service.dart';

class ShakeDetectionService {
  // Configurable thresholds
  double shakeThresholdGravity = 2.7; // Magnitude of acceleration in Gs to count as a shake
  int minimumShakes = 3; // Number of shakes required
  Duration timeWindow = const Duration(seconds: 2); // Time window to achieve minimum shakes

  final SosService _sosService = SosService();
  final LocationService _locationService = LocationService();
  
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  List<DateTime> _shakeTimestamps = [];
  bool _isProcessingSos = false;
  
  // A global navigator key must be provided to navigate to the SOS screen
  final GlobalKey<NavigatorState> navigatorKey;

  ShakeDetectionService({required this.navigatorKey});

  void startListening() {
    if (_accelerometerSubscription != null) return;
    
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (_isProcessingSos) return;
      
      // Calculate magnitude in Gs (Standard gravity is ~9.8 m/s^2)
      double gX = event.x / 9.80665;
      double gY = event.y / 9.80665;
      double gZ = event.z / 9.80665;
      
      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);
      
      if (gForce > shakeThresholdGravity) {
        _onShakeDetected();
      }
    });
    
    debugPrint("Shake detection started.");
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _shakeTimestamps.clear();
    debugPrint("Shake detection stopped.");
  }

  void _onShakeDetected() {
    final now = DateTime.now();
    
    // Remove old timestamps outside the window
    _shakeTimestamps.removeWhere((timestamp) => 
      now.difference(timestamp) > timeWindow
    );
    
    // To prevent a single long motion from being counted as many shakes rapidly,
    // ensure at least 200ms between counted shakes
    if (_shakeTimestamps.isNotEmpty) {
      if (now.difference(_shakeTimestamps.last) < const Duration(milliseconds: 200)) {
        return;
      }
    }
    
    _shakeTimestamps.add(now);
    
    if (_shakeTimestamps.length >= minimumShakes) {
      _shakeTimestamps.clear();
      _triggerSos();
    }
  }

  Future<void> _triggerSos() async {
    _isProcessingSos = true;
    debugPrint("SHAKE PATTERN DETECTED! TRIGGERING SOS...");
    
    // Navigate immediately to SOS ACTIVATED screen so user sees feedback
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed('/sos_activated');
    }

    double lat = 0.0;
    double lng = 0.0;
    
    try {
      final position = await _locationService.getCurrentLocation();
      lat = position?.latitude ?? 0.0;
      lng = position?.longitude ?? 0.0;
    } catch (e) {
      debugPrint("Failed to get location for shake SOS");
    }

    try {
      await _sosService.triggerSos(
        triggerType: 'Motion',
        latitude: lat,
        longitude: lng,
      );
      
      // Open SMS as a fallback
      await _sosService.openNativeSms(lat, lng, isSos: true);
      
      // We do NOT reset _isProcessingSos here, so it doesn't re-trigger infinitely 
      // while they are in the emergency state. They must restart the app or reset it.
    } catch (e) {
      debugPrint("Failed to send SOS: $e");
      // Allow them to try shaking again if it failed
      _isProcessingSos = false;
    }
  }
}
