import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/theme.dart';
import '../services/incident_service.dart';
import '../services/encrypted_storage_service.dart';
import '../widgets/helpline_card.dart';
import '../widgets/incident_log_tile.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final IncidentService _incidentService = IncidentService();
  final EncryptedStorageService _encryptedStorage = EncryptedStorageService();
  List<dynamic> _incidents = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Voice', 'Motion', 'SOS', 'Manual'];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  void _loadIncidents() async {
    try {
      // First, load encrypted logs from local device
      final localIncidents = await _encryptedStorage.loadIncidents();
      if (mounted && localIncidents.isNotEmpty) {
        setState(() {
          _incidents = localIncidents;
          _isLoading = false;
        });
      }

      // Then sync with the server
      final data = await _incidentService.getIncidents();
      final fetchedIncidents = data['incidents'] ?? [];
      
      // Save synced logs to encrypted local storage
      await _encryptedStorage.saveIncidents(fetchedIncidents);

      if (mounted) {
        setState(() { 
          _incidents = fetchedIncidents; 
          _isLoading = false; 
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredIncidents {
    if (_selectedFilter == 'All') return _incidents;
    return _incidents.where((i) => (i['triggerType'] ?? '').toString().toLowerCase() == _selectedFilter.toLowerCase()).toList();
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
              Text('Support & Helplines ✨', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Immediate National Helplines & AI Security Logs', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 20),

              // Helplines Header
              Row(
                children: [
                  Expanded(
                    child: Text("24/7 Rapid Response Helplines ", style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.phone, color: AppColors.accentPink, size: 18),
                ],
              ),
              const SizedBox(height: 14),

              // Helpline Cards Grid
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
                  HelplineCard(number: '1091', title: 'Women Helpline', subtitle: 'National Support', accentColor: AppColors.accentPink, onCall: () => _dial('1091')),
                  HelplineCard(number: '181', title: 'Abuse Helpline', subtitle: 'Domestic Support', accentColor: AppColors.neonPurple, onCall: () => _dial('181')),
                  HelplineCard(number: '112', title: 'Police Force', subtitle: 'Immediate Emergency', accentColor: AppColors.neonPurple, onCall: () => _dial('112')),
                  HelplineCard(number: '108', title: 'Ambulance & M...', subtitle: 'Medical Response', accentColor: AppColors.accentPink, onCall: () => _dial('108')),
                ],
              ),
              const SizedBox(height: 28),

              // Activity Logs Header
              Row(
                children: [
                  Expanded(
                    child: Text('AI Protection Activity Logs ', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.description, color: Colors.amber, size: 18),
                ],
              ),
              const SizedBox(height: 14),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected ? AppColors.neonPurple.withValues(alpha: 0.2) : AppColors.cardDark,
                            border: Border.all(color: isSelected ? AppColors.neonPurple : AppColors.cardBorder.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (filter == 'Voice') const Icon(Icons.mic, size: 13, color: AppColors.neonPurple),
                              if (filter == 'Motion') const Icon(Icons.directions_walk, size: 13, color: AppColors.neonPurple),
                              if (filter == 'SOS') const Icon(Icons.sos, size: 13, color: AppColors.sosPink),
                              if (filter != 'All' && filter != 'Manual') const SizedBox(width: 4),
                              Text(
                                filter,
                                style: GoogleFonts.poppins(
                                  color: isSelected ? AppColors.neonPurple : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Incident Logs
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.accentPink),
                ))
              else if (_filteredIncidents.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Icon(Icons.shield, color: AppColors.neonPurple.withValues(alpha: 0.5), size: 40),
                        const SizedBox(height: 10),
                        Text('No incidents recorded', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
                        Text('Your safety log is clear!', style: GoogleFonts.poppins(color: AppColors.neonPurple, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              else
                ..._filteredIncidents.map((incident) {
                  final coords = incident['location']?['coordinates'] as List?;
                  return IncidentLogTile(
                    triggerType: incident['triggerType'] ?? 'Manual',
                    status: incident['status'] ?? 'Active',
                    lat: coords != null && coords.length >= 2 ? (coords[1] as num).toDouble() : null,
                    lng: coords != null && coords.length >= 2 ? (coords[0] as num).toDouble() : null,
                    timestamp: DateTime.tryParse(incident['timestamp'] ?? '') ?? DateTime.now(),
                    mediaCount: (incident['mediaLinks'] as List?)?.length ?? 0,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
