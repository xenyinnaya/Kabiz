import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/business_provider.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../widgets/stitch_sale_product_selector.dart';
import '../widgets/stitch_amount_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class RecordSaleView extends StatefulWidget {
  const RecordSaleView({super.key});

  @override
  State<RecordSaleView> createState() => _RecordSaleViewState();
}

class _RecordSaleViewState extends State<RecordSaleView> {
  Customer? _selectedCustomer;
  final List<_SaleItemEntry> _items = [];

  @override
  void initState() {
    super.initState();
    // Start with one empty item row
    _items.add(_SaleItemEntry());
  }

  int get _grandTotal {
    int total = 0;
    for (var item in _items) {
      if (item.product != null && item.quantity > 0) {
        total += (item.product!.sellingPriceBif * item.quantity).toInt();
      }
    }
    return total;
  }

  void _saveSale() {
    final provider = Provider.of<BusinessProvider>(context, listen: false);

    // Filter valid items
    final validItems = _items.where((i) => i.product != null && i.quantity > 0).toList();
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one valid product.')));
      return;
    }

    final total = _grandTotal;
    final sale = Sale(
      customerId: _selectedCustomer?.id,
      totalAmountBif: total,
      createdAt: DateTime.now(),
    );

    final saleItems = validItems.map((i) => SaleItem(
      saleId: 0, // Assigned by db
      productId: i.product!.id!,
      quantity: i.quantity,
      unitPriceBif: i.product!.sellingPriceBif,
    )).toList();

    provider.addSale(sale, saleItems);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale recorded successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BusinessProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Record Transaction'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.edgeMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.md),
              _buildCustomerSelectorCard(provider),
              const SizedBox(height: AppSpacing.md),
              _buildItemHeader(),
              const SizedBox(height: AppSpacing.sm),
              _buildItemsList(provider),
              const SizedBox(height: AppSpacing.sm),
              _buildAddProductButton(),
              const SizedBox(height: AppSpacing.lg),
              StitchAmountCard(
                title: "Grand Total",
                amountBif: _grandTotal,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSubmitButton(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.gutter),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.3),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.gutter),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Sale',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Create a new transaction',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelectorCard(BusinessProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CUSTOMER (OPTIONAL)',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.outline,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonHideUnderline(
            child: DropdownButton<Customer>(
              isExpanded: true,
              hint: Text(
                'Select Customer or Walk-in',
                style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.outline),
              ),
              value: _selectedCustomer,
              items: provider.customers.map((c) {
                return DropdownMenuItem<Customer>(
                  value: c,
                  child: Text(
                    c.name,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCustomer = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'PRODUCTS TO SELL',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.outline,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        Text(
          '${_items.length} item(s)',
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(BusinessProvider provider) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = _items[index];
        return StitchSaleProductSelector(
          selectedProduct: item.product,
          availableProducts: provider.products,
          quantity: item.quantity,
          onProductChanged: (val) => setState(() => item.product = val),
          onQuantityChanged: (val) => setState(() => item.quantity = val),
          onRemove: () {
            setState(() {
              _items.removeAt(index);
              if (_items.isEmpty) _items.add(_SaleItemEntry());
            });
          },
        );
      },
    );
  }

  Widget _buildAddProductButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => setState(() => _items.add(_SaleItemEntry())),
        icon: const Icon(Icons.add, color: AppColors.primary, size: 20),
        label: Text(
          'Add Another Product',
          style: AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusLg,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _saveSale,
        icon: const Icon(Icons.check_circle_outline, size: 22, color: AppColors.onPrimary),
        label: Text(
          'Complete Sale',
          style: AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusLg,
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.25),
        ),
      ),
    );
  }
}

class _SaleItemEntry {
  Product? product;
  double quantity = 0;
}
