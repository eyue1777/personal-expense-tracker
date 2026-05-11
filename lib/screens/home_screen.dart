import 'package:flutter/material.dart';
import '../services/expenses_db.dart';
import '../services/prefs_service.dart';
import '../models/expense.dart';
import 'expense_form.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _list = [];
  double _total = 0;
  String _curr = 'USD';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    final list = await ExpensesDb.instance.getAllExpenses();
    final total = await ExpensesDb.instance.getMonthlyTotal();
    final curr = await PrefsService().getCurrency();
    setState(() {
      _list = list;
      _total = total;
      _curr = curr;
    });
  }

  IconData _getIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // THEME AWARE
      appBar: AppBar(
        title: Text(
          'MyMoney',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              _refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card (Gradients work in both modes)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.indigo, Colors.indigoAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Monthly Spending",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_curr ${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transactions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text("View All")),
              ],
            ),
          ),

          Expanded(
            child: _list.isEmpty
                ? Center(
                    child: Text(
                      "No expenses yet",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _list.length,
                    itemBuilder: (context, i) {
                      final item = _list[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey[900]
                              : Colors.grey[100], // THEME AWARE
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIcon(item.category),
                              color: Colors.indigoAccent,
                            ),
                          ),
                          title: Text(
                            item.category,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            item.note,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          trailing: Text(
                            '- $_curr${item.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () async {
                            if (await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ExpenseForm(existingExpense: item),
                                  ),
                                ) ==
                                true)
                              _refresh();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        onPressed: () async {
          if (await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpenseForm()),
              ) ==
              true)
            _refresh();
        },
        label: const Text(
          "Add Expense",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
