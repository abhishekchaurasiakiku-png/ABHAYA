import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../services/location_service.dart';
import '../services/safety_service.dart';
import '../services/map_service.dart';
import '../widgets/glassmorphic_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final SafetyService _safetyService = SafetyService();
  final MapService _mapService = MapService();
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(25.2425, 86.9842); // Default: IIIT Bhagalpur
  bool _isLoading = true;
  bool _isRouting = false;
  String _riskLabel = 'Low Risk (94% Safe)';
  Color _riskColor = AppColors.neonGreen;
  String _geofenceLabel = 'GEOFENCE: SAFE ZONE';
  List<LatLng> _policeStations = [];
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  void _loadLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController.move(_currentLocation, 15);
        _loadSafetyData();
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadSafetyData() async {
    try {
      final data = await _safetyService.getNearbyZones(_currentLocation.latitude, _currentLocation.longitude);
      final zones = data['zones'] as List? ?? [];
      if (zones.isNotEmpty && mounted) {
        final firstZone = zones[0];
        final risk = firstZone['riskScore'] ?? 2;
        setState(() {
          if (risk <= 3) {
            _riskLabel = 'Low Risk (${100 - risk * 6}% Safe)';
            _riskColor = AppColors.neonGreen;
            _geofenceLabel = 'GEOFENCE: SAFE ZONE';
          } else if (risk <= 6) {
            _riskLabel = 'Medium Risk (${100 - risk * 8}% Safe)';
            _riskColor = Colors.orange;
            _geofenceLabel = 'GEOFENCE: CAUTION ZONE';
          } else {
            _riskLabel = 'High Risk (${100 - risk * 9}% Safe)';
            _riskColor = AppColors.sosPink;
            _geofenceLabel = 'GEOFENCE: DANGER ZONE';
          }
        });
      }
    } catch (e) {
      // Use defaults
    }
  }

  void _findPoliceStation() async {
    setState(() => _isLoading = true);
    final stations = await _mapService.getNearbyPoliceStations(_currentLocation.latitude, _currentLocation.longitude);
    if (mounted) {
      setState(() {
        _policeStations = stations;
        _isLoading = false;
      });
      if (stations.isNotEmpty) {
        _calculateRouteTo(stations.first);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No police stations found nearby')));
      }
    }
  }

  void _calculateRouteTo(LatLng destination) async {
    setState(() => _isRouting = true);
    final route = await _mapService.getRoute(_currentLocation, destination);
    if (mounted) {
      setState(() {
        _routePoints = route;
        _isRouting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live Safety Map ✨', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Real-Time Geofence & Threat Analytics', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  GestureDetector(
                    onTap: _loadLocation,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonCyan.withValues(alpha: 0.15),
                        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.my_location, color: AppColors.neonCyan, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Map Container
              Container(
                height: 340,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentLocation,
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.abhaya.app',
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: _currentLocation,
                              radius: 100,
                              color: AppColors.neonCyan.withValues(alpha: 0.1),
                              borderColor: AppColors.neonCyan,
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                        PolylineLayer(
                          polylines: [
                            if (_routePoints.isNotEmpty)
                              Polyline(
                                points: _routePoints,
                                strokeWidth: 4.0,
                                color: AppColors.neonPurple,
                              ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation,
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.sosPink.withValues(alpha: 0.3),
                                  border: Border.all(color: AppColors.sosPink, width: 2),
                                ),
                                child: const Icon(Icons.my_location, color: AppColors.sosPink, size: 20),
                              ),
                            ),
                            ..._policeStations.map((station) => Marker(
                                  point: station,
                                  width: 40,
                                  height: 40,
                                  child: GestureDetector(
                                    onTap: () => _calculateRouteTo(station),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue.withValues(alpha: 0.8),
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.local_police, color: Colors.white, size: 20),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                    // Geofence Label
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.cardDark.withValues(alpha: 0.9),
                          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield, color: _riskColor, size: 14),
                            const SizedBox(width: 6),
                            Text(_geofenceLabel, style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.neonCyan)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Navigate Button
              GestureDetector(
                onTap: _findPoliceStation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(colors: [AppColors.neonCyan, AppColors.neonPurple]),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.radar, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('Scan for Nearby Police Stations', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              if (_isRouting)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Center(child: CircularProgressIndicator(color: AppColors.neonPurple)),
                ),
                
              // (Removed old AI button as the scanning button replaces it)
              const SizedBox(height: 24),

              // Safety Analysis
              Row(
                children: [
                  Text('Local Area Safety Analysis ', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Icon(Icons.verified_user, color: AppColors.neonCyan, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              GlassmorphicCard(
                borderColor: _riskColor.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _riskColor.withValues(alpha: 0.2),
                      ),
                      child: Icon(Icons.circle, color: _riskColor, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overall Area Risk Score', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
                        Text(_riskLabel, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
