import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../core/theme.dart';
import '../services/location_service.dart';
import '../services/map_service.dart';
import '../services/trip_monitor_service.dart';

class TripMonitorScreen extends StatefulWidget {
  const TripMonitorScreen({super.key});

  @override
  State<TripMonitorScreen> createState() => _TripMonitorScreenState();
}

class _TripMonitorScreenState extends State<TripMonitorScreen> {
  final LocationService _locationService = LocationService();
  final MapService _mapService = MapService();
  final TripMonitorService _tripService = TripMonitorService();
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  bool _isMonitoring = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
    
    _tripService.onDeviationDetected = _showDeviationAlert;
    _tripService.onStrikeUpdated = (strike) {
      if (mounted) setState(() {});
    };
    _tripService.onSosTriggered = () {
      if (mounted) {
        Navigator.pop(context); // Close alert
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auto-SOS Triggered due to route deviation!', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.sosPink),
        );
      }
    };
  }

  @override
  void dispose() {
    _tripService.stopMonitoring();
    WakelockPlus.disable();
    super.dispose();
  }

  void _loadInitialLocation() async {
    final pos = await _locationService.getCurrentLocation();
    if (pos != null && mounted) {
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onMapLongPress(TapPosition tapPosition, LatLng point) async {
    if (_isMonitoring) return;
    
    setState(() {
      _destination = point;
      _isLoading = true;
    });

    if (_currentLocation != null) {
      final route = await _mapService.getRoute(_currentLocation!, _destination!);
      if (mounted) {
        setState(() {
          _routePoints = route;
          _isLoading = false;
        });
      }
    }
  }

  void _toggleTrip() {
    if (_isMonitoring) {
      _tripService.stopMonitoring();
      WakelockPlus.disable();
      setState(() {
        _isMonitoring = false;
        _destination = null;
        _routePoints = [];
      });
    } else {
      if (_routePoints.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a destination by long-pressing on the map.')));
        return;
      }
      _tripService.startMonitoring(_routePoints);
      WakelockPlus.enable();
      setState(() {
        _isMonitoring = true;
      });
    }
  }

  void _showDeviationAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.amber, size: 28),
              const SizedBox(width: 10),
              Text('Route Deviation', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'We noticed you deviated from your expected route. Are you safe?\n\nIf you do not respond, an SOS will be triggered automatically.',
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _tripService.markAsSafe();
                Navigator.pop(context);
              },
              child: Text('Yes, I am Safe', style: GoogleFonts.poppins(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Optionally manually trigger SOS here
              },
              child: Text('No, Help!', style: GoogleFonts.poppins(color: AppColors.sosPink, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Safe Commute', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading && _currentLocation == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.neonCyan))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation ?? const LatLng(0, 0),
                    initialZoom: 15,
                    onLongPress: _onMapLongPress,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.abhaya.app',
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 4.0,
                            color: AppColors.neonPurple,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (_currentLocation != null)
                          Marker(
                            point: _currentLocation!,
                            width: 20,
                            height: 20,
                            child: const Icon(Icons.my_location, color: AppColors.neonCyan),
                          ),
                        if (_destination != null)
                          Marker(
                            point: _destination!,
                            width: 30,
                            height: 30,
                            child: const Icon(Icons.location_on, color: AppColors.sosPink, size: 30),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isMonitoring ? AppColors.sosPink : AppColors.neonGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _toggleTrip,
                    child: Text(
                      _isMonitoring ? 'Stop Monitoring Trip' : 'Start Safe Commute',
                      style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (_isMonitoring)
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neonPurple),
                      ),
                      child: Text(
                        'AI Route Monitor Active. We are watching your back.',
                        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
