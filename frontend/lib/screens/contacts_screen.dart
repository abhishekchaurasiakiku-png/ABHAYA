import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';

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
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            isEdit ? 'Edit Contact' : 'Add Contact',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                TextField(
                  controller: phoneController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (for alerts)',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text('Trusted Guardians', style: GoogleFonts.poppins()),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _contacts.isEmpty
              ? Center(
                  child: Text(
                    'No contacts added yet.\nAdd someone you trust!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white54),
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
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                            backgroundColor: Color(0xFF0F172A),
                            child: Icon(Icons.person, color: Colors.white70),
                          ),
                        ),
                        title: Text(
                          contact['name'] ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          contact['phone'] ?? '',
                          style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white54),
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
          child: const Icon(Icons.person_add_alt_1, color: Colors.white),
        ),
      ),
    );
  }
}
