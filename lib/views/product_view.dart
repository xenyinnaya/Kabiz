import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/business_provider.dart';
import '../models/product.dart';
import '../widgets/stitch_product_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

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
    final provider = Provider.of<BusinessProvider>(context);
    final filtered = provider.products.where((p) => p.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              _buildHeaderSection(context, provider.products.length, filtered.length),
              const SizedBox(height: AppSpacing.md),
              _buildSearchField(),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filtered.length,
                        separatorBuilder: (c, i) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (c, i) {
                          final p = filtered[i];
                          return StitchProductCard(
                            product: p,
                            onTap: () => _showAddProductDialog(context, product: p),
                            onEdit: () => _showAddProductDialog(context, product: p),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: const CircleBorder(),
        elevation: 3,
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, int totalCount, int filteredCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Items',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Manage products, prices & stock levels',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withOpacity(0.3),
            borderRadius: AppRadius.borderRadiusXl,
          ),
          child: Text(
            '$filteredCount of $totalCount',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _search,
      onChanged: (v) => setState(() => _query = v),
      style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: 'Search products by name...',
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.outline),
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.outline),
                onPressed: () {
                  _search.clear();
                  setState(() => _query = '');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusLg,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.sm),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isSearching = _query.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: AppRadius.borderRadiusXl,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.outline,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isSearching ? 'No matching products found' : 'No products in inventory yet',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isSearching
                    ? 'Try searching with a different keyword or clear the search bar.'
                    : 'Tap the button below to add your first product to the catalog.',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () => _showAddProductDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Product Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                ),
              ),
            ],
          ),
        ),
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
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
          title: Text(
            isEdit ? 'Edit Product' : 'Add Product',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter product name' : null,
                    onSaved: (v) => name = v!.trim(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: isEdit ? qty.toString() : '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                          decoration: const InputDecoration(labelText: 'Stock Qty'),
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Number required' : null,
                          onSaved: (v) => qty = double.parse(v!),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextFormField(
                          initialValue: unit,
                          style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                          decoration: const InputDecoration(labelText: 'Unit (e.g., kg, bottle)'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Unit required' : null,
                          onSaved: (v) => unit = v!.trim(),
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
                          style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                          decoration: const InputDecoration(labelText: 'Cost Price (BIF)'),
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Integer required' : null,
                          onSaved: (v) => cost = int.parse(v!),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextFormField(
                          initialValue: isEdit ? sell.toString() : '',
                          keyboardType: TextInputType.number,
                          style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                          decoration: const InputDecoration(labelText: 'Selling Price (BIF)'),
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Integer required' : null,
                          onSaved: (v) => sell = int.parse(v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    initialValue: isEdit ? threshold.toString() : '5.0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                    decoration: const InputDecoration(labelText: 'Low Stock Alert Threshold'),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Number required' : null,
                    onSaved: (v) => threshold = double.parse(v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTypography.textTheme.labelLarge?.copyWith(color: AppColors.outline)),
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
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 44),
              ),
              child: Text(isEdit ? 'Save Changes' : 'Add Product'),
            ),
          ],
        );
      },
    );
  }
}
