import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class StitchSaleProductSelector extends StatelessWidget {
  final Product? selectedProduct;
  final List<Product> availableProducts;
  final double quantity;
  final ValueChanged<Product?> onProductChanged;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback? onRemove;

  const StitchSaleProductSelector({
    super.key,
    required this.selectedProduct,
    required this.availableProducts,
    required this.quantity,
    required this.onProductChanged,
    required this.onQuantityChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final isSelected = selectedProduct != null;
    final isExceedingStock = isSelected && (quantity > selectedProduct!.stockQuantity);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: isExceedingStock
              ? AppColors.error
              : isSelected
                  ? AppColors.primary
                  : AppColors.outlineVariant,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Product Dropdown & Remove Button
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer.withOpacity(0.3)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: isSelected ? AppColors.primary : AppColors.outline,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Product>(
                    isExpanded: true,
                    hint: Text(
                      'Select Product',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.outline),
                    ),
                    value: selectedProduct,
                    items: availableProducts.map((p) {
                      return DropdownMenuItem<Product>(
                        value: p,
                        child: Text(
                          p.name,
                          style: AppTypography.textTheme.bodyLarge?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: onProductChanged,
                  ),
                ),
              ),
              if (onRemove != null) ...[
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 22),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),

          // Product Details & Quantity Row
          if (isSelected) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Row(
                children: [
                  // Price & Available Stock Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Price: ${currency.format(selectedProduct!.sellingPriceBif)}",
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              "Stock: ${selectedProduct!.stockQuantity} ${selectedProduct!.unit}",
                              style: AppTypography.textTheme.labelSmall?.copyWith(
                                color: selectedProduct!.stockQuantity <= selectedProduct!.lowStockThreshold
                                    ? AppColors.error
                                    : AppColors.onSurfaceVariant,
                                fontWeight: selectedProduct!.stockQuantity <= selectedProduct!.lowStockThreshold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (isExceedingStock) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                                decoration: BoxDecoration(
                                  color: AppColors.errorContainer,
                                  borderRadius: AppRadius.borderRadiusSm,
                                ),
                                child: Text(
                                  'Exceeds Stock',
                                  style: AppTypography.textTheme.labelSmall?.copyWith(
                                    color: AppColors.onErrorContainer,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quantity Field
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: quantity > 0 ? (quantity == quantity.roundToDouble() ? quantity.toInt().toString() : quantity.toString()) : '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Qty (${selectedProduct!.unit})',
                        labelStyle: AppTypography.textTheme.labelSmall?.copyWith(color: AppColors.outline),
                        filled: true,
                        fillColor: AppColors.surfaceContainerHigh,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.borderRadiusSm,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      ),
                      onChanged: (val) {
                        onQuantityChanged(double.tryParse(val) ?? 0.0);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
