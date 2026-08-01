import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class StitchExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const StitchExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('rent') || cat.contains('loyer')) {
      return Icons.home_work_outlined;
    } else if (cat.contains('utilit') || cat.contains('eau') || cat.contains('electr')) {
      return Icons.lightbulb_outlined;
    } else if (cat.contains('salary') || cat.contains('salair') || cat.contains('staff')) {
      return Icons.people_outline;
    } else if (cat.contains('transport') || cat.contains('freight')) {
      return Icons.local_shipping_outlined;
    } else if (cat.contains('supply') || cat.contains('stock') || cat.contains('achat')) {
      return Icons.inventory_2_outlined;
    } else {
      return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final formattedDate = DateFormat('MMM d, yyyy').format(expense.expenseDate);

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category Icon Badge (Secondary green accent)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: AppColors.onSecondaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Description, Category badge, and Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: AppTypography.textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer.withOpacity(0.5),
                              borderRadius: AppRadius.borderRadiusSm,
                            ),
                            child: Text(
                              expense.category,
                              style: AppTypography.textTheme.labelLarge?.copyWith(
                                color: AppColors.onSecondaryContainer,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            formattedDate,
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
                // Amount in Primary Blue Accent
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currency.format(expense.amountBif),
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (onEdit != null || onDelete != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onEdit != null)
                            InkWell(
                              onTap: onEdit,
                              child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.outline),
                            ),
                          if (onEdit != null && onDelete != null)
                            const SizedBox(width: AppSpacing.xs),
                          if (onDelete != null)
                            InkWell(
                              onTap: onDelete,
                              child: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                            ),
                        ],
                      ),
                    ],
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
