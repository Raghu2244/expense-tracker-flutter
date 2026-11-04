import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

class ExpenseStorage {
  static const String _storageKey = 'expenses';

  // Save all expenses
  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();

    final String encodedData = jsonEncode(
      expenses.map((expense) => expense.toMap()).toList(),
    );

    await prefs.setString(_storageKey, encodedData);
  }

  // Load saved expenses
  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString(_storageKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData.map((item) {
      return Expense.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  // Delete all saved expenses
  Future<void> clearExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
