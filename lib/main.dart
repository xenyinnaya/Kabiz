import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/business_provider.dart';
import 'views/product_view.dart';
import 'views/debt_view.dart';
import 'views/expense_view.dart';
import 'views/assistant_view.dart';
import 'views/record_sale_view.dart';
import 'views/home_view.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => BusinessProvider(),
      child: const BujumburaBusinessApp(),
    ),
  );
}

class BujumburaBusinessApp extends StatelessWidget {
  const BujumburaBusinessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kora',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigationScreen(),
        '/record_sale': (context) => const RecordSaleView(),
        '/assistant': (context) => const AssistantView(),
        '/preview_home': (context) => const HomeView(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const HomeView(),
    const ProductView(),
    const DebtView(),
    const ExpenseView(),
    const AssistantView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on_outlined), activeIcon: Icon(Icons.monetization_on), label: 'Debts'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.assistant_outlined), activeIcon: Icon(Icons.assistant), label: 'Assistant'),
        ],
      ),
    );
  }
}
