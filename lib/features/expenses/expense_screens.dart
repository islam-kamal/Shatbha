import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di.dart';
import '../../core/failures.dart';
import '../../core/format.dart';
import '../../data/models/models.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../features/shell/date_range_cubit.dart';
import '../../theme/atelier_theme.dart';
import '../../widgets/widgets.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<ExpenseItem> _rows = [];
  String _total = '0.00';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final range = context.read<DateRangeCubit>().state;
    try {
      final result = await sl<ExpenseRepository>().list(
        from: range.fromIso,
        to: range.toIso,
      );
      if (!mounted) return;
      setState(() {
        _rows = result.$1;
        _total = result.$2;
        _loading = false;
        _error = null;
      });
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('يومية المصروفات الإدارية'),
        toolbarHeight: 88,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () => context.push('/reports/expenses'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!)
              : _rows.isEmpty
                  ? StatusView.empty(
                      title: 'لا توجد مصروفات في هذه الفترة',
                      body: 'غيّر الفترة أو أضف أول مصروف.',
                      actionLabel: 'إضافة أول مصروف',
                      onAction: () async {
                        await context.push('/expenses/add');
                        _load();
                      },
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: KpiStrip(
                            items: [
                              KpiItem(
                                'الإجمالي',
                                _total,
                                tint: c.ivory,
                                icon: Icons.account_balance_wallet_outlined,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: IvorySheet(
                            child: LedgerList(
                              rows: [
                                for (final e in _rows)
                                  LedgerRow(
                                    id: e.id,
                                    title: e.title,
                                    subtitle:
                                        '${e.categoryName ?? 'أخرى'} · ${displayDate(e.entryDate)}',
                                    amount: e.amount,
                                    accent: c.terracotta,
                                    badge: 'ج.م',
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: AtelierButton(
                              label: 'مصروف جديد',
                              icon: Icons.add,
                              onPressed: () async {
                                await context.push('/expenses/add');
                                _load();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  List<NamedItem> _cats = [];
  int? _categoryId;
  final _title = TextEditingController();
  final _amount = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    sl<CatalogRepository>().expenseCategories().then((rows) {
      if (mounted) setState(() => _cats = rows);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('مصروف جديد'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int>(
            initialValue: _categoryId,
            hint: const Text('البند'),
            items: [
              for (final c in _cats)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'البيان')),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'المبلغ'),
          ),
          ListTile(
            title: Text(formatDate(_date)),
            trailing: const Icon(Icons.event),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          const SizedBox(height: 24),
          AtelierButton(
            label: 'حفظ',
            onPressed: () async {
              await sl<ExpenseRepository>().create({
                'category_id': _categoryId,
                'entry_date': formatDate(_date),
                'title': _title.text.trim(),
                'amount': _amount.text.trim(),
              });
              if (context.mounted) {
                await showAtelierSuccess(context, body: 'تم تسجيل المصروف بنجاح');
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  List<CategoryTotal> _rows = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    sl<ExpenseRepository>().byCategory().then((rows) {
      if (mounted) setState(() {
        _rows = rows;
        _loading = false;
      });
    }).catchError((e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('تقرير المصروفات'),
        toolbarHeight: 76,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!)
              : _rows.isEmpty
                  ? const StatusView.empty()
                  : IvorySheet(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: [
                          for (final row in _rows)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: LedgerCard(
                                row: LedgerRow(
                                  id: row.category.hashCode,
                                  title: row.category,
                                  subtitle: 'إجمالي البند',
                                  amount: row.total,
                                  accent: c.terracotta,
                                  badge: 'ج.م',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}
