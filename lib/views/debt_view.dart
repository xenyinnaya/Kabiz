import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/business_provider.dart';
import '../models/debt.dart';
import '../models/customer.dart';

class DebtView extends StatelessWidget {
  const DebtView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');
    final provider = Provider.of<BusinessProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('Debts Management')),
      body: ListView.builder(
        itemCount: provider.debts.length,
        itemBuilder: (context, index) {
          final debt = provider.debts[index];
          final isPaid = debt['status'] == 'paid';
          return ListTile(
            leading: Icon(isPaid ? Icons.check_circle : Icons.money_off, color: isPaid ? Colors.green : Colors.orangeAccent),
            title: Text(debt['customer_name'] ?? 'Unknown', style: TextStyle(color: isPaid ? Colors.white54 : Colors.white, fontWeight: FontWeight.bold, decoration: isPaid ? TextDecoration.lineThrough : null)),
            subtitle: Text("Due: ${debt['due_date'].toString().substring(0, 10)}"),
            trailing: Text(currency.format(debt['amount_bif']), style: TextStyle(color: isPaid ? Colors.white54 : Colors.redAccent, fontWeight: FontWeight.bold, decoration: isPaid ? TextDecoration.lineThrough : null)),
            onTap: isPaid ? null : () => _showDebtActions(context, debt),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () => _showAddDebtDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDebtActions(BuildContext context, Map<String, dynamic> debtMap) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: const Text('Mark as Paid', style: TextStyle(color: Colors.white)),
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
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Record New Debt', style: TextStyle(color: Colors.white)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Customer>(
                      decoration: const InputDecoration(labelText: 'Customer', labelStyle: TextStyle(color: Colors.amber)),
                      dropdownColor: const Color(0xFF2C2C2C),
                      items: provider.customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (v) => setState(() => selectedCustomer = v),
                      validator: (v) => v == null ? 'Select customer' : null,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount (BIF)', labelStyle: TextStyle(color: Colors.amber)),
                      validator: (v) => int.tryParse(v!) == null ? 'Invalid amount' : null,
                      onSaved: (v) => amount = int.parse(v!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Due: ${DateFormat('yyyy-MM-dd').format(dueDate)}", style: const TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(context: context, initialDate: dueDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
                            if (picked != null) setState(() => dueDate = picked);
                          },
                          child: const Text('Change', style: TextStyle(color: Colors.amber)),
                        )
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
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
