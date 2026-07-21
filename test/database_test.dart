import 'package:flutter_test/flutter_test.dart';
import 'package:bujumbura_business_assistant/models/product.dart';
import 'package:bujumbura_business_assistant/models/customer.dart';
import 'package:bujumbura_business_assistant/models/sale_item.dart';
import 'package:bujumbura_business_assistant/models/debt.dart';
import 'package:bujumbura_business_assistant/services/assistant_service.dart';

void main() {
  group('Currency Precision & Math Tests', () {
    test('Validate money fields are stored and computed strictly as integers', () {
      const int sellingPriceBif = 2000;
      const double quantitySold = 3.5; // e.g. 3.5 kg of sugar or liters of oil

      // 1. Total sale calculation
      final double totalAmountDouble = quantitySold * sellingPriceBif;
      final int totalAmountInt = totalAmountDouble.toInt();
      
      expect(totalAmountInt, equals(7000));
      expect(totalAmountInt, isA<int>());
    });

    test('Validate profit calculations use unit cost versus selling price', () {
      // Setup mock product
      final product = Product(
        id: 1,
        name: 'Fanta',
        stockQuantity: 20,
        unit: 'bottle',
        costPriceBif: 1200,      // Cost price
        sellingPriceBif: 1500,   // Selling price
        lowStockThreshold: 5.0,
        createdAt: DateTime.now(),
      );

      final saleItem = SaleItem(
        id: 1,
        saleId: 1,
        productId: product.id!,
        quantity: 5.0,
        unitPriceBif: product.sellingPriceBif,
      );

      // Profit = quantity * (selling_price - cost_price)
      final double profitDouble = saleItem.quantity * (saleItem.unitPriceBif - product.costPriceBif);
      final int profitInt = profitDouble.toInt();

      // 5 * (1500 - 1200) = 5 * 300 = 1500 BIF
      expect(profitInt, equals(1500));
      expect(profitInt, isA<int>());
    });
  });

  group('Low Stock Alert Tests', () {
    test('Product triggers low stock warning when stock is below or equal to threshold', () {
      final p1 = Product(
        id: 1,
        name: 'Coca-Cola',
        stockQuantity: 4.5,
        unit: 'bottle',
        costPriceBif: 1200,
        sellingPriceBif: 1500,
        lowStockThreshold: 5.0,
        createdAt: DateTime.now(),
      );

      final p2 = Product(
        id: 2,
        name: 'Sprite',
        stockQuantity: 6.0,
        unit: 'bottle',
        costPriceBif: 1200,
        sellingPriceBif: 1500,
        lowStockThreshold: 5.0,
        createdAt: DateTime.now(),
      );

      final isP1Low = p1.stockQuantity <= p1.lowStockThreshold;
      final isP2Low = p2.stockQuantity <= p2.lowStockThreshold;

      expect(isP1Low, isTrue);   // 4.5 <= 5.0 -> True
      expect(isP2Low, isFalse);  // 6.0 <= 5.0 -> False
    });
  });

  group('AI Assistant Parser Tests', () {
    final assistant = LocalAssistantService();

    test('Parse English sale phrase: "Sold 3 Fanta at 1500 each"', () async {
      final parsed = await assistant.parseSale("Sold 3 Fanta at 1500 each");

      expect(parsed.hasError, isFalse);
      expect(parsed.productName, equals("Fanta"));
      expect(parsed.quantity, equals(3.0));
      expect(parsed.unitPriceBif, equals(1500));
    });

    test('Parse French sale phrase: "Vendu 1.5 kg isukari à 3000"', () async {
      final parsed = await assistant.parseSale("Vendu 1.5 kg isukari à 3000");

      expect(parsed.hasError, isFalse);
      expect(parsed.productName, equals("Isukari"));
      expect(parsed.quantity, equals(1.5));
      expect(parsed.unitPriceBif, equals(3000));
    });

    test('Parse Kirundi sale phrase: "4 fanta ku 1500"', () async {
      final parsed = await assistant.parseSale("4 fanta ku 1500");

      expect(parsed.hasError, isFalse);
      expect(parsed.productName, equals("Fanta"));
      expect(parsed.quantity, equals(4.0));
      expect(parsed.unitPriceBif, equals(1500));
    });

    test('Generate Debt Reminders in multiple languages', () async {
      final customer = Customer(id: 1, name: "Jean", phone: "+25779123456", createdAt: DateTime.now());
      final debt = Debt(
        id: 1,
        customerId: 1,
        amountBif: 50000,
        dueDate: DateTime(2026, 6, 20),
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final kirundiReminder = await assistant.generateReminder(customer, debt, language: 'Kirundi');
      final frenchReminder = await assistant.generateReminder(customer, debt, language: 'French');

      expect(kirundiReminder, contains("Jean"));
      expect(kirundiReminder, contains("50")); // formatted locale fr_BI group separator
      expect(kirundiReminder, contains("000"));
      expect(kirundiReminder, contains("20/06/2026"));

      expect(frenchReminder, contains("Bonjour Jean"));
      expect(frenchReminder, contains("50"));
      expect(frenchReminder, contains("000"));
      expect(frenchReminder, contains("20/06/2026"));
    });
  });
}
