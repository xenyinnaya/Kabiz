import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('Record Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Customer Selection
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Customer>(
                  isExpanded: true,
                  hint: const Text('Select Customer (Optional)', style: TextStyle(color: Colors.white70)),
                  value: _selectedCustomer,
                  dropdownColor: const Color(0xFF2C2C2C),
                  items: provider.customers.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.name, style: const TextStyle(color: Colors.white)));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCustomer = val),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Items List
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButton<Product>(
                            isExpanded: true,
                            hint: const Text('Product'),
                            value: item.product,
                            dropdownColor: const Color(0xFF2C2C2C),
                            items: provider.products.map((p) {
                              return DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis));
                            }).toList(),
                            onChanged: (val) => setState(() => item.product = val),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                          icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
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
              icon: const Icon(Icons.add, color: Colors.amber),
              label: const Text('Add Another Product', style: TextStyle(color: Colors.amber)),
            ),
            
            const Divider(color: Colors.white24, height: 32),
            
            // Grand Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total:', style: TextStyle(color: Colors.white70, fontSize: 18)),
                Text(_currency.format(_grandTotal), style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                onPressed: _saveSale,
                child: const Text('Complete Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
  double quantity;
  _SaleItemEntry({this.product, this.quantity = 0});
}
