import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Match Stitch background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildKPIBentoGrid(provider, currency),
                    const SizedBox(height: 16),
                    _buildAIInsight(provider),
                    const SizedBox(height: 16),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildRecentActivity(context, provider, currency),
                    const SizedBox(height: 80), // Space for bottom bar
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAIFloatingBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF004D99), // Primary
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bubble_chart, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kora AI',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF004D99),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF1565C0),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              )
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Mwaramutse, Business Owner 👋',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF1A1C1C),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF424752),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIBentoGrid(BusinessProvider provider, NumberFormat currency) {
    final lowStockCount = provider.products.where((p) => p.stockQuantity <= p.lowStockThreshold).length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildKPICard("Sales", currency.format(provider.todaySalesTotal), "Today", Icons.trending_up, const Color(0xFF1565C0), const Color(0xFFDAE5FF)),
        _buildKPICard("Expenses", currency.format(provider.expensesThisMonthTotal), "This Month", Icons.account_balance_wallet, const Color(0xFFA0F399), const Color(0xFF217128)),
        _buildKPICard("Debts", currency.format(provider.outstandingDebtsTotal), "Outstanding", Icons.assignment_late, const Color(0xFFFFDAD6), const Color(0xFF93000A)),
        _buildKPICard("Stock", "$lowStockCount items", "Low alerts", Icons.inventory_2, const Color(0xFF00575F), Colors.white),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, String subtitle, IconData icon, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), offset: const Offset(0, 4), blurRadius: 4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: textColor.withOpacity(0.8), size: 18),
              Text(title.toUpperCase(), style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
              ),
              Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11, fontFamily: 'Inter')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsight(BusinessProvider provider) {
    String insightText = "Kora AI: Your business is performing well today.";
    
    // Priority 1: Overdue Debts
    final overdueDebts = provider.debts.where((d) {
      final status = d['status'];
      final dueDate = DateTime.parse(d['due_date']);
      return status != 'paid' && dueDate.isBefore(DateTime.now());
    }).length;
    
    // Priority 2: Low Stock
    final lowStockCount = provider.products.where((p) => p.stockQuantity <= p.lowStockThreshold).length;

    if (overdueDebts > 0) {
      insightText = "Insight: You have $overdueDebts customer(s) with overdue payments.";
    } else if (lowStockCount > 0) {
      insightText = "Insight: $lowStockCount products are running low. Check your inventory.";
    } else if (provider.todaySalesTotal > 0) {
      insightText = "Insight: Great job! Sales are active today.";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC2C6D4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF004D99).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF004D99), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insightText,
              style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF424752), fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.8,
      children: [
        _buildActionButton(context, "Record Sale", Icons.add_shopping_cart, false, () {
          Navigator.pushNamed(context, '/record_sale');
        }),
        _buildActionButton(context, "Scan Receipt", Icons.receipt_long, false, () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt scanning will be available soon.')),
          );
        }),
        _buildActionButton(context, "Add Expense", Icons.payments, false, () {
          // Placeholder action for Add Expense from dashboard
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigate to Expense section to add expenses.')),
          );
        }),
        _buildActionButton(context, "Voice Sale", Icons.mic, true, () {
          // Future functionality, open assistant
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice recording will be available soon. Please use AI Chat.')),
          );
        }),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, bool isPrimary, VoidCallback onTap) {
    return Material(
      color: isPrimary ? const Color(0xFF004D99) : const Color(0xFFF3F3F3),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: isPrimary ? null : Border.all(color: const Color(0xFFC2C6D4)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: isPrimary ? Colors.white : const Color(0xFF004D99), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: isPrimary ? Colors.white : const Color(0xFF1A1C1C),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, BusinessProvider provider, NumberFormat currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RECENT ACTIVITY',
              style: TextStyle(color: Color(0xFF727783), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            TextButton(
              onPressed: () {}, // Future View All functionality
              child: const Text('View All', style: TextStyle(color: Color(0xFF004D99), fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        if (provider.sales.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text("No recent sales.", style: TextStyle(color: Colors.grey))),
          ),
        ...provider.sales.take(3).map((sale) {
          // sale keys: id, total_amount_bif, created_at, customer_name, customer_phone
          final amount = sale['total_amount_bif'];
          final dateStr = sale['created_at'];
          final customerName = sale['customer_name'] ?? 'Unknown Customer';
          
          DateTime parsedDate;
          try {
            parsedDate = DateTime.parse(dateStr);
          } catch(e) {
            parsedDate = DateTime.now();
          }
          final formattedDate = DateFormat('MMM d, h:mm a').format(parsedDate);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC2C6D4).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.shopping_bag, color: Color(0xFF424752), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1C1C))),
                      Text(formattedDate, style: const TextStyle(color: Color(0xFF424752), fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  '+${currency.format(amount)}',
                  style: const TextStyle(color: Color(0xFF1B6D24), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAIFloatingBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          // Find the MainNavigationScreen state to switch tabs, or push a route.
          // Since we want to preview it, let's just push a route to the existing AssistantView.
          Navigator.pushNamed(context, '/assistant');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF004D99).withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 4), blurRadius: 12)
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.attach_file, color: Color(0xFF004D99), size: 20),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Ask Kora...', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFF004D99), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.send, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
