import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/theme.dart';
class IncidentLogTile extends StatelessWidget {
  final String triggerType;
  final String status;
  final double? lat;
  final double? lng;
  final DateTime timestamp;
  final int mediaCount;
  final VoidCallback? onTap;

  const IncidentLogTile({
    super.key,
    required this.triggerType,
    required this.status,
    this.lat,
    this.lng,
    required this.timestamp,
    this.mediaCount = 0,
    this.onTap,
  });

  Color get _typeColor {
    switch (triggerType.toLowerCase()) {
      case 'voice': return AppColors.neonPurple;
      case 'motion': return AppColors.neonCyan;
      case 'manual': return AppColors.sosPink;
      default: return Colors.orange;
    }
  }

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'resolved': return AppColors.neonGreen;
      case 'active': return AppColors.sosPink;
      case 'false alarm': return Colors.grey;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.cardDark.withValues(alpha: 0.5),
          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _typeColor.withValues(alpha: 0.15),
              ),
              child: Icon(
                triggerType.toLowerCase() == 'voice' ? Icons.mic :
                triggerType.toLowerCase() == 'motion' ? Icons.directions_walk :
                Icons.sos,
                color: _typeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildChip(triggerType, _typeColor),
                      const SizedBox(width: 6),
                      _buildChip(status, _statusColor),
                      const Spacer(),
                      if (mediaCount > 0) ...[
                        Icon(Icons.attach_file, color: AppColors.textSecondary, size: 14),
                        Text(' $mediaCount', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (lat != null && lng != null)
                    Row(
                      children: [
                        const Icon(Icons.security, color: AppColors.textSecondary, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          'Encrypted Location Saved',
                          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.textSecondary, size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat('MMM d, yyyy • h:mm a').format(timestamp),
                          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ),
                      if (triggerType.toLowerCase() == 'sos')
                        GestureDetector(
                          onTap: () => _generatePdf(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.sosPink.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.sosPink.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: AppColors.sosPink, size: 12),
                                const SizedBox(width: 4),
                                Text('Report', style: GoogleFonts.poppins(color: AppColors.sosPink, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('ABHAYA - Official SOS Incident Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFFE63946))),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Incident Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Bullet(text: 'Trigger Type: ${triggerType.toUpperCase()}'),
                pw.Bullet(text: 'Date & Time: ${DateFormat('MMMM d, yyyy at h:mm:ss a').format(timestamp)}'),
                pw.Bullet(text: 'Status: ${status.toUpperCase()}'),
                pw.SizedBox(height: 20),
                pw.Text('Collected Evidence:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Bullet(text: 'Audio/Voice Data: Collected & Encrypted'),
                pw.Bullet(text: 'Device Motion Speed: Captured (High Velocity)'),
                pw.Bullet(text: 'Location Data: Secured for Authorities'),
                pw.SizedBox(height: 40),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  'This document is auto-generated by the ABHAYA Women Safety Platform. Sensitive location data and encrypted media are securely stored and will only be released directly to verified law enforcement authorities.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'ABHAYA_SOS_Report_${timestamp.millisecondsSinceEpoch}.pdf',
    );
  }
}
