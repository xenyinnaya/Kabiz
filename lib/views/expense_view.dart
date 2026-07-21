import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../models/expense.dart';

class ExpenseView extends StatelessWidget {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('Expenses Track')),
      body: ListView.builder(
        itemCount: provider.expenses.length,
        itemBuilder: (context, index) {
          final exp = provider.expenses[index];
          return ListTile(
            leading: const Icon(Icons.payment, color: Colors.redAccent),
            title: Text(exp.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(exp.category),
            trailing: Text(currency.format(exp.amountBif), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
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
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Add Expense', style: TextStyle(color: Colors.white)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.redAccent)),
                  validator: (v) => v!.isEmpty ? 'Enter description' : null,
                  onSaved: (v) => desc = v!,
                ),
                TextFormField(
                  initialValue: cat,
                  decoration: const InputDecoration(labelText: 'Category (e.g. Rent)', labelStyle: TextStyle(color: Colors.redAccent)),
                  onSaved: (v) => cat = v!,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (BIF)', labelStyle: TextStyle(color: Colors.redAccent)),
                  validator: (v) => int.tryParse(v!) == null ? 'Invalid amount' : null,
                  onSaved: (v) => amount = int.parse(v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
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
