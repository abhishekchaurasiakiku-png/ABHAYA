import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../routes/app_routes.dart';
import '../services/location_service.dart';
import '../services/sos_service.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _locationService = LocationService();
  final _sosService = SosService();
  String _currentLocation = 'Fetching location...';
  bool _isSosActive = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final hasPermission = await _locationService.requestPermission();
    if (hasPermission) {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentLocation = 'Lat: ${position.latitude.toStringAsFixed(4)}, '
              'Lng: ${position.longitude.toStringAsFixed(4)}';
        });
      } else {
        setState(() => _currentLocation = 'Location unavailable');
      }
    } else {
      setState(() => _currentLocation = 'Permission denied');
    }
  }

  void _toggleSos() async {
    setState(() => _isSosActive = !_isSosActive);

    if (_isSosActive) {
      final position = await _locationService.getCurrentLocation();
      await _sosService.activateSOS(position);
    } else {
      await _sosService.deactivateSOS();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'A.B.H.A.Y.A',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.contacts),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2.seconds),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Location',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentLocation,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                const Spacer(),
                Center(
                  child: GestureDetector(
                    onTap: _toggleSos,
                    child: GlassContainer(
                      opacity: _isSosActive ? 0.4 : 0.1,
                      color: _isSosActive ? Colors.red : Colors.white,
                      border: Border.all(
                        color: _isSosActive ? Colors.redAccent : Colors.white30,
                        width: 2,
                      ),
                      padding: const EdgeInsets.all(40),
                      borderRadius: BorderRadius.circular(100),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sos_rounded,
                            size: 100,
                            color: _isSosActive ? Colors.white : Colors.redAccent,
                          )
                              .animate(target: _isSosActive ? 1 : 0)
                              .scale(end: const Offset(1.1, 1.1))
                              .shake(hz: 3),
                          const SizedBox(height: 10),
                          Text(
                            _isSosActive ? 'ACTIVE' : 'PRESS TO SOS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isSosActive ? Colors.white : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(target: _isSosActive ? 1 : 0)
                    .custom(
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 1.0 + (value * 0.05),
                          child: child,
                        );
                      },
                    ),
                ).animate().fadeIn(delay: 300.ms).scale(),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.video_call,
                        label: 'Video Evidence',
                        onTap: () {},
                        delay: 400.ms,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.map,
                        label: 'Safe Routes',
                        onTap: () {},
                        delay: 500.ms,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.local_police,
                        label: 'Helpline',
                        onTap: () {},
                        delay: 600.ms,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.medical_services,
                        label: 'First Aid',
                        onTap: () {},
                        delay: 700.ms,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Duration delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: delay).slideY(begin: 0.2, end: 0),
    );
  }
}
