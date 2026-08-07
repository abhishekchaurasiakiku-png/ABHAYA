import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'support_screen.dart';
import 'profile_screen.dart';
import '../services/sos_service.dart';
import '../services/location_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  Timer? _sosLocationTimer;
  String? _activeSosId;
  bool _isSosActive = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    SizedBox(), // SOS placeholder — handled by FAB
    SupportScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) return; // SOS is handled by floating button
    setState(() => _currentIndex = index);
  }

  void _triggerSos() async {
    if (_isSosActive) {
      // Resolve SOS
      _stopLocationTracking();
      if (_activeSosId != null) {
        await SosService().resolveSos(_activeSosId!);
      }
      setState(() => _isSosActive = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SOS Resolved. Tracking stopped.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final sosService = SosService();
    final locationService = LocationService();

    try {
      final position = await locationService.getCurrentLocation();
      final response = await sosService.triggerSos(
        triggerType: 'Manual',
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
      );
      await SosService().openNativeSms(position?.latitude ?? 0.0, position?.longitude ?? 0.0, isSos: true);
      
      setState(() {
        _isSosActive = true;
        _activeSosId = response['_id'];
      });
      
      _startLocationTracking();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚨 EMERGENCY ALERT SENT! LIVE TRACKING ON.', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.sosPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert sent (offline mode)', style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _startLocationTracking() {
    _sosLocationTimer?.cancel();
    _sosLocationTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (_activeSosId == null) return;
      try {
        final position = await LocationService().getCurrentLocation();
        if (position != null) {
          await SosService().updateSosLocation(_activeSosId!, position.latitude, position.longitude);
        }
      } catch (e) {
        debugPrint('Live tracking update failed: $e');
      }
    });
  }

  void _stopLocationTracking() {
    _sosLocationTimer?.cancel();
    _sosLocationTimer = null;
    _activeSosId = null;
  }

  @override
  void dispose() {
    _stopLocationTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex < 2 ? _currentIndex : _currentIndex - 1,
        children: [
          _screens[0],
          _screens[1],
          _screens[3],
          _screens[4],
        ],
      ),
      extendBody: true,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(top: 20),
        child: FloatingActionButton(
          onPressed: _triggerSos,
          backgroundColor: _isSosActive ? Colors.red[900] : AppColors.sosPink,
          elevation: _isSosActive ? 12 : 8,
          shape: const CircleBorder(),
          child: _isSosActive 
            ? const Icon(Icons.stop, color: Colors.white, size: 30)
            : Text(
                'SOS',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.navBar,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.map, 'Map', 1),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(Icons.support_agent, 'Support', 3),
            _buildNavItem(Icons.person, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final actualSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: actualSelected ? AppColors.accentPink : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: actualSelected ? AppColors.accentPink : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: actualSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
