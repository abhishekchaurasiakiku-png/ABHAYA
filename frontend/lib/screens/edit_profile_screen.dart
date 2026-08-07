import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditProfileScreen({super.key, required this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _medicalDetailsController;
  late TextEditingController _homeAddressController;
  late TextEditingController _workAddressController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData['phone'] ?? '');
    _bloodGroupController = TextEditingController(text: widget.initialData['bloodGroup'] ?? '');
    _medicalDetailsController = TextEditingController(text: widget.initialData['medicalDetails'] ?? '');
    _homeAddressController = TextEditingController(text: widget.initialData['homeAddress'] ?? '');
    _workAddressController = TextEditingController(text: widget.initialData['workAddress'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bloodGroupController.dispose();
    _medicalDetailsController.dispose();
    _homeAddressController.dispose();
    _workAddressController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await _userService.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        bloodGroup: _bloodGroupController.text.trim(),
        medicalDetails: _medicalDetailsController.text.trim(),
        homeAddress: _homeAddressController.text.trim(),
        workAddress: _workAddressController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
        Navigator.pop(context, true); // Return true to refresh profile screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Edit Profile', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.neonCyan))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Personal Details'),
                  _buildTextField('Full Name', _nameController),
                  _buildTextField('Phone Number', _phoneController, keyboardType: TextInputType.phone),
                  
                  const SizedBox(height: 20),
                  _buildLabel('Medical & Emergency Info'),
                  _buildTextField('Blood Group', _bloodGroupController),
                  _buildTextField('Medical Notes / Allergies', _medicalDetailsController, maxLines: 3),
                  
                  const SizedBox(height: 20),
                  _buildLabel('Safe Zone Addresses'),
                  _buildTextField('Home Address', _homeAddressController, maxLines: 2),
                  _buildTextField('Work/School Address', _workAddressController, maxLines: 2),
                  
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveProfile,
                      child: Text('Save Changes', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(text, style: GoogleFonts.poppins(color: AppColors.neonCyan, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.neonPurple, width: 2),
          ),
        ),
      ),
    );
  }
}
