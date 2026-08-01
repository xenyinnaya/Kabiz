import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'stitch_status_badge.dart';

class StitchDebtCard extends StatelessWidget {
  final Map<String, dynamic> debt;
  final VoidCallback? onTap;
  final VoidCallback? onStatusUpdate;

  const StitchDebtCard({
    super.key,
    required this.debt,
    this.onTap,
    this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');

    final customerName = debt['customer_name']?.toString() ?? 'Unknown';
    final amount = (debt['amount_bif'] as num?)?.toInt() ?? 0;
    final status = debt['status']?.toString() ?? 'pending';
    final isPaid = status.toLowerCase() == 'paid';

    DateTime? dueDate;
    final rawDueDate = debt['due_date'];
    if (rawDueDate is DateTime) {
      dueDate = rawDueDate;
    } else if (rawDueDate is String) {
      dueDate = DateTime.tryParse(rawDueDate);
    }

    final formattedDueDate = dueDate != null
        ? DateFormat('MMM d, yyyy').format(dueDate)
        : rawDueDate?.toString().substring(0, 10) ?? 'N/A';

    final firstChar = customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderRadiusLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Customer Avatar / Initial Container
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isPaid
                          ? AppColors.surfaceContainerHigh
                          : AppColors.primaryContainer.withOpacity(0.4),
                      child: Text(
                        firstChar,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: isPaid ? AppColors.onSurfaceVariant : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Customer Name and Due Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: AppTypography.textTheme.bodyLarge?.copyWith(
                              color: isPaid ? AppColors.onSurfaceVariant : AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                              decoration: isPaid ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                "Due: $formattedDueDate",
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Amount in BIF
                    Text(
                      currency.format(amount),
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: isPaid ? AppColors.onSurfaceVariant : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: isPaid ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StitchStatusBadge(
                      status: status,
                      dueDate: dueDate,
                    ),
                    if (!isPaid && onStatusUpdate != null)
                      TextButton.icon(
                        onPressed: onStatusUpdate,
                        icon: const Icon(Icons.check, size: 16, color: AppColors.secondary),
                        label: Text(
                          'Mark Paid',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
