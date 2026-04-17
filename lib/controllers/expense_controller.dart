import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/expense_database.dart';

class ExpenseController extends ChangeNotifier {
  ExpenseController();

  final ExpenseDatabase _database = ExpenseDatabase.instance;
  final List<Expense> _expenses = [];
  bool _isLoading = true;
  double _monthlyBudget = 15000;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  UnmodifiableListView<Expense> get expenses => UnmodifiableListView(_expenses);
  bool get isLoading => _isLoading;
  double get monthlyBudget => _monthlyBudget;
  DateTime get selectedMonth => _selectedMonth;

  List<Expense> get filteredExpenses {
    final month = _selectedMonth.month;
    final year = _selectedMonth.year;
    return _expenses
        .where((expense) => expense.date.month == month && expense.date.year == year)
        .toList();
  }

  List<Expense> get incomeTransactions {
    return filteredExpenses
        .where((expense) => expense.type == TransactionType.income)
        .toList();
  }

  List<Expense> get expenseTransactions {
    return filteredExpenses
        .where((expense) => expense.type == TransactionType.expense)
        .toList();
  }

  double get totalIncome {
    return incomeTransactions.fold(0, (total, expense) => total + expense.amount);
  }

  double get totalSpent {
    return expenseTransactions.fold(0, (total, expense) => total + expense.amount);
  }

  double get monthlyBalance => totalIncome - totalSpent;

  double get remainingBudget => _monthlyBudget - totalSpent;

  Map<ExpenseCategory, double> get categoryTotals {
    final totals = <ExpenseCategory, double>{};
    for (final expense in expenseTransactions) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _monthlyBudget = prefs.getDouble('monthly_budget') ?? 15000;
    _expenses
      ..clear()
      ..addAll(await _database.fetchExpenses());

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required TransactionType type,
    required ExpenseCategory category,
    required DateTime date,
    String note = '',
  }) async {
    final expense = Expense(
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );

    final id = await _database.insertExpense(expense);
    _expenses.insert(0, expense.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deleteExpense(Expense expense) async {
    if (expense.id == null) {
      return;
    }

    await _database.deleteExpense(expense.id!);
    _expenses.removeWhere((item) => item.id == expense.id);
    notifyListeners();
  }

  Future<void> updateBudget(double budget) async {
    _monthlyBudget = budget;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget', budget);
    notifyListeners();
  }

  void changeMonth(int offset) {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    notifyListeners();
  }
}
