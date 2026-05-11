import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expenses_db.dart';

class ExpenseForm extends StatefulWidget {
  final Expense? existingExpense;
  const ExpenseForm({super.key, this.existingExpense});
  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amtController, _noteController;
  String _selectedCategory = 'Food';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant_rounded},
    {'name': 'Transport', 'icon': Icons.directions_car_rounded},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded},
    {'name': 'Bills', 'icon': Icons.receipt_long_rounded},
    {'name': 'Entertainment', 'icon': Icons.confirmation_number_rounded},
    {'name': 'Health', 'icon': Icons.favorite_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _amtController = TextEditingController(
      text: widget.existingExpense?.amount.toString() ?? '',
    );
    _noteController = TextEditingController(
      text: widget.existingExpense?.note ?? '',
    );
    if (widget.existingExpense != null)
      _selectedCategory = widget.existingExpense!.category;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.existingExpense == null ? 'New Expense' : 'Edit Expense',
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Transaction Amount",
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                  controller: _amtController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.indigo,
                  ),
                  decoration: const InputDecoration(
                    prefixText: "\$",
                    hintText: "0.00",
                    border: InputBorder.none,
                  ),
                  validator: (v) =>
                      (v == null || double.tryParse(v) == null) ? '!' : null,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[900]
                      : Colors.grey[50], // THEME AWARE
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Category",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _categories.map((cat) {
                        bool isSelected = _selectedCategory == cat['name'];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat['name']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.indigo
                                  : (isDark ? Colors.black : Colors.white),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat['icon'],
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.indigo,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cat['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Notes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Add a description...",
                        filled: true,
                        fillColor: isDark
                            ? Colors.black
                            : Colors.white, // THEME AWARE
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: widget.existingExpense?.id,
        amount: double.parse(_amtController.text),
        category: _selectedCategory,
        note: _noteController.text,
        date: widget.existingExpense?.date ?? DateTime.now(),
      );
      widget.existingExpense == null
          ? await ExpensesDb.instance.insert(expense)
          : await ExpensesDb.instance.update(expense);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
}
