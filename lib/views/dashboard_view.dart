import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../widgets/stat_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);
    final lowStockCount = provider.products.where((p) => p.stockQuantity <= p.lowStockThreshold).length;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('Bujumbura Assistant', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Muraho!', style: TextStyle(color: Colors.white54, fontSize: 14)),
              const Text('Business Dashboard', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(title: "Today's Sales", value: currency.format(provider.todaySalesTotal), icon: Icons.shopping_basket, gradientColors: const [Color(0xFF0D5C3A), Color(0xFF10B981)]),
                  StatCard(title: "Expenses (Month)", value: currency.format(provider.expensesThisMonthTotal), icon: Icons.receipt_long, gradientColors: const [Color(0xFF9E2A2B), Color(0xFFEF4444)]),
                  StatCard(title: "Outstanding Debts", value: currency.format(provider.outstandingDebtsTotal), icon: Icons.money_off, gradientColors: const [Color(0xFFB57C1E), Color(0xFFFFB300)]),
                  StatCard(title: "Low Stock Items", value: "$lowStockCount Alerts", icon: Icons.warning_amber, gradientColors: lowStockCount > 0 ? const [Color(0xFFB45309), Color(0xFFF59E0B)] : const [Color(0xFF374151), Color(0xFF4B5563)]),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    foregroundColor: const Color(0xFF121212),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/record_sale'),
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  label: const Text('Record New Sale Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),

              if (lowStockCount > 0) ...[
                const Text('Urgent Stock Warnings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: provider.products
                        .where((p) => p.stockQuantity <= p.lowStockThreshold)
                        .map((p) => ListTile(
                              leading: const Icon(Icons.warning_amber, color: Colors.orangeAccent),
                              title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text("Only ${p.stockQuantity} ${p.unit} left. Threshold: ${p.lowStockThreshold} ${p.unit}"),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
