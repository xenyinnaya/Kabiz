import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class StitchStatusBadge extends StatelessWidget {
  final String status;
  final DateTime? dueDate;

  const StitchStatusBadge({
    super.key,
    required this.status,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.trim().toLowerCase();
    final isPaid = normalizedStatus == 'paid';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = !isPaid &&
        dueDate != null &&
        DateTime(dueDate!.year, dueDate!.month, dueDate!.day).isBefore(today);

    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (isPaid) {
      bg = AppColors.secondaryContainer;
      fg = AppColors.onSecondaryContainer;
      icon = Icons.check_circle_outline;
      label = 'PAID';
    } else if (isOverdue) {
      bg = AppColors.errorContainer;
      fg = AppColors.onErrorContainer;
      icon = Icons.warning_amber_rounded;
      label = 'OVERDUE';
    } else {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
      icon = Icons.schedule;
      label = 'PENDING';
    }

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
