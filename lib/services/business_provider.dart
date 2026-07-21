import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/expense.dart';
import '../models/debt.dart';
import '../database/database_helper.dart';
import '../repositories/expense_repository.dart';
import '../repositories/debt_repository.dart';
import 'sales_service.dart';
import 'inventory_service.dart';
import 'customer_service.dart';
import 'assistant_service.dart';

class BusinessProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final InventoryService _inventoryService = InventoryService();
  final CustomerService _customerService = CustomerService();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final DebtRepository _debtRepository = DebtRepository();
  final SalesService _salesService = SalesService();
  final AssistantService _assistant = LocalAssistantService();

  List<Product> products = [];
  List<Customer> customers = [];
  List<Map<String, dynamic>> sales = [];
  List<Expense> expenses = [];
  List<Map<String, dynamic>> debts = [];

  int todaySalesTotal = 0;
  int expensesThisMonthTotal = 0;
  int outstandingDebtsTotal = 0;

  BusinessProvider() {
    refreshData();
  }

  Future<void> refreshData() async {
    products = await _inventoryService.getProducts();
    customers = await _customerService.getCustomers();
    sales = await _salesService.getSales();
    expenses = await _expenseRepository.getExpenses();
    debts = await _debtRepository.getDebtsWithCustomers();

    todaySalesTotal = await _db.getTodaySalesTotal();
    expensesThisMonthTotal = await _db.getExpensesThisMonthTotal();
    outstandingDebtsTotal = await _debtRepository.getOutstandingDebtsTotal();
    notifyListeners();
  }

  Future<void> addProduct(Product p) async {
    await _inventoryService.createProduct(p);
    await refreshData();
  }

  Future<void> updateProduct(Product p) async {
    await _inventoryService.updateProduct(p);
    await refreshData();
  }

  Future<void> deleteProduct(int id) async {
    await _inventoryService.deleteProduct(id);
    await refreshData();
  }

  Future<int> addCustomer(Customer c) async {
    final id = await _customerService.createCustomer(c);
    await refreshData();
    return id;
  }

  Future<void> addSale(Sale sale, List<SaleItem> items) async {
    await _salesService.createSale(sale, items);
    await refreshData();
  }

  Future<void> addExpense(Expense e) async {
    await _expenseRepository.createExpense(e);
    await refreshData();
  }

  Future<void> addDebt(Debt d) async {
    await _debtRepository.createDebt(d);
    await refreshData();
  }

  Future<void> updateDebt(int debtId, String status) async {
    await _debtRepository.updateDebtStatus(debtId, status);
    await refreshData();
  }

  Future<ParsedSale> parseVoiceSale(String text) async {
    return await _assistant.parseSale(text);
  }

  Future<String> askAssistant(String question) async {
    return await _assistant.answerQuestion(question, _db);
  }

  Future<String> generateDebtReminder(Customer customer, Debt debt, String lang) async {
    return await _assistant.generateReminder(customer, debt, language: lang);
  }
}
