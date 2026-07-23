import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../widgets/stat_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final lowStockCount = provider.products.where((p) => p.stockQuantity <= p.lowStockThreshold).length;

    return Scaffold(
      appBar: AppBar(title: const Text('BizMate AI')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.edgeMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Muraho!', style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant)),
              Text('Business Dashboard', style: textTheme.headlineMedium?.copyWith(color: AppColors.onSurface)),
              const SizedBox(height: AppSpacing.lg),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.gutter,
                mainAxisSpacing: AppSpacing.gutter,
                childAspectRatio: 1.4,
                children: [
                  StatCard(title: "Today's Sales", value: currency.format(provider.todaySalesTotal), icon: Icons.shopping_basket),
                  StatCard(title: "Expenses (Month)", value: currency.format(provider.expensesThisMonthTotal), icon: Icons.receipt_long),
                  StatCard(title: "Outstanding Debts", value: currency.format(provider.outstandingDebtsTotal), icon: Icons.money_off),
                  StatCard(title: "Low Stock Items", value: "$lowStockCount Alerts", icon: Icons.warning_amber),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/record_sale'),
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  label: const Text('Record New Sale Now'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (lowStockCount > 0) ...[
                Text('Urgent Stock Warnings', style: textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer, 
                    borderRadius: AppRadius.borderRadiusLg,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.products.where((p) => p.stockQuantity <= p.lowStockThreshold).length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final p = provider.products.where((p) => p.stockQuantity <= p.lowStockThreshold).elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.warning_amber, color: AppColors.error),
                        title: Text(p.name, style: textTheme.bodyLarge?.copyWith(color: AppColors.onErrorContainer, fontWeight: FontWeight.bold)),
                        subtitle: Text("Only ${p.stockQuantity} ${p.unit} left. Threshold: ${p.lowStockThreshold} ${p.unit}", style: textTheme.bodyMedium?.copyWith(color: AppColors.onErrorContainer)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
