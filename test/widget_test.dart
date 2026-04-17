import 'package:flutter_test/flutter_test.dart';

import 'package:control_gastos_app/models/expense_category.dart';

void main() {
  test('expense category labels are available', () {
    expect(ExpenseCategory.food.label, 'Comida');
    expect(ExpenseCategory.transport.label, 'Transporte');
  });
}
