import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/expense_controller.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../widgets/add_expense_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final pages = [
          _DashboardTab(
            controller: controller,
            onEdit: (expense) => _openEditExpenseSheet(context, expense),
          ),
          _TransactionsTab(
            controller: controller,
            onEdit: (expense) => _openEditExpenseSheet(context, expense),
          ),
          _CategoriesTab(controller: controller),
        ];

        return Scaffold(
          extendBody: true,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddExpenseSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar'),
          ),
          bottomNavigationBar: _BottomBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7F3EC), Color(0xFFE8EEF6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(child: pages[_currentIndex]),
          ),
        );
      },
    );
  }

  Future<void> _openAddExpenseSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const AddExpenseSheet(),
    );
  }

  Future<void> _openEditExpenseSheet(BuildContext context, Expense expense) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddExpenseSheet(initialExpense: expense),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.controller,
    required this.onEdit,
  });

  final ExpenseController controller;
  final ValueChanged<Expense> onEdit;

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'es').format(controller.selectedMonth);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopHeader(controller: controller, monthLabel: monthLabel),
                const SizedBox(height: 18),
                _BalanceHero(controller: controller),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _SmallStatCard(
                        title: 'Ingresos',
                        value: controller.totalIncome,
                        valueColor: const Color(0xFF2AA968),
                        icon: Icons.arrow_downward_rounded,
                        iconTint: const Color(0xFFDDF4E7),
                        iconColor: const Color(0xFF2AA968),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _SmallStatCard(
                        title: 'Gastos',
                        value: controller.totalSpent,
                        valueColor: const Color(0xFFE25555),
                        icon: Icons.arrow_upward_rounded,
                        iconTint: const Color(0xFFFBE3E3),
                        iconColor: const Color(0xFFE25555),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Gastos por categoria',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                _CategoryDonutCard(controller: controller),
                const SizedBox(height: 22),
                Text(
                  'Actividad reciente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (controller.filteredExpenses.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: _EmptyState(
                title: 'Todavia no registras movimientos',
                message:
                    'Agrega ingresos o gastos para ver tu resumen mensual aqui.',
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(context).padding.bottom + 90,
            ),
            sliver: SliverList.separated(
              itemCount: math.min(4, controller.filteredExpenses.length),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _TransactionTile(
                  expense: controller.filteredExpenses[index],
                  onEdit: onEdit,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab({
    required this.controller,
    required this.onEdit,
  });

  final ExpenseController controller;
  final ValueChanged<Expense> onEdit;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transacciones',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Historial completo del mes seleccionado.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF66757D),
                      ),
                ),
                const SizedBox(height: 16),
                _MonthSelector(controller: controller),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoPill(
                      label: 'Movimientos',
                      value: '${controller.filteredExpenses.length}',
                    ),
                    _InfoPill(
                      label: 'Ingresos',
                      value: _currency0(controller.totalIncome),
                    ),
                    _InfoPill(
                      label: 'Gastos',
                      value: _currency0(controller.totalSpent),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
        if (controller.filteredExpenses.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: _EmptyState(
                title: 'No hay transacciones en este mes',
                message: 'Cambia el mes o agrega un nuevo movimiento.',
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(context).padding.bottom + 90,
            ),
            sliver: SliverList.separated(
              itemCount: controller.filteredExpenses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _TransactionTile(
                  expense: controller.filteredExpenses[index],
                  onEdit: onEdit,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.controller});

  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    final categories = controller.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categorias',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vista agrupada de tus gastos del mes.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF66757D),
                      ),
                ),
                const SizedBox(height: 16),
                _MonthSelector(controller: controller),
                const SizedBox(height: 18),
                _BudgetStatusCard(controller: controller),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
        if (categories.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: _EmptyState(
                title: 'Sin categorias activas',
                message: 'Los gastos que registres apareceran agrupados aqui.',
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(context).padding.bottom + 90,
            ),
            sliver: SliverList.separated(
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = categories[index];
                final total = controller.totalSpent == 0
                    ? 0.0
                    : entry.value / controller.totalSpent;
                return _CategorySummaryTile(
                  category: entry.key,
                  amount: entry.value,
                  progress: total,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.controller,
    required this.monthLabel,
  });

  final ExpenseController controller;
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C86DB),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mi Billetera',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                onPressed: controller.loadData,
                icon: const Icon(Icons.sync_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                monthLabel.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.4,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: () => controller.changeMonth(-1),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => controller.changeMonth(1),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({required this.controller});

  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D8AE0), Color(0xFF2672CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33267ACC),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance del mes',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            _currency2(controller.monthlyBalance),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            controller.monthlyBalance >= 0
                ? 'Tu flujo del mes va positivo.'
                : 'Tus gastos superan tus ingresos este mes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.title,
    required this.value,
    required this.valueColor,
    required this.icon,
    required this.iconTint,
    required this.iconColor,
  });

  final String title;
  final double value;
  final Color valueColor;
  final IconData icon;
  final Color iconTint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconTint,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6A7680),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currency2(value),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: valueColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryDonutCard extends StatelessWidget {
  const _CategoryDonutCard({required this.controller});

  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    final categories = controller.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: categories.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No hay gastos para graficar.')),
            )
          : Column(
              children: [
                SizedBox(
                  height: 230,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size.square(200),
                        painter: _DonutChartPainter(
                          items: categories,
                          total: controller.totalSpent,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currency0(controller.totalSpent),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gastos del mes',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF708089),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: categories.map((entry) {
                    return _LegendDot(
                      label: entry.key.label,
                      color: entry.key.color,
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.controller});

  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'es').format(controller.selectedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => controller.changeMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              toBeginningOfSentenceCase(monthLabel) ?? monthLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          IconButton(
            onPressed: () => controller.changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _BudgetStatusCard extends StatelessWidget {
  const _BudgetStatusCard({required this.controller});

  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.monthlyBudget == 0
        ? 0.0
        : (controller.totalSpent / controller.monthlyBudget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Presupuesto mensual',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              Text(
                _currency0(controller.monthlyBudget),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showBudgetDialog(context),
                icon: const Icon(Icons.edit_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE7EEF9),
                  foregroundColor: const Color(0xFF2C86DB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: const Color(0xFFE6EDF7),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2C86DB)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            controller.remainingBudget >= 0
                ? 'Disponible: ${_currency0(controller.remainingBudget)}'
                : 'Excedido: ${_currency0(controller.remainingBudget.abs())}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: controller.remainingBudget >= 0
                      ? const Color(0xFF2C8E61)
                      : const Color(0xFFC84A4A),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBudgetDialog(BuildContext context) async {
    final budgetCtrl = TextEditingController(
      text: controller.monthlyBudget.toStringAsFixed(0),
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Presupuesto mensual'),
          content: TextField(
            controller: budgetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monto disponible',
              prefixIcon: Icon(Icons.wallet_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(
                  budgetCtrl.text.trim().replaceAll(',', '.'),
                );
                if (amount != null && amount > 0) {
                  await controller.updateBudget(amount);
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Color(0xFF6C7A82),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF163B56),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.expense,
    required this.onEdit,
  });

  final Expense expense;
  final ValueChanged<Expense> onEdit;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ExpenseController>();
    final dateLabel = DateFormat('dd MMM yyyy', 'es').format(expense.date);
    final isIncome = expense.type == TransactionType.income;
    final amountColor =
        isIncome ? const Color(0xFF2AA968) : const Color(0xFFE25555);

    return Dismissible(
      key: ValueKey(expense.id ?? '${expense.title}-${expense.date.toIso8601String()}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFC0392B),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteExpense(expense),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: expense.category.color.withValues(alpha: 0.12),
              child: Icon(
                isIncome ? Icons.arrow_downward_rounded : expense.category.icon,
                color:
                    isIncome ? const Color(0xFF2AA968) : expense.category.color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${expense.type.label} · ${expense.category.label} · ${toBeginningOfSentenceCase(dateLabel)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6A7880),
                        ),
                  ),
                  if (expense.note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(expense.note, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      onEdit(expense);
                    } else if (value == 'delete') {
                      final shouldDelete = await _confirmDelete(context);
                      if (shouldDelete == true) {
                        await controller.deleteExpense(expense);
                      }
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Eliminar'),
                    ),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.more_vert_rounded),
                  ),
                ),
                Text(
                  '${isIncome ? '+' : '-'}${_currency2(expense.amount)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: amountColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar movimiento'),
          content: Text('¿Deseas eliminar "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

class _CategorySummaryTile extends StatelessWidget {
  const _CategorySummaryTile({
    required this.category,
    required this.amount,
    required this.progress,
  });

  final ExpenseCategory category;
  final double amount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: category.color.withValues(alpha: 0.12),
                child: Icon(category.icon, color: category.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                _currency2(amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: category.color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: const Color(0xFFE6EDF7),
              valueColor: AlwaysStoppedAnimation(category.color),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}% del total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF68767F),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Inicio'),
      (Icons.swap_horiz_rounded, 'Transacciones'),
      (Icons.category_outlined, 'Categorias'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BottomAppBar(
          elevation: 14,
          color: Colors.white.withValues(alpha: 0.95),
          child: SizedBox(
            height: 88,
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final active = currentIndex == index;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onTap(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFE1ECFF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              item.$1,
                              size: 22,
                              color: active
                                  ? const Color(0xFF2C86DB)
                                  : const Color(0xFF4F5D67),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Flexible(
                            child: Text(
                              item.$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    fontSize: 10,
                                    fontWeight:
                                        active ? FontWeight.w800 : FontWeight.w600,
                                    color: const Color(0xFF33414A),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            color: Color(0xFFE6EEF9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            size: 52,
            color: Color(0xFF2C86DB),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF66757D),
              ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.items,
    required this.total,
  });

  final List<MapEntry<ExpenseCategory, double>> items;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFE7EDF7)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(stroke / 2), 0, math.pi * 2, false, basePaint);

    var startAngle = -math.pi / 2;
    for (final item in items) {
      final sweep = total == 0 ? 0.0 : (item.value / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = item.key.color;
      canvas.drawArc(rect.deflate(stroke / 2), startAngle, sweep, false, paint);
      startAngle += sweep + 0.04;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.total != total;
  }
}

String _currency2(double value) {
  return NumberFormat.currency(
    locale: 'es_DO',
    symbol: 'RD\$',
    decimalDigits: 2,
  ).format(value);
}

String _currency0(double value) {
  return NumberFormat.currency(
    locale: 'es_DO',
    symbol: 'RD\$',
    decimalDigits: 0,
  ).format(value);
}
