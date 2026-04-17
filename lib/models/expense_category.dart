import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transport,
  home,
  health,
  entertainment,
  education,
  shopping,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Comida';
      case ExpenseCategory.transport:
        return 'Transporte';
      case ExpenseCategory.home:
        return 'Hogar';
      case ExpenseCategory.health:
        return 'Salud';
      case ExpenseCategory.entertainment:
        return 'Ocio';
      case ExpenseCategory.education:
        return 'Educacion';
      case ExpenseCategory.shopping:
        return 'Compras';
      case ExpenseCategory.other:
        return 'Otros';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_bus_rounded;
      case ExpenseCategory.home:
        return Icons.home_rounded;
      case ExpenseCategory.health:
        return Icons.favorite_rounded;
      case ExpenseCategory.entertainment:
        return Icons.movie_rounded;
      case ExpenseCategory.education:
        return Icons.school_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFE67E22);
      case ExpenseCategory.transport:
        return const Color(0xFF2980B9);
      case ExpenseCategory.home:
        return const Color(0xFF16A085);
      case ExpenseCategory.health:
        return const Color(0xFFC0392B);
      case ExpenseCategory.entertainment:
        return const Color(0xFF8E44AD);
      case ExpenseCategory.education:
        return const Color(0xFF2C3E50);
      case ExpenseCategory.shopping:
        return const Color(0xFFD35400);
      case ExpenseCategory.other:
        return const Color(0xFF7F8C8D);
    }
  }

  static ExpenseCategory fromName(String value) {
    return ExpenseCategory.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}
