import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../models/debt.dart';
import '../models/customer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class DebtView extends StatelessWidget {
  const DebtView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Debts Management')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.edgeMargin),
        child: ListView.separated(
          itemCount: provider.debts.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final debt = provider.debts[index];
            final isPaid = debt['status'] == 'paid';
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(isPaid ? Icons.check_circle : Icons.money_off, color: isPaid ? AppColors.secondary : AppColors.error),
                title: Text(debt['customer_name'] ?? 'Unknown', style: textTheme.bodyLarge?.copyWith(color: isPaid ? AppColors.onSurfaceVariant : AppColors.onSurface, fontWeight: FontWeight.bold, decoration: isPaid ? TextDecoration.lineThrough : null)),
                subtitle: Text("Due: ${debt['due_date'].toString().substring(0, 10)}", style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                trailing: Text(currency.format(debt['amount_bif']), style: textTheme.bodyLarge?.copyWith(color: isPaid ? AppColors.onSurfaceVariant : AppColors.error, fontWeight: FontWeight.bold, decoration: isPaid ? TextDecoration.lineThrough : null)),
                onTap: isPaid ? null : () => _showDebtActions(context, debt),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDebtActions(BuildContext context, Map<String, dynamic> debtMap) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check, color: AppColors.secondary),
                title: Text('Mark as Paid', style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface)),
                onTap: () {
                  Provider.of<BusinessProvider>(context, listen: false).updateDebt(debtMap['id'], 'paid');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
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
            final theme = Theme.of(context);
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
              title: Text('Record New Debt', style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Customer>(
                      decoration: const InputDecoration(labelText: 'Customer'),
                      items: provider.customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface)))).toList(),
                      onChanged: (v) => setState(() => selectedCustomer = v),
                      validator: (v) => v == null ? 'Select customer' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount (BIF)'),
                      validator: (v) => int.tryParse(v!) == null ? 'Invalid amount' : null,
                      onSaved: (v) => amount = int.parse(v!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Due: ${DateFormat('yyyy-MM-dd').format(dueDate)}", style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(context: context, initialDate: dueDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
                            if (picked != null) setState(() => dueDate = picked);
                          },
                          child: Text('Change', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                        )
                      ],
                    )
                  ],
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
                  child: const Text('Add Debt'),
                ),
              ],
            );
          }
        );
      }
    );
  }
}
