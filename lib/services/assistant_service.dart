import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/debt.dart';
import '../database/database_helper.dart';

class ParsedSale {
  final String? productName;
  final double quantity;
  final int? unitPriceBif;
  final String? error;

  ParsedSale({this.productName, required this.quantity, this.unitPriceBif, this.error});
  bool get hasError => error != null;
}

abstract class AssistantService {
  Future<ParsedSale> parseSale(String text);
  Future<String> generateReminder(Customer customer, Debt debt, {String language = 'Kirundi'});
  Future<String> answerQuestion(String question, DatabaseHelper db);
}

class LocalAssistantService implements AssistantService {
  final NumberFormat _currencyFormatter = NumberFormat.currency(symbol: 'BIF ', decimalDigits: 0, locale: 'fr_BI');

  @override
  Future<ParsedSale> parseSale(String text) async {
    try {
      final cleanText = text.toLowerCase().trim();
      double qty = 1.0;
      int price = 0;
      String prodName = '';

      final regex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:bottles|bottle|kg|liter|liters|piece|pieces)?\s*([a-zA-Z\s\-]+?)\s*(?:at|à|ku|pour|each|par)\s*(\d+)');
      final match = regex.firstMatch(cleanText);

      if (match != null) {
        qty = double.parse(match.group(1)!);
        prodName = match.group(2)!.trim();
        price = int.parse(match.group(3)!);
      } else {
        final words = cleanText.split(' ');
        final numbers = words.map((w) => double.tryParse(w)).where((n) => n != null).map((n) => n!).toList();
        if (numbers.length >= 2) {
          qty = numbers[0];
          price = numbers[1].toInt();
          final prodWords = words.where((w) => double.tryParse(w) == null && w.length > 2 && w != 'sold' && w != 'vendu' && w != 'agurishije' && w != 'at' && w != 'each' && w != 'ku').toList();
          prodName = prodWords.isNotEmpty ? prodWords.join(' ') : 'Product';
        } else {
          return ParsedSale(quantity: 0, error: "Could not parse phrase. Example: '3 Fanta at 1500'");
        }
      }

      prodName = prodName.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ').trim();
      return ParsedSale(productName: prodName, quantity: qty, unitPriceBif: price);
    } catch (e) {
      return ParsedSale(quantity: 0, error: "Error parsing: $e");
    }
  }

  @override
  Future<String> generateReminder(Customer customer, Debt debt, {String language = 'Kirundi'}) async {
    final formattedAmount = _currencyFormatter.format(debt.amountBif);
    final formattedDueDate = DateFormat('dd/MM/yyyy').format(debt.dueDate);

    switch (language.toLowerCase()) {
      case 'kirundi':
        return "Yambu ${customer.name},\nUbu ni ubutumwa bukuremisha ku mwenda wanyu w'amafaranga $formattedAmount uteganyijwe kwishyurwa taliki $formattedDueDate. Murakoze cane!";
      case 'french':
        return "Bonjour ${customer.name},\nNous vous rappelons gentiment que votre solde de $formattedAmount reste impayé. La date d'échéance était le $formattedDueDate. Merci de régulariser.";
      case 'swahili':
        return "Jambo ${customer.name},\nKikumbusho cha kirafiki kuhusu deni lako la $formattedAmount linalopaswa kulipwa tarehe $formattedDueDate. Asante!";
      default:
        return "Hello ${customer.name},\nThis is a friendly reminder regarding your outstanding balance of $formattedAmount due on $formattedDueDate. Thank you!";
    }
  }

  @override
  Future<String> answerQuestion(String question, DatabaseHelper db) async {
    final q = question.toLowerCase();

    if (q.contains('sell') || q.contains('sale') || q.contains('vendu') || q.contains('agurishije')) {
      final total = await db.getTodaySalesTotal();
      return "Today's total sales: ${_currencyFormatter.format(total)}.";
    }

    if (q.contains('owe') || q.contains('debt') || q.contains('dette') || q.contains('ideni')) {
      final debts = (await db.getAllDebtsWithCustomers()).where((d) => d['status'] != 'paid').toList();
      if (debts.isEmpty) return "Nobody owes you money currently.";
      
      final buffer = StringBuffer("Outstanding debts:\n");
      int total = 0;
      for (var d in debts) {
        total += d['amount_bif'] as int;
        buffer.writeln("- ${d['customer_name']}: ${_currencyFormatter.format(d['amount_bif'])} (Due: ${d['due_date'].toString().substring(0, 10)})");
      }
      buffer.writeln("\nTotal debts: ${_currencyFormatter.format(total)}");
      return buffer.toString();
    }

    if (q.contains('low') || q.contains('stock') || q.contains('pénurie')) {
      final alerts = (await db.getAllProducts()).where((p) => p.stockQuantity <= p.lowStockThreshold).toList();
      if (alerts.isEmpty) return "All products have sufficient stock.";
      
      final buffer = StringBuffer("Low stock items:\n");
      for (var p in alerts) {
        buffer.writeln("- ${p.name}: ${p.stockQuantity} ${p.unit} left (Threshold: ${p.lowStockThreshold})");
      }
      return buffer.toString();
    }

    if (q.contains('expense') || q.contains('dépense')) {
      final total = await db.getExpensesThisMonthTotal();
      return "Recorded expenses this month: ${_currencyFormatter.format(total)}.";
    }

    return "Hello! I am your Kabiz Smart Assistant.\n\nYou can ask:\n- 'How much did I sell today?'\n- 'Who owes me money?'\n- 'Which products are low?'\n- 'What are my expenses this month?'";
  }
}
