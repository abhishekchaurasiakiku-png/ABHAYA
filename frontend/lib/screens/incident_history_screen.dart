import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../services/incident_service.dart';
import '../widgets/glassmorphic_card.dart';

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  final IncidentService _incidentService = IncidentService();
  bool _isLoading = true;
  List<dynamic> _incidents = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    try {
      final data = await _incidentService.getIncidents();
      if (mounted) {
        setState(() {
          _incidents = data['incidents'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Incident History', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.neonCyan))
          : _incidents.isEmpty
              ? Center(
                  child: Text('No incidents recorded.', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _incidents.length,
                  itemBuilder: (context, index) {
                    final incident = _incidents[index];
                    final date = DateTime.tryParse(incident['timestamp'] ?? '');
                    final formattedDate = date != null ? DateFormat('MMM d, yyyy - h:mm a').format(date.toLocal()) : 'Unknown Date';
                    final type = incident['triggerType'] ?? 'Unknown Type';
                    final status = incident['status'] ?? 'Unknown Status';
                    
                    Color statusColor = Colors.grey;
                    if (status == 'Active') statusColor = AppColors.sosPink;
                    if (status == 'Resolved') statusColor = AppColors.neonGreen;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassmorphicCard(
                        borderColor: statusColor.withValues(alpha: 0.3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  type,
                                  style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(status, style: GoogleFonts.poppins(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: AppColors.textSecondary, size: 14),
                                const SizedBox(width: 6),
                                Text(formattedDate, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
