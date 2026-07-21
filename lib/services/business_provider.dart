import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/expense.dart';
import '../models/debt.dart';
import '../database/database_helper.dart';
import 'assistant_service.dart';

class BusinessProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
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
    products = await _db.getAllProducts();
    customers = await _db.getAllCustomers();
    sales = await _db.getAllSalesWithCustomers();
    expenses = await _db.getAllExpenses();
    debts = await _db.getAllDebtsWithCustomers();

    todaySalesTotal = await _db.getTodaySalesTotal();
    expensesThisMonthTotal = await _db.getExpensesThisMonthTotal();
    outstandingDebtsTotal = await _db.getOutstandingDebtsTotal();
    notifyListeners();
  }

  Future<void> addProduct(Product p) async {
    await _db.insertProduct(p);
    await refreshData();
  }

  Future<void> updateProduct(Product p) async {
    await _db.updateProduct(p);
    await refreshData();
  }

  Future<void> deleteProduct(int id) async {
    await _db.deleteProduct(id);
    await refreshData();
  }

  Future<int> addCustomer(Customer c) async {
    final id = await _db.insertCustomer(c);
    await refreshData();
    return id;
  }

  Future<void> addSale(Sale sale, List<SaleItem> items) async {
    await _db.insertSale(sale, items);
    await refreshData();
  }

  Future<void> addExpense(Expense e) async {
    await _db.insertExpense(e);
    await refreshData();
  }

  Future<void> addDebt(Debt d) async {
    await _db.insertDebt(d);
    await refreshData();
  }

  Future<void> updateDebt(int debtId, String status) async {
    await _db.updateDebtStatus(debtId, status);
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
