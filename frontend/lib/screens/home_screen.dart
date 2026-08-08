import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:torch_light/torch_light.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import '../widgets/sos_button.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/safety_toolkit_tile.dart';
import '../services/user_service.dart';
import '../services/sos_service.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import 'map_screen.dart';
import 'trip_monitor_screen.dart';
import 'incident_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';
  late Map<String, String> _currentTip;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _currentTip = AppConstants.safetyTips[Random().nextInt(AppConstants.safetyTips.length)];
  }

  void _loadUserName() async {
    try {
      final data = await UserService().getProfile();
      if (mounted) setState(() => _userName = data['name'] ?? 'User');
    } catch (e) {
      final name = await AuthService().getUserName();
      if (mounted) setState(() => _userName = name);
    }
  }

  void _toggleFlashlight() async {
    try {
      final isTorchAvailable = await TorchLight.isTorchAvailable();
      if (isTorchAvailable) {
        if (_isTorchOn) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }
        if (mounted) setState(() => _isTorchOn = !_isTorchOn);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not toggle flashlight')),
        );
      }
    }
  }

  void _recordEvidence() async {
    final picker = ImagePicker();
    await picker.pickVideo(source: ImageSource.camera);
    // In a real app, this video would be saved/uploaded securely
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $_userName ✨',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.neonGreen),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Shield Active & Monitoring',
                                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.neonCyan.withValues(alpha: 0.3), AppColors.neonPurple.withValues(alpha: 0.3)],
                      ),
                      border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.gps_fixed, color: AppColors.neonCyan, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Live Protection Card
              GlassmorphicCard(
                borderColor: AppColors.neonPurple.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.sosPink.withValues(alpha: 0.2),
                            ),
                            child: Text(
                              'LIVE PROTECTION',
                              style: GoogleFonts.poppins(color: AppColors.sosPink, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'You Are Never\nAlone',
                            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'SafeHer AI & real-time guardian shield is actively guarding your journey 24/7.',
                            style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.accentPink.withValues(alpha: 0.3), AppColors.neonPurple.withValues(alpha: 0.3)],
                        ),
                      ),
                      child: const Icon(Icons.verified_user, color: AppColors.accentPink, size: 36),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // SOS Button
              const Center(child: SosButton()),
              const SizedBox(height: 24),

              // Quick Actions Row
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 8,
                runSpacing: 16,
                children: [
                  QuickActionButton(
                    icon: Icons.phone,
                    label: 'Emergency',
                    iconColor: AppColors.sosPink,
                    onTap: () => _dial('112'),
                  ),
                  QuickActionButton(
                    icon: Icons.support_agent,
                    label: '1091 Wom...',
                    iconColor: AppColors.accentPink,
                    onTap: () => _dial('1091'),
                  ),
                  QuickActionButton(
                    icon: Icons.fiber_manual_record,
                    label: 'Evidence',
                    iconColor: AppColors.neonPurple,
                    onTap: _recordEvidence,
                  ),
                  QuickActionButton(
                    icon: Icons.flashlight_on,
                    label: _isTorchOn ? 'Flash Off' : 'Flashlight',
                    iconColor: _isTorchOn ? AppColors.sosPink : AppColors.neonPurple.withValues(alpha: 0.7),
                    onTap: _toggleFlashlight,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Safety Toolkit
              Text(
                'Safety Toolkit',
                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 130, // Fixed height to prevent overflow
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                children: [
                  SafetyToolkitTile(
                    icon: Icons.my_location,
                    title: 'Live Location',
                    subtitle: 'Share real-time GPS',
                    iconColor: AppColors.accentPink,
                    onTap: _shareLiveLocation,
                  ),
                  SafetyToolkitTile(
                    icon: Icons.contacts,
                    title: 'Emergency C...',
                    subtitle: 'Call or alert guardia...',
                    iconColor: AppColors.sosPink,
                    onTap: () => Navigator.pushNamed(context, '/contacts'),
                  ),
                  SafetyToolkitTile(
                    icon: Icons.verified_user,
                    title: 'Safety Zone',
                    subtitle: 'Geofence all-clear',
                    iconColor: AppColors.neonPurple,
                    onTap: () => Navigator.pushNamed(context, '/main'), // Assumes tab change or map screen
                  ),
                  SafetyToolkitTile(
                    icon: Icons.directions_walk,
                    title: 'Safe Route',
                    subtitle: 'AI monitored naviga...',
                    iconColor: AppColors.neonPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TripMonitorScreen()),
                      );
                    }, // Routing to Safe Commute UI
                  ),
                  SafetyToolkitTile(
                    icon: Icons.local_police,
                    title: 'Nearby Police',
                    subtitle: 'Locate closest stati...',
                    iconColor: AppColors.accentPink,
                    onTap: _findPoliceStation,
                  ),
                  SafetyToolkitTile(
                    icon: Icons.history,
                    title: 'Incident History',
                    subtitle: 'View security logs',
                    iconColor: AppColors.neonPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const IncidentHistoryScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Daily Safety Tip
              GlassmorphicCard(
                borderColor: Colors.amber.withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DAILY SAFETY TIP',
                          style: GoogleFonts.poppins(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.amber.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentTip['title']!,
                                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentTip['body']!,
                                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                              ),
                            ],
                          ),
                        ),
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

  void _dial(String number) async {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      await FlutterPhoneDirectCaller.callNumber(number);
    } else {
      final Uri phoneUri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    }
  }

  void _shareLiveLocation() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sharing location with trusted contacts...')),
        );
      }
      final position = await LocationService().getCurrentLocation();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied or service disabled')),
          );
        }
        return;
      }
      await SosService().shareLiveLocation(position.latitude, position.longitude);
      await SosService().openNativeSms(position.latitude, position.longitude, isSos: false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live location sent via Email/SMS!')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch or share location')),
        );
      }
    }
  }

  void _findPoliceStation() {
    // Navigate to MapScreen which will handle its own Police Station rendering now.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Scaffold(
        appBar: null, // Let MapScreen use safe area
        body: MapScreen(),
      )),
    );
  }
}
