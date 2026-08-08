import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  void _submit() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      if (_isLogin) {
        await _authService.login(_emailController.text.trim(), _passwordController.text);
      } else {
        await _authService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          phone: _phoneController.text.trim(),
        );
      }
      if (mounted) Navigator.pushReplacementNamed(context, '/main');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Connection failed. Is the backend running?');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppColors.neonPurple, AppColors.sosPink]),
                      boxShadow: [
                        BoxShadow(color: AppColors.neonPurple.withValues(alpha: 0.3), blurRadius: 20),
                      ],
                    ),
                    child: const Icon(Icons.shield, color: AppColors.textPrimary, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin ? 'Sign in to A.B.H.A.Y.A' : 'Join A.B.H.A.Y.A',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.sosPink.withValues(alpha: 0.15),
                        border: Border.all(color: AppColors.sosPink.withValues(alpha: 0.4)),
                      ),
                      child: Text(_error!, style: GoogleFonts.poppins(color: AppColors.sosPink, fontSize: 13)),
                    ),

                  if (!_isLogin) ...[
                    _buildTextField(_nameController, 'Full Name', Icons.person_outline),
                    const SizedBox(height: 14),
                    _buildTextField(_phoneController, 'Phone Number (e.g. +91...)', Icons.phone_outlined),
                    const SizedBox(height: 14),
                  ],
                  _buildTextField(_emailController, 'Email', Icons.email_outlined),
                  const SizedBox(height: 14),
                  _buildTextField(_passwordController, 'Password', Icons.lock_outline, obscure: true),
                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sosPink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                          ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => setState(() { _isLogin = !_isLogin; _error = null; }),
                    child: Text(
                      _isLogin ? "Don't have an account? Register" : "Already have an account? Login",
                      style: GoogleFonts.poppins(color: AppColors.neonPurple, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonCyan),
        ),
      ),
    );
  }
}
