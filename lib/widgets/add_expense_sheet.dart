import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/expense_controller.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({
    super.key,
    this.initialExpense,
  });

  final Expense? initialExpense;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.initialExpense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;
    if (expense != null) {
      _titleCtrl.text = expense.title;
      _amountCtrl.text = expense.amount.toStringAsFixed(2);
      _noteCtrl.text = expense.note;
      _selectedType = expense.type;
      _selectedCategory = expense.category;
      _selectedDate = expense.date;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    final controller = context.read<ExpenseController>();

    if (_isEditing) {
      await controller.updateExpense(
        originalExpense: widget.initialExpense!,
        title: _titleCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
        type: _selectedType,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteCtrl.text.trim(),
      );
    } else {
      await controller.addExpense(
        title: _titleCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
        type: _selectedType,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteCtrl.text.trim(),
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy', 'es');
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isEditing ? 'Editar movimiento' : 'Nuevo movimiento',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment<TransactionType>(
                    value: TransactionType.income,
                    icon: Icon(Icons.arrow_downward_rounded),
                    label: Text('Ingreso'),
                  ),
                  ButtonSegment<TransactionType>(
                    value: TransactionType.expense,
                    icon: Icon(Icons.arrow_upward_rounded),
                    label: Text('Gasto'),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (selection) {
                  setState(() => _selectedType = selection.first);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: _selectedType == TransactionType.income
                      ? 'Descripcion del ingreso'
                      : 'Descripcion del gasto',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa una descripcion';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (value) {
                  final normalized = value?.replaceAll(',', '.') ?? '';
                  final amount = double.tryParse(normalized);
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un monto valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: ExpenseCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _pickDate,
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Fecha: ${formatter.format(_selectedDate)}'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nota opcional',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.sticky_note_2_rounded),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_isEditing ? Icons.edit_rounded : Icons.save_rounded),
                  label: Text(
                    _isEditing
                        ? 'Guardar cambios'
                        : _selectedType == TransactionType.income
                            ? 'Guardar ingreso'
                            : 'Guardar gasto',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
