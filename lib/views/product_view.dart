import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});
  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final filtered = provider.products.where((p) => p.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Product Inventory')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.edgeMargin),
        child: Column(
          children: [
            TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (c, i) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (c, i) {
                  final p = filtered[i];
                  final isLow = p.stockQuantity <= p.lowStockThreshold;
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(Icons.inventory_2, color: isLow ? AppColors.error : AppColors.primary),
                      title: Text(p.name, style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                      subtitle: Text("Cost: ${currency.format(p.costPriceBif)} | Sell: ${currency.format(p.sellingPriceBif)}", style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                      trailing: Text("${p.stockQuantity} ${p.unit}", style: textTheme.bodyMedium?.copyWith(color: isLow ? AppColors.error : AppColors.onSurface, fontWeight: FontWeight.bold)),
                      onTap: () => _showAddProductDialog(context, product: p),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, {Product? product}) {
    final isEdit = product != null;
    final formKey = GlobalKey<FormState>();

    String name = product?.name ?? '';
    double qty = product?.stockQuantity ?? 0.0;
    String unit = product?.unit ?? 'piece';
    int cost = product?.costPriceBif ?? 0;
    int sell = product?.sellingPriceBif ?? 0;
    double threshold = product?.lowStockThreshold ?? 5.0;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
          title: Text(isEdit ? 'Edit Product' : 'Add Product', style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    onSaved: (v) => name = v!,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: isEdit ? qty.toString() : '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Stock Qty'),
                          validator: (v) => double.tryParse(v!) == null ? 'Number required' : null,
                          onSaved: (v) => qty = double.parse(v!),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextFormField(
                          initialValue: unit,
                          decoration: const InputDecoration(labelText: 'Unit (e.g., kg)'),
                          validator: (v) => v!.isEmpty ? 'Unit required' : null,
                          onSaved: (v) => unit = v!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: isEdit ? cost.toString() : '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cost Price (BIF)'),
                          validator: (v) => int.tryParse(v!) == null ? 'Integer required' : null,
                          onSaved: (v) => cost = int.parse(v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: isEdit ? sell.toString() : '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Selling Price (BIF)'),
                          validator: (v) => int.tryParse(v!) == null ? 'Integer required' : null,
                          onSaved: (v) => sell = int.parse(v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    initialValue: isEdit ? threshold.toString() : '5.0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Low Stock Threshold'),
                    validator: (v) => double.tryParse(v!) == null ? 'Number required' : null,
                    onSaved: (v) => threshold = double.parse(v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.outline)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final provider = Provider.of<BusinessProvider>(context, listen: false);
                  
                  if (isEdit) {
                    provider.updateProduct(product.copyWith(
                      name: name,
                      stockQuantity: qty,
                      unit: unit,
                      costPriceBif: cost,
                      sellingPriceBif: sell,
                      lowStockThreshold: threshold,
                    ));
                  } else {
                    provider.addProduct(Product(
                      name: name,
                      stockQuantity: qty,
                      unit: unit,
                      costPriceBif: cost,
                      sellingPriceBif: sell,
                      lowStockThreshold: threshold,
                      createdAt: DateTime.now(),
                    ));
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isEdit ? 'Save Changes' : 'Add Product'),
            ),
          ],
        );
      },
    );
  }
}
