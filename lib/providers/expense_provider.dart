import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_storage.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseStorage _storage = ExpenseStorage();

  List<Expense> _expenses = [];

  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => List.unmodifiable(_expenses);

  bool get isLoading => _isLoading;

  String? get error => _error;

  // Calculate total income
  double get totalIncome {
    return _expenses
        .where((expense) => expense.isIncome)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Calculate total expenses
  double get totalExpenses {
    return _expenses
        .where((expense) => !expense.isIncome)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Calculate available balance
  double get balance => totalIncome - totalExpenses;

  // Load transactions from local storage
  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _storage.loadExpenses();
    } catch (e) {
      _error = 'Unable to load transactions.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new transaction
  Future<void> addExpense(Expense expense) async {
    _error = null;

    _expenses.insert(0, expense);
    notifyListeners();

    try {
      await _storage.saveExpenses(_expenses);
    } catch (e) {
      _expenses.removeWhere((item) => item.id == expense.id);
      _error = 'Unable to save transaction.';
      notifyListeners();
      rethrow;
    }
  }

  // Update an existing transaction
  Future<void> updateExpense(Expense updatedExpense) async {
    _error = null;

    final index = _expenses.indexWhere(
      (item) => item.id == updatedExpense.id,
    );

    if (index == -1) {
      throw Exception('Transaction not found.');
    }

    final oldExpense = _expenses[index];

    _expenses[index] = updatedExpense;
    notifyListeners();

    try {
      await _storage.saveExpenses(_expenses);
    } catch (e) {
      _expenses[index] = oldExpense;
      _error = 'Unable to update transaction.';
      notifyListeners();
      rethrow;
    }
  }

  // Delete a transaction
  Future<void> deleteExpense(String id) async {
    final index = _expenses.indexWhere((item) => item.id == id);

    if (index == -1) return;

    final removedExpense = _expenses.removeAt(index);
    notifyListeners();

    try {
      await _storage.saveExpenses(_expenses);
    } catch (e) {
      _expenses.insert(index, removedExpense);
      _error = 'Unable to delete transaction.';
      notifyListeners();
      rethrow;
    }
  }
}
