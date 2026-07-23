import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _buildKPIBentoGrid(provider, currency),
                    const SizedBox(height: AppSpacing.md),
                    _buildAIInsight(provider),
                    const SizedBox(height: AppSpacing.md),
                    _buildQuickActions(context),
                    const SizedBox(height: AppSpacing.lg),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin, vertical: AppSpacing.gutter),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
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
                      color: AppColors.primary,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: const Icon(Icons.bubble_chart, color: AppColors.onPrimary, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Kora AI',
                    style: AppTypography.textTheme.headlineLarge!.copyWith(color: AppColors.primary, fontSize: 20),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.person, color: AppColors.onPrimaryContainer, size: 20),
              )
            ],
          ),
          const SizedBox(height: AppSpacing.gutter),
          Text(
            'Mwaramutse, Business Owner 👋',
            style: AppTypography.textTheme.headlineSmall!.copyWith(color: AppColors.onSurface, fontSize: 16),
          ),
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: AppTypography.textTheme.labelLarge!.copyWith(color: AppColors.onSurfaceVariant),
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
      crossAxisSpacing: AppSpacing.gutter,
      mainAxisSpacing: AppSpacing.gutter,
      childAspectRatio: 1.5,
      children: [
        _buildKPICard("Sales", currency.format(provider.todaySalesTotal), "Today", Icons.trending_up, AppColors.primaryContainer, AppColors.onPrimaryContainer),
        _buildKPICard("Expenses", currency.format(provider.expensesThisMonthTotal), "This Month", Icons.account_balance_wallet, AppColors.secondaryContainer, AppColors.onSecondaryContainer),
        _buildKPICard("Debts", currency.format(provider.outstandingDebtsTotal), "Outstanding", Icons.assignment_late, AppColors.errorContainer, AppColors.onErrorContainer),
        _buildKPICard("Stock", "$lowStockCount items", "Low alerts", Icons.inventory_2, AppColors.tertiary, AppColors.onTertiary),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, String subtitle, IconData icon, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderRadiusLg,
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
              Text(title.toUpperCase(), style: AppTypography.textTheme.labelLarge!.copyWith(color: textColor.withOpacity(0.7), fontSize: 10)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: AppTypography.textTheme.bodyLarge!.copyWith(color: textColor, fontSize: 16)),
              ),
              Text(subtitle, style: AppTypography.textTheme.labelLarge!.copyWith(color: textColor.withOpacity(0.8), fontSize: 11)),
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
      padding: const EdgeInsets.all(AppSpacing.gutter),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.primaryContainer.withOpacity(0.3), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.gutter),
          Expanded(
            child: Text(
              insightText,
              style: AppTypography.textTheme.bodyMedium!.copyWith(color: AppColors.onSurfaceVariant, fontSize: 14),
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
      crossAxisSpacing: AppSpacing.gutter,
      mainAxisSpacing: AppSpacing.gutter,
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigate to Expense section to add expenses.')),
          );
        }),
        _buildActionButton(context, "Voice Sale", Icons.mic, true, () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice recording will be available soon. Please use AI Chat.')),
          );
        }),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, bool isPrimary, VoidCallback onTap) {
    return Material(
      color: isPrimary ? AppColors.primary : AppColors.surfaceContainerHigh,
      borderRadius: AppRadius.borderRadiusLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusLg,
        child: Container(
          decoration: BoxDecoration(
            border: isPrimary ? null : Border.all(color: AppColors.outlineVariant),
            borderRadius: AppRadius.borderRadiusLg,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Row(
            children: [
              Icon(icon, color: isPrimary ? AppColors.onPrimary : AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.textTheme.labelLarge!.copyWith(
                    color: isPrimary ? AppColors.onPrimary : AppColors.onSurface,
                    fontSize: 13,
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
            Text(
              'RECENT ACTIVITY',
              style: AppTypography.textTheme.labelLarge!.copyWith(color: AppColors.outline, fontSize: 12),
            ),
            TextButton(
              onPressed: () {}, 
              child: Text('View All', style: AppTypography.textTheme.labelLarge!.copyWith(color: AppColors.primary, fontSize: 12)),
            )
          ],
        ),
        if (provider.sales.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(child: Text("No recent sales.", style: AppTypography.textTheme.bodyMedium!.copyWith(color: AppColors.outline))),
          ),
        ...provider.sales.take(3).map((sale) {
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
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.gutter),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: AppRadius.borderRadiusSm),
                  child: const Icon(Icons.shopping_bag, color: AppColors.onSurfaceVariant, size: 18),
                ),
                const SizedBox(width: AppSpacing.gutter),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customerName, style: AppTypography.textTheme.bodyMedium!.copyWith(color: AppColors.onSurface)),
                      Text(formattedDate, style: AppTypography.textTheme.labelLarge!.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Text(
                  '+${currency.format(amount)}',
                  style: AppTypography.textTheme.bodyMedium!.copyWith(color: AppColors.secondary),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin, vertical: AppSpacing.sm),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/assistant');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.95),
            borderRadius: AppRadius.borderRadiusXl,
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 4), blurRadius: 12)
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(borderRadius: AppRadius.borderRadiusMd),
                child: const Icon(Icons.attach_file, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Ask Kora...', style: AppTypography.textTheme.bodyMedium!.copyWith(color: AppColors.outline)),
              ),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadius.borderRadiusMd),
                child: const Icon(Icons.send, color: AppColors.onPrimary, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
