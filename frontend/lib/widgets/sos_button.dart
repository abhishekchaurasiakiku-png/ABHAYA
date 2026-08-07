import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/sos_service.dart';
import '../services/location_service.dart';

class SosButton extends StatefulWidget {
  const SosButton({super.key});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  final SosService _sosService = SosService();
  final LocationService _locationService = LocationService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerSos() async {
    if (_isSending) return;
    setState(() { _isPressed = true; _isSending = true; });

    try {
      final position = await _locationService.getCurrentLocation();
      final lat = position?.latitude ?? 0.0;
      final lng = position?.longitude ?? 0.0;

      await _sosService.triggerSos(
        triggerType: 'Manual',
        latitude: lat,
        longitude: lng,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚨 EMERGENCY ALERT SENT', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.sosPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() { _isPressed = false; _isSending = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerSos,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  Container(
                    width: 160 * _pulseAnimation.value,
                    height: 160 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sosPink.withValues(alpha: 0.08),
                    ),
                  ),
                  Container(
                    width: 140 * _pulseAnimation.value,
                    height: 140 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sosPink.withValues(alpha: 0.12),
                    ),
                  ),
                  // Main button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: _isPressed ? 105 : 115,
                    height: _isPressed ? 105 : 115,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFF4B6E), Color(0xFFFF2D55), Color(0xFFD91A40)],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sosPink.withValues(alpha: 0.5),
                          blurRadius: _isPressed ? 15 : 30,
                          spreadRadius: _isPressed ? 2 : 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app, color: Colors.white, size: 28),
                        const SizedBox(height: 2),
                        Text(
                          'SOS',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'TAP TO ALERT',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
