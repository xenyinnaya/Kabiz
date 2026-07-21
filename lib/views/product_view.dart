import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../models/product.dart';

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
    final filtered = provider.products.where((p) => p.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('Product Inventory')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (c, i) => const Divider(color: Colors.white10),
                itemBuilder: (c, i) {
                  final p = filtered[i];
                  final isLow = p.stockQuantity <= p.lowStockThreshold;
                  return ListTile(
                    leading: Icon(Icons.inventory_2, color: isLow ? Colors.redAccent : Colors.amber),
                    title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("Cost: ${currency.format(p.costPriceBif)} | Sell: ${currency.format(p.sellingPriceBif)}"),
                    trailing: Text("${p.stockQuantity} ${p.unit}", style: TextStyle(color: isLow ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold)),
                    onTap: () => _showAddProductDialog(context, product: p),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: const Color(0xFF121212),
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
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(isEdit ? 'Edit Product' : 'Add Product', style: const TextStyle(color: Colors.white)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.amber)),
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    onSaved: (v) => name = v!,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: isEdit ? qty.toString() : '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Stock Qty', labelStyle: TextStyle(color: Colors.amber)),
                          validator: (v) => double.tryParse(v!) == null ? 'Number required' : null,
                          onSaved: (v) => qty = double.parse(v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: unit,
                          decoration: const InputDecoration(labelText: 'Unit (e.g., kg)', labelStyle: TextStyle(color: Colors.amber)),
                          validator: (v) => v!.isEmpty ? 'Unit required' : null,
                          onSaved: (v) => unit = v!,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: isEdit ? cost.toString() : '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cost Price (BIF)', labelStyle: TextStyle(color: Colors.amber)),
                          validator: (v) => int.tryParse(v!) == null ? 'Integer required' : null,
                          onSaved: (v) => cost = int.parse(v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: isEdit ? sell.toString() : '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Selling Price (BIF)', labelStyle: TextStyle(color: Colors.amber)),
                          validator: (v) => int.tryParse(v!) == null ? 'Integer required' : null,
                          onSaved: (v) => sell = int.parse(v!),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    initialValue: isEdit ? threshold.toString() : '5.0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Low Stock Threshold', labelStyle: TextStyle(color: Colors.amber)),
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
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
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
