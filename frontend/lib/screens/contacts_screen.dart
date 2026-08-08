import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  List<dynamic> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final data = await _userService.getProfile();
      if (data.containsKey('emergencyContacts')) {
        setState(() {
          _contacts = data['emergencyContacts'];
        });
      }
    } catch (e) {
      debugPrint('Error loading contacts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveContacts() async {
    setState(() => _isLoading = true);
    try {
      // Cast the contacts to List<Map<String, dynamic>>
      final List<Map<String, dynamic>> payload = _contacts.map((c) => {
        'name': c['name'],
        'phone': c['phone'],
        'email': c['email'],
        'relationship': c['relationship'],
        'notifyOnSos': c['notifyOnSos'] ?? true,
      }).toList();
      await _userService.updateContacts(payload);
    } catch (e) {
      debugPrint('Error saving contacts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddContactDialog({int? editIndex}) {
    final bool isEdit = editIndex != null;
    final Map<String, dynamic> contact = isEdit 
      ? Map<String, dynamic>.from(_contacts[editIndex]) 
      : {'name': '', 'phone': '', 'email': '', 'relationship': 'Family', 'notifyOnSos': true};

    final nameController = TextEditingController(text: contact['name']);
    final phoneController = TextEditingController(text: contact['phone']);
    final emailController = TextEditingController(text: contact['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(
            isEdit ? 'Edit Contact' : 'Add Contact',
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextField(
                  controller: phoneController,
                  style: TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (for alerts)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            if (isEdit)
              TextButton(
                onPressed: () {
                  setState(() {
                    _contacts.removeAt(editIndex);
                  });
                  _saveContacts();
                  Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
              onPressed: () {
                final newContact = {
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                  'relationship': contact['relationship'],
                  'notifyOnSos': true,
                };
                setState(() {
                  if (isEdit) {
                    _contacts[editIndex] = newContact;
                  } else {
                    _contacts.add(newContact);
                  }
                });
                _saveContacts();
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.greenAccent)),
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
        title: Text('Trusted Guardians', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _contacts.isEmpty
              ? Center(
                  child: Text(
                    'No trusted contacts added yet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.redAccent, Colors.orangeAccent],
                            ),
                          ),
                          child: const CircleAvatar(
                            backgroundColor: AppColors.background,
                            child: Icon(Icons.person, color: AppColors.textSecondary),
                          ),
                        ),
                        title: Text(
                          contact['name'] ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          contact['phone'] ?? '',
                          style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: AppColors.textSecondary),
                          onPressed: () => _showAddContactDialog(editIndex: index),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.redAccent, Colors.orangeAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddContactDialog(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.person_add_alt_1, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
