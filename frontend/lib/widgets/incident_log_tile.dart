import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
                        const Icon(Icons.location_on, color: AppColors.textSecondary, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}',
                          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.textSecondary, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(timestamp),
                        style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
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
}
