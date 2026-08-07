import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'sos_service.dart';

class TripMonitorService {
  StreamSubscription<Position>? _positionStream;
  List<LatLng> _expectedRoute = [];
  bool _isMonitoring = false;
  
  int _strikeCount = 0;
  Timer? _escalationTimer;
  bool _isPrompting = false;

  final double deviationThresholdMeters = 200.0;
  final Duration popupInterval = const Duration(minutes: 2);
  final int maxStrikes = 5;

  // Callbacks for UI
  Function()? onDeviationDetected;
  Function(int)? onStrikeUpdated;
  Function()? onSosTriggered;

  void startMonitoring(List<LatLng> route) {
    _expectedRoute = route;
    _isMonitoring = true;
    _strikeCount = 0;
    _isPrompting = false;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (!_isMonitoring || _isPrompting) return;
      _checkDeviation(LatLng(position.latitude, position.longitude));
    });
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _positionStream?.cancel();
    _escalationTimer?.cancel();
  }

  void _checkDeviation(LatLng currentLoc) {
    if (_expectedRoute.isEmpty) return;

    double minDistance = double.infinity;
    final distance = const Distance();

    for (var point in _expectedRoute) {
      double dist = distance.as(LengthUnit.Meter, currentLoc, point);
      if (dist < minDistance) {
        minDistance = dist;
      }
    }

    if (minDistance > deviationThresholdMeters) {
      _triggerEscalation();
    }
  }

  void _triggerEscalation() {
    _isPrompting = true;
    _strikeCount++;
    if (onStrikeUpdated != null) onStrikeUpdated!(_strikeCount);
    
    if (_strikeCount > maxStrikes) {
      _triggerSos();
      return;
    }

    if (onDeviationDetected != null) onDeviationDetected!();

    _escalationTimer = Timer(popupInterval, () {
      if (_isPrompting) {
        _triggerEscalation(); // Strike again
      }
    });
  }

  void markAsSafe() {
    _isPrompting = false;
    _strikeCount = 0;
    _escalationTimer?.cancel();
  }

  void _triggerSos() async {
    stopMonitoring();
    if (onSosTriggered != null) onSosTriggered!();
    
    try {
      final pos = await Geolocator.getCurrentPosition();
      await SosService().triggerSos(
        triggerType: 'Route Deviation',
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
    } catch (e) {
      // Auto SOS failed
    }
  }
}
