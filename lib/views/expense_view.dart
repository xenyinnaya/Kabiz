import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../models/expense.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class ExpenseView extends StatelessWidget {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses Track')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.edgeMargin),
        child: ListView.separated(
          itemCount: provider.expenses.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final exp = provider.expenses[index];
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.payment, color: AppColors.error),
                title: Text(exp.description, style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                subtitle: Text(exp.category, style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                trailing: Text(currency.format(exp.amountBif), style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.onError,
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add),
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
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
          title: Text('Add Expense', style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (v) => v!.isEmpty ? 'Enter description' : null,
                    onSaved: (v) => desc = v!,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    initialValue: cat,
                    decoration: const InputDecoration(labelText: 'Category (e.g. Rent)'),
                    onSaved: (v) => cat = v!,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount (BIF)'),
                    validator: (v) => int.tryParse(v!) == null ? 'Invalid amount' : null,
                    onSaved: (v) => amount = int.parse(v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text('Cancel', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.outline))
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
              child: const Text('Save Expense'),
            ),
          ],
        );
      }
    );
  }
}
