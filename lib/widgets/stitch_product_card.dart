import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class StitchProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StitchProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final isOut = product.stockQuantity <= 0;
    final isLow = !isOut && (product.stockQuantity <= product.lowStockThreshold);

    Color badgeBg;
    Color badgeFg;
    String badgeText;

    if (isOut) {
      badgeBg = AppColors.errorContainer;
      badgeFg = AppColors.onErrorContainer;
      badgeText = 'Out of Stock';
    } else if (isLow) {
      badgeBg = AppColors.tertiaryContainer;
      badgeFg = AppColors.onTertiaryContainer;
      badgeText = 'Low Stock';
    } else {
      badgeBg = AppColors.secondaryContainer;
      badgeFg = AppColors.onSecondaryContainer;
      badgeText = 'In Stock';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderRadiusLg,
        child: InkWell(
          onTap: onTap ?? onEdit,
          borderRadius: AppRadius.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Product Icon + Name & Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isOut
                            ? AppColors.errorContainer.withOpacity(0.4)
                            : isLow
                                ? AppColors.tertiaryContainer.withOpacity(0.4)
                                : AppColors.primaryContainer.withOpacity(0.3),
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: isOut
                            ? AppColors.error
                            : isLow
                                ? AppColors.tertiary
                                : AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.gutter),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Unit: ${product.unit}",
                            style: AppTypography.textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Status Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: AppRadius.borderRadiusXl,
                      ),
                      child: Text(
                        badgeText,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: badgeFg,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.gutter),

                // Bottom Row: Price info & Quantity
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Prices
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sell: ${currency.format(product.sellingPriceBif)}",
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Cost: ${currency.format(product.costPriceBif)}",
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                      // Stock Quantity Badge
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${product.stockQuantity} ${product.unit}",
                                style: AppTypography.textTheme.titleMedium?.copyWith(
                                  color: isOut
                                      ? AppColors.error
                                      : isLow
                                          ? AppColors.tertiary
                                          : AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Threshold: ${product.lowStockThreshold}",
                                style: AppTypography.textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          if (onEdit != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.outline),
                              onPressed: onEdit,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
