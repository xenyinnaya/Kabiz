import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/expense.dart';
import '../models/debt.dart';
import '../models/inventory_transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'bujumbura_business.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE inventory_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          quantity REAL NOT NULL,
          reference_id INTEGER,
          note TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY(product_id) REFERENCES products(id)
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        stock_quantity REAL,
        unit TEXT,
        cost_price_bif INTEGER,
        selling_price_bif INTEGER,
        low_stock_threshold REAL,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        notes TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        total_amount_bif INTEGER,
        created_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL,
        unit_price_bif INTEGER,
        FOREIGN KEY (sale_id) REFERENCES sales (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        category TEXT,
        amount_bif INTEGER,
        expense_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        amount_bif INTEGER,
        due_date TEXT,
        status TEXT,
        created_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');
    
    // Seed data
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final seedProducts = [
      Product(name: "Fanta Orange", stockQuantity: 45.0, unit: "bottle", costPriceBif: 1200, sellingPriceBif: 1500, lowStockThreshold: 10.0, createdAt: DateTime.now()),
      Product(name: "Coca-Cola", stockQuantity: 8.0, unit: "bottle", costPriceBif: 1200, sellingPriceBif: 1500, lowStockThreshold: 10.0, createdAt: DateTime.now()),
      Product(name: "Sugar (Imported)", stockQuantity: 120.0, unit: "kg", costPriceBif: 2800, sellingPriceBif: 3500, lowStockThreshold: 20.0, createdAt: DateTime.now()),
      Product(name: "Primus Beer", stockQuantity: 24.5, unit: "bottle", costPriceBif: 2200, sellingPriceBif: 2800, lowStockThreshold: 5.0, createdAt: DateTime.now()),
    ];
    for (var p in seedProducts) {
      await db.insert('products', p.toMap());
    }

    final seedCustomers = [
      Customer(name: "Jean Nkurunziza", phone: "+257 79 123 456", notes: "Regular buyer", createdAt: DateTime.now()),
      Customer(name: "Marie Kamikazi", phone: "+257 61 789 012", notes: "Prefers morning pickups", createdAt: DateTime.now()),
    ];
    for (var c in seedCustomers) {
      await db.insert('customers', c.toMap());
    }

    final seedDebts = [
      Debt(customerId: 1, amountBif: 25000, dueDate: DateTime.now().add(const Duration(days: 3)), status: 'pending', createdAt: DateTime.now()),
      Debt(customerId: 2, amountBif: 45000, dueDate: DateTime.now().subtract(const Duration(days: 1)), status: 'overdue', createdAt: DateTime.now()),
    ];
    for (var d in seedDebts) {
      await db.insert('debts', d.toMap());
    }

    final seedExpenses = [
      Expense(description: "Store Rent", category: "Rent", amountBif: 150000, expenseDate: DateTime.now()),
      Expense(description: "Transport of Sugar", category: "Transport", amountBif: 35000, expenseDate: DateTime.now()),
    ];
    for (var e in seedExpenses) {
      await db.insert('expenses', e.toMap());
    }
  }

  // PRODUCTS
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }
  
  Future<int> insertProduct(Product p) async {
    final db = await database;
    return await db.insert('products', p.toMap());
  }

  Future<int> updateProduct(Product p) async {
    final db = await database;
    return await db.update('products', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // CUSTOMERS
  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final maps = await db.query('customers');
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<int> insertCustomer(Customer c) async {
    final db = await database;
    return await db.insert('customers', c.toMap());
  }

  // INVENTORY TRANSACTIONS
  Future<int> insertInventoryTransaction(InventoryTransaction transaction) async {
    final db = await database;
    return await db.insert('inventory_transactions', transaction.toMap());
  }

  Future<List<InventoryTransaction>> getInventoryTransactions(int productId) async {
    final db = await database;
    final maps = await db.query(
      'inventory_transactions',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
    return List.generate(
      maps.length,
      (index) => InventoryTransaction.fromMap(maps[index]),
    );
  }

  // SALES
  Future<int> insertSale(Sale sale, List<SaleItem> items) async {
    final db = await database;
    int saleId = 0;
    await db.transaction((txn) async {
      saleId = await txn.insert('sales', sale.toMap());
      for (var item in items) {
        var itemMap = item.toMap();
        itemMap['sale_id'] = saleId;
        await txn.insert('sale_items', itemMap);

        // Update product stock
        final productMaps = await txn.query('products', where: 'id = ?', whereArgs: [item.productId]);
        if (productMaps.isNotEmpty) {
          final p = Product.fromMap(productMaps.first);
          final newStock = (p.stockQuantity - item.quantity);
          await txn.update('products', {'stock_quantity': newStock < 0 ? 0 : newStock}, where: 'id = ?', whereArgs: [p.id]);
        }
        
        await txn.insert(
          'inventory_transactions',
          {
            'product_id': item.productId,
            'type': 'sale',
            'quantity': item.quantity,
            'reference_id': saleId,
            'note': 'Sale transaction',
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      }
    });
    return saleId;
  }

  Future<List<Map<String, dynamic>>> getAllSalesWithCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT s.id, s.total_amount_bif, s.created_at, c.name as customer_name, c.phone as customer_phone
      FROM sales s
      LEFT JOIN customers c ON s.customer_id = c.id
      ORDER BY s.created_at DESC
    ''');
    return result;
  }

  // EXPENSES
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'expense_date DESC');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<int> insertExpense(Expense e) async {
    final db = await database;
    return await db.insert('expenses', e.toMap());
  }

  // DEBTS
  Future<List<Map<String, dynamic>>> getAllDebtsWithCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT d.id, d.amount_bif, d.due_date, d.status, d.created_at, 
             c.id as customer_id, c.name as customer_name, c.phone as customer_phone
      FROM debts d
      LEFT JOIN customers c ON d.customer_id = c.id
      ORDER BY d.due_date ASC
    ''');
    return result;
  }

  Future<int> insertDebt(Debt d) async {
    final db = await database;
    return await db.insert('debts', d.toMap());
  }

  Future<int> updateDebtStatus(int id, String status) async {
    final db = await database;
    return await db.update('debts', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  // METRICS
  Future<int> getTodaySalesTotal() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery("SELECT SUM(total_amount_bif) as total FROM sales WHERE created_at LIKE '$today%'");
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> getExpensesThisMonthTotal() async {
    final db = await database;
    final month = DateTime.now().toIso8601String().substring(0, 7);
    final result = await db.rawQuery("SELECT SUM(amount_bif) as total FROM expenses WHERE expense_date LIKE '$month%'");
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> getOutstandingDebtsTotal() async {
    final db = await database;
    final result = await db.rawQuery("SELECT SUM(amount_bif) as total FROM debts WHERE status IN ('pending', 'partial', 'overdue')");
    return (result.first['total'] as int?) ?? 0;
  }
}
