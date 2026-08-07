import 'package:flutter/material.dart';
import '../services/sos_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SosButton extends StatefulWidget {
  const SosButton({super.key});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  final SosService sosService = SosService();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerSos() async {
    setState(() => _isPressed = true);
    await sosService.triggerSos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('EMERGENCY ALERT SENT', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => _triggerSos(),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse rings
              Container(
                width: 200 * _pulseAnimation.value,
                height: 200 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withOpacity((1.0 - (_pulseAnimation.value - 1.0) * 2).clamp(0.0, 1.0)),
                ),
              ),
              Container(
                width: 170 * (_pulseAnimation.value * 0.8).clamp(1.0, 1.5),
                height: 170 * (_pulseAnimation.value * 0.8).clamp(1.0, 1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              // Inner Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _isPressed ? 140 : 150,
                height: _isPressed ? 140 : 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4B4B), Color(0xFFD32F2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.6),
                      blurRadius: _isPressed ? 10 : 30,
                      spreadRadius: _isPressed ? 2 : 10,
                      offset: _isPressed ? const Offset(0, 0) : const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'SOS',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: _isPressed ? 34 : 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
