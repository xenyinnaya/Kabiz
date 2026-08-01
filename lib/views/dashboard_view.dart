import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../widgets/stitch_stat_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);
    final lowStockCount = provider.products.where((p) => p.stockQuantity <= p.lowStockThreshold).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BizMate AI Dashboard'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.edgeMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryGrid(provider, currency, lowStockCount),
                    const SizedBox(height: AppSpacing.lg),
                    _buildQuickActionCTA(context),
                    const SizedBox(height: AppSpacing.lg),
                    if (lowStockCount > 0) ...[
                      _buildStockWarningsSection(context, provider),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    _buildActivitySection(context, provider, currency),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin, vertical: AppSpacing.gutter),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mwaramutse, Business Owner 👋',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.3),
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: const Icon(Icons.analytics, color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(BusinessProvider provider, NumberFormat currency, int lowStockCount) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.gutter,
      mainAxisSpacing: AppSpacing.gutter,
      childAspectRatio: 1.4,
      children: [
        StitchStatCard(
          title: "Sales Today",
          value: currency.format(provider.todaySalesTotal),
          icon: Icons.trending_up,
          color: AppColors.primary,
          subtitle: "Today's Total",
        ),
        StitchStatCard(
          title: "Outstanding Debt",
          value: currency.format(provider.outstandingDebtsTotal),
          icon: Icons.assignment_late,
          color: AppColors.error,
          subtitle: "Pending Collection",
        ),
        StitchStatCard(
          title: "Monthly Expenses",
          value: currency.format(provider.expensesThisMonthTotal),
          icon: Icons.account_balance_wallet,
          color: AppColors.secondary,
          subtitle: "This Month",
        ),
        StitchStatCard(
          title: "Low Stock Items",
          value: "$lowStockCount Alerts",
          icon: Icons.inventory_2,
          color: AppColors.tertiary,
          subtitle: "Reorder Warnings",
        ),
      ],
    );
  }

  Widget _buildQuickActionCTA(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/record_sale'),
        icon: const Icon(Icons.add_shopping_cart, size: 22, color: AppColors.onPrimary),
        label: Text(
          'Record New Sale Now',
          style: AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.onPrimary,
            fontSize: 15,
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
          shadowColor: AppColors.primary.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildStockWarningsSection(BuildContext context, BusinessProvider provider) {
    final lowStockItems = provider.products.where((p) => p.stockQuantity <= p.lowStockThreshold).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'URGENT STOCK WARNINGS',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Text(
                '${lowStockItems.length} Low',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.errorContainer.withOpacity(0.3),
            borderRadius: AppRadius.borderRadiusLg,
            border: Border.all(color: AppColors.errorContainer),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lowStockItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final p = lowStockItems[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: const Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.gutter),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: AppTypography.textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Threshold: ${p.lowStockThreshold} ${p.unit}',
                            style: AppTypography.textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: Text(
                        '${p.stockQuantity} ${p.unit}',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection(BuildContext context, BusinessProvider provider, NumberFormat currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ACTIVITY',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.outline,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/record_sale');
              },
              child: Text(
                'New Sale',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (provider.sales.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderRadiusLg,
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                const Icon(Icons.history, color: AppColors.outline, size: 32),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "No recent transactions recorded.",
                  style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.outline),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.sales.take(5).length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final sale = provider.sales[index];
              final amount = sale['total_amount_bif'];
              final dateStr = sale['created_at'];
              final customerName = sale['customer_name'] ?? 'Walk-in Customer';

              DateTime parsedDate;
              try {
                parsedDate = DateTime.parse(dateStr);
              } catch (e) {
                parsedDate = DateTime.now();
              }
              final formattedDate = DateFormat('MMM d, h:mm a').format(parsedDate);

              return Container(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withOpacity(0.4),
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: const Icon(Icons.shopping_bag, color: AppColors.secondary, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.gutter),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${currency.format(amount)}',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
