import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../models/expense.dart';
import '../widgets/stitch_expense_card.dart';
import '../widgets/stitch_empty_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ExpenseView extends StatelessWidget {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Expenses Track'),
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
              _buildHeaderSection(context, provider.expenses.length),
              const SizedBox(height: AppSpacing.md),
              _buildSummaryCard(currency.format(provider.expensesThisMonthTotal)),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: provider.expenses.isEmpty
                    ? StitchEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No expenses yet',
                        description: 'Track your business spending easily',
                        buttonText: 'Add Expense',
                        onButtonPressed: () => _showAddExpenseDialog(context),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: provider.expenses.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final exp = provider.expenses[index];
                          return StitchExpenseCard(
                            expense: exp,
                            onTap: () {},
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
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Track your business spending',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
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
            '$count Expenses',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String formattedMonthlyTotal) {
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
                'THIS MONTH',
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
                  Icons.calendar_today_outlined,
                  color: AppColors.onPrimary,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formattedMonthlyTotal,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String desc = '';
    String cat = 'Operations';
    int amount = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
          title: Text(
            'Add Expense',
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
                    style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter description' : null,
                    onSaved: (v) => desc = v!.trim(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    initialValue: cat,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                    decoration: const InputDecoration(labelText: 'Category (e.g. Rent)'),
                    onSaved: (v) => cat = v!.trim(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                    decoration: const InputDecoration(labelText: 'Amount (BIF)'),
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid amount' : null,
                    onSaved: (v) => amount = int.parse(v!),
                  ),
                ],
              ),
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
                  Provider.of<BusinessProvider>(context, listen: false).addExpense(Expense(
                    description: desc,
                    category: cat,
                    amountBif: amount,
                    expenseDate: DateTime.now(),
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
              child: const Text('Save Expense'),
            ),
          ],
        );
      },
    );
  }
}
