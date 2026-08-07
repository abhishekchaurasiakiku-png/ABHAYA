import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/contact_model.dart';
import '../widgets/glass_container.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final List<Contact> _contacts = [
    Contact(id: '1', name: 'Mom', phoneNumber: '+1234567890', relation: 'Family'),
    Contact(id: '2', name: 'Dad', phoneNumber: '+0987654321', relation: 'Family'),
    Contact(id: '3', name: 'Sarah (Friend)', phoneNumber: '+1122334455', relation: 'Friend'),
  ];

  void _addContact() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Contact feature coming soon!')),
    );
  }

  void _removeContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Trusted Contacts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        backgroundColor: Colors.white,
        child: const Icon(Icons.person_add, color: Color(0xFFE94057)),
      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: SafeArea(
          child: _contacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off_outlined, size: 80, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No trusted contacts added yet.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ).animate().fadeIn(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Text(
                              contact.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${contact.relation} • ${contact.phoneNumber}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _removeContact(index),
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.2, end: 0),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
