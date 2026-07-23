import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class RecordSaleView extends StatefulWidget {
  const RecordSaleView({super.key});

  @override
  State<RecordSaleView> createState() => _RecordSaleViewState();
}

class _RecordSaleViewState extends State<RecordSaleView> {
  Customer? _selectedCustomer;
  final List<_SaleItemEntry> _items = [];
  final _currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Record Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.edgeMargin),
        child: Column(
          children: [
            // Customer Selection
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin, vertical: AppSpacing.unit),
              decoration: BoxDecoration(
                color: AppColors.surface, 
                borderRadius: AppRadius.borderRadiusLg,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Customer>(
                  isExpanded: true,
                  hint: Text('Select Customer (Optional)', style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                  value: _selectedCustomer,
                  items: provider.customers.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.name, style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurface)));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCustomer = val),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Items List
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.gutter),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: AppRadius.borderRadiusLg,
                      color: AppColors.surface,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Product>(
                              isExpanded: true,
                              hint: Text('Product', style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                              value: item.product,
                              items: provider.products.map((p) {
                                return DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis, style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurface)));
                              }).toList(),
                              onChanged: (val) => setState(() => item.product = val),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.gutter),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: item.quantity > 0 ? item.quantity.toString() : '',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Qty'),
                            onChanged: (val) => setState(() => item.quantity = double.tryParse(val) ?? 0),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: AppColors.error),
                          onPressed: () {
                            setState(() {
                              _items.removeAt(index);
                              if (_items.isEmpty) _items.add(_SaleItemEntry());
                            });
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            // Add Item Button
            TextButton.icon(
              onPressed: () => setState(() => _items.add(_SaleItemEntry())),
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: Text('Add Another Product', style: textTheme.labelLarge?.copyWith(color: AppColors.primary)),
            ),
            
            const Divider(color: AppColors.outlineVariant, height: AppSpacing.xl),
            
            // Grand Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grand Total:', style: textTheme.titleMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                Text(_currency.format(_grandTotal), style: textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSale,
                child: const Text('Complete Sale'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SaleItemEntry {
  Product? product;
  double quantity = 0;
}
