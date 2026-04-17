import 'expense_category.dart';

enum TransactionType { income, expense }

extension TransactionTypeX on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Ingreso';
      case TransactionType.expense:
        return 'Gasto';
    }
  }

  static TransactionType fromName(String value) {
    return TransactionType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}

class Expense {
  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note = '',
  });

  final int? id;
  final String title;
  final double amount;
  final TransactionType type;
  final ExpenseCategory category;
  final DateTime date;
  final String note;

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    TransactionType? type,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      type: TransactionTypeX.fromName(map['type'] as String? ?? ''),
      category: ExpenseCategoryX.fromName(map['category'] as String? ?? ''),
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      note: map['note'] as String? ?? '',
    );
  }
}
