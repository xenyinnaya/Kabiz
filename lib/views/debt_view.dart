import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../models/debt.dart';
import '../models/customer.dart';
import '../widgets/stitch_debt_card.dart';
import '../widgets/stitch_empty_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class DebtView extends StatelessWidget {
  const DebtView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);
    final outstandingCount = provider.debts.where((d) => d['status'] != 'paid').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Debts Management'),
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
              _buildHeaderSection(context, outstandingCount),
              const SizedBox(height: AppSpacing.md),
              _buildSummaryCard(currency.format(provider.outstandingDebtsTotal)),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: provider.debts.isEmpty
                    ? StitchEmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'No debts recorded',
                        description: 'All customer balances are clear',
                        buttonText: 'Record Debt',
                        onButtonPressed: () => _showAddDebtDialog(context),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: provider.debts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final debt = provider.debts[index];
                          final isPaid = debt['status'] == 'paid';
                          return StitchDebtCard(
                            debt: debt,
                            onTap: isPaid ? null : () => _showDebtActions(context, debt),
                            onStatusUpdate: isPaid
                                ? null
                                : () => Provider.of<BusinessProvider>(context, listen: false)
                                    .updateDebt(debt['id'], 'paid'),
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
        onPressed: () => _showAddDebtDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, int outstandingCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debts',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Manage customer balances',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.errorContainer.withOpacity(0.4),
            borderRadius: AppRadius.borderRadiusXl,
          ),
          child: Text(
            '$outstandingCount Outstanding',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String formattedTotal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL OUTSTANDING',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.onPrimaryContainer.withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.onPrimary,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formattedTotal,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showDebtActions(BuildContext context, Map<String, dynamic> debtMap) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: const Icon(Icons.check, color: AppColors.onSecondaryContainer, size: 20),
                  ),
                  title: Text(
                    'Mark as Paid',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Update status of debt to paid',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  onTap: () {
                    Provider.of<BusinessProvider>(context, listen: false).updateDebt(debtMap['id'], 'paid');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    Customer? selectedCustomer;
    int amount = 0;
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final provider = Provider.of<BusinessProvider>(context, listen: false);
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
              title: Text(
                'Record New Debt',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Customer>(
                      decoration: const InputDecoration(labelText: 'Customer'),
                      items: provider.customers
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c.name,
                                  style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedCustomer = v),
                      validator: (v) => v == null ? 'Select customer' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                      decoration: const InputDecoration(labelText: 'Amount (BIF)'),
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid amount' : null,
                      onSaved: (v) => amount = int.parse(v!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: AppRadius.borderRadiusMd,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DUE DATE',
                                style: AppTypography.textTheme.labelLarge?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd').format(dueDate),
                                style: AppTypography.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: dueDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => dueDate = picked);
                            },
                            child: Text(
                              'Change',
                              style: AppTypography.textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTypography.textTheme.labelLarge?.copyWith(color: AppColors.outline),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      provider.addDebt(Debt(
                        customerId: selectedCustomer!.id!,
                        amountBif: amount,
                        dueDate: dueDate,
                        status: 'pending',
                        createdAt: DateTime.now(),
                      ));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size(120, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusButton,
                    ),
                  ),
                  child: const Text('Add Debt'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
