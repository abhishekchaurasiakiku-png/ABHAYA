import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../widgets/glassmorphic_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  String _name = 'User';
  String _email = '';
  String _phone = '';
  String _bloodGroup = 'Not set';
  String _medicalNotes = 'No allergies or medical notes recorded yet.';
  String _homeAddress = 'Set residence address for automated arrival check-ins.';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    // Load cached data first
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'User';
      _email = prefs.getString('user_email') ?? '';
      _phone = prefs.getString('user_phone') ?? '';
    });

    // Then fetch from backend
    try {
      final data = await _userService.getProfile();
      if (mounted) {
        setState(() {
          _name = data['name'] ?? _name;
          _email = data['email'] ?? _email;
          _phone = data['phone'] ?? _phone;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await AuthService().logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
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
              Text('Guardian Profile ✨', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Personalized Security & Live AI Detection Sensors', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 20),

              // User Info Card
              GlassmorphicCard(
                borderColor: AppColors.neonPurple.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [AppColors.neonPurple, AppColors.sosPink]),
                        border: Border.all(color: AppColors.neonPurple, width: 2),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.neonGreen,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 13),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _email.isNotEmpty ? _email : 'No email set',
                                  style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                _phone.isNotEmpty ? _phone : 'No phone set',
                                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.tune, color: AppColors.neonCyan, size: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Emergency & Medical Section
              Row(
                children: [
                  Text('Emergency & Medical...', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, color: AppColors.neonCyan, size: 16),
                  const SizedBox(width: 4),
                  Text('Edit Details', style: GoogleFonts.poppins(color: AppColors.neonCyan, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Vital paramedical triage & smart home safe-zone geofencing',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 14),

              GlassmorphicCard(
                child: Column(
                  children: [
                    _buildMedicalRow(
                      icon: Icons.favorite,
                      iconColor: AppColors.sosPink,
                      title: 'Blood Group & Vital Info',
                      subtitle: 'Blood Group: $_bloodGroup (Tap Edit)',
                      subtitleColor: AppColors.neonGreen,
                    ),
                    const Divider(color: AppColors.cardBorder, height: 24),
                    _buildMedicalRow(
                      icon: Icons.medical_services,
                      iconColor: AppColors.neonCyan,
                      title: 'Medical Notes / Allergies (ER Ready)',
                      subtitle: _medicalNotes,
                    ),
                    const Divider(color: AppColors.cardBorder, height: 24),
                    _buildMedicalRow(
                      icon: Icons.home,
                      iconColor: Colors.blue,
                      title: 'Home Safe Zone Geofence Address',
                      subtitle: _homeAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              GestureDetector(
                onTap: _logout,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.sosPink.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.sosPink.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text('Logout', style: GoogleFonts.poppins(color: AppColors.sosPink, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? subtitleColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: iconColor.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(color: subtitleColor ?? AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
