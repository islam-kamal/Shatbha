import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di.dart';
import '../../core/format.dart';
import '../../data/models/models.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../features/shell/date_range_cubit.dart';
import '../../theme/atelier_theme.dart';
import '../../widgets/widgets.dart';
import 'journal_cubit.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final range = context.read<DateRangeCubit>().state;
        return JournalCubit(sl())
          ..load(from: range.fromIso, to: range.toIso);
      },
      child: const _JournalView(),
    );
  }
}

class _JournalView extends StatelessWidget {
  const _JournalView();

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('يومية العملاء', subtitle: 'دفتر اليومية'),
        toolbarHeight: 88,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => _pickDates(context),
          ),
        ],
      ),
      body: BlocBuilder<JournalCubit, JournalState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return StatusView.error(body: state.error!);
          }
          if (state.isEmpty) {
            return StatusView.empty(
              title: 'لا توجد حركات',
              body: 'أضف أول قيد ليظهر في اليومية.',
              actionLabel: 'قيد جديد',
              onAction: () => context.push('/journal/add'),
            );
          }
          final cash = state.entries
              .where((e) => e.entryType == 'cash')
              .fold<double>(0, (s, e) => s + (double.tryParse(e.amount) ?? 0));
          final labor = state.entries.fold<double>(
            0,
            (s, e) => s + (double.tryParse(e.laborAmount) ?? 0),
          );
          final returns = state.entries.fold<double>(
            0,
            (s, e) => s + (double.tryParse(e.returnAmount) ?? 0),
          );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: KpiStrip(
                  items: [
                    KpiItem(
                      'توريدات نقدية',
                      cash.toStringAsFixed(2),
                      tint: c.cashTint,
                      icon: Icons.payments_outlined,
                    ),
                    KpiItem(
                      'مصنعيات',
                      labor.toStringAsFixed(2),
                      tint: c.expenseTint,
                      icon: Icons.handyman_outlined,
                    ),
                    KpiItem(
                      'مرتجعات',
                      returns.toStringAsFixed(2),
                      tint: c.dateTint,
                      icon: Icons.undo,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IvorySheet(
                  child: LedgerList(
                    rows: [
                      for (final e in state.entries)
                        LedgerRow(
                          id: e.id,
                          title: e.title,
                          subtitle:
                              '${_typeLabel(e.entryType)} · ${e.customerName ?? ''} · ${displayDate(e.entryDate)}',
                          amount: e.entryType == 'labor' ? e.laborAmount : e.amount,
                          accent: e.entryType == 'cash' ? c.teal : c.terracotta,
                          badge: e.entryType == 'cash' ? 'إيراد' : 'مصروف',
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
                    label: 'قيد جديد',
                    icon: Icons.add,
                    onPressed: () => context.push('/journal/add'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _typeLabel(String type) {
  return switch (type) {
    'cash' => 'توريد نقدي',
    'labor' => 'مصنعية',
    'goods' => 'خامات',
    'return' => 'مرتجع',
    _ => type,
  };
}

Future<void> _pickDates(BuildContext context) async {
  final cubit = context.read<DateRangeCubit>();
  final from = await showDatePicker(
    context: context,
    initialDate: cubit.state.from ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    helpText: 'من تاريخ',
  );
  if (!context.mounted) return;
  final to = await showDatePicker(
    context: context,
    initialDate: cubit.state.to ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    helpText: 'إلى تاريخ',
  );
  cubit.setRange(from, to);
  if (context.mounted) {
    context.read<JournalCubit>().load(from: cubit.state.fromIso, to: cubit.state.toIso);
  }
}

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  List<Party> _customers = [];
  int? _customerId;
  String _type = 'cash';
  final _title = TextEditingController();
  final _amount = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    sl<CatalogRepository>().parties('customer').then((rows) {
      if (mounted) setState(() => _customers = rows);
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
        title: const ScreenTitle('قيد جديد'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int>(
            initialValue: _customerId,
            hint: const Text('العميل'),
            items: [
              for (final p in _customers)
                DropdownMenuItem(value: p.id, child: Text(p.name)),
            ],
            onChanged: (v) => setState(() => _customerId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('تحصيل')),
              DropdownMenuItem(value: 'labor', child: Text('مصنعية')),
              DropdownMenuItem(value: 'goods', child: Text('خامات')),
              DropdownMenuItem(value: 'return', child: Text('مرتجع')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'cash'),
            decoration: const InputDecoration(labelText: 'نوع القيد'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'البيان')),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'المبلغ'),
          ),
          const SizedBox(height: 12),
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
              if (_customerId == null || _title.text.trim().isEmpty) return;
              final amount = _amount.text.trim();
              await sl<JournalRepository>().create({
                'customer_id': _customerId,
                'entry_date': formatDate(_date),
                'entry_type': _type,
                'title': _title.text.trim(),
                if (_type == 'labor') 'labor_amount': amount else 'amount': amount,
              });
              if (context.mounted) {
                await showAtelierSuccess(context, body: 'تم تسجيل القيد بنجاح');
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class CustomerPickerScreen extends StatefulWidget {
  const CustomerPickerScreen({super.key});

  @override
  State<CustomerPickerScreen> createState() => _CustomerPickerScreenState();
}

class _CustomerPickerScreenState extends State<CustomerPickerScreen> {
  List<Party> _rows = [];

  @override
  void initState() {
    super.initState();
    sl<CatalogRepository>().parties('customer').then((rows) {
      if (mounted) setState(() => _rows = rows);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('كشف حساب عميل'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          IvoryMenuCard(
            children: [
              for (final p in _rows)
                HubRow(
                  title: p.name,
                  subtitle: p.isSupervision
                      ? 'عميل إشراف · ${p.phone ?? ''}'
                      : 'عميل اتفاق · ${p.phone ?? ''}',
                  icon: Icons.person_outline,
                  onTap: () => context.push('/customers/${p.id}/statement'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key, required this.customerId});
  final int customerId;

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  StatementData? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    final range = context.read<DateRangeCubit>().state;
    sl<JournalRepository>()
        .statement(widget.customerId, from: range.fromIso, to: range.toIso)
        .then((data) {
      if (mounted) setState(() => _data = data);
    }).catchError((e) {
      if (mounted) setState(() => _error = e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final data = _data;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('كشف حساب عميل'),
        toolbarHeight: 76,
        actions: [
          if (data?.customer.isSupervision == true)
            TextButton(
              onPressed: () =>
                  context.push('/customers/${widget.customerId}/supervision'),
              child: const Text('إشراف'),
            ),
        ],
      ),
      body: _error != null
          ? StatusView.error(body: _error!)
          : data == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Text(
                        data.customer.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'الرصيد الحالي',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      formatEgp(data.closing),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: c.brass,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const BrassDiamond(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: KpiStrip(
                        items: [
                          KpiItem('افتتاحي', data.opening, tint: c.identityTint),
                          KpiItem('مبيعات', data.sales, tint: c.dateTint),
                          KpiItem('تحصيل', data.collect, tint: c.cashTint),
                          KpiItem('ختامي', data.closing, tint: c.calculatedTint),
                        ],
                      ),
                    ),
                    Expanded(
                      child: IvorySheet(
                        child: LedgerList(
                          rows: [
                            for (final e in data.entries)
                              LedgerRow(
                                id: e.id,
                                title: e.title,
                                subtitle:
                                    '${_typeLabel(e.entryType)} · ${displayDate(e.entryDate)}',
                                amount: e.entryType == 'labor'
                                    ? e.laborAmount
                                    : e.amount,
                                accent: e.entryType == 'cash'
                                    ? c.teal
                                    : c.terracotta,
                                badge: e.entryType == 'cash' ? 'إيراد' : 'مصروف',
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
                          label: 'إضافة قيد',
                          icon: Icons.add,
                          onPressed: () => context.push('/journal/add'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class SupervisionScreen extends StatefulWidget {
  const SupervisionScreen({super.key, required this.customerId});
  final int customerId;

  @override
  State<SupervisionScreen> createState() => _SupervisionScreenState();
}

class _SupervisionScreenState extends State<SupervisionScreen> {
  Party? _party;
  List<JournalEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    sl<CatalogRepository>().parties('customer').then((rows) {
      if (!mounted) return;
      setState(() {
        _party = rows.where((p) => p.id == widget.customerId).firstOrNull;
      });
    });
    sl<JournalRepository>().entries(customerId: widget.customerId).then((rows) {
      if (mounted) setState(() => _entries = rows);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final party = _party;
    final collected = _entries
        .where((e) => e.entryType == 'cash')
        .fold<double>(0, (s, e) => s + (double.tryParse(e.amount) ?? 0));
    final fee = collected * ((party?.supervisionPercent ?? 0) / 100);
    return Scaffold(
      appBar: AppBar(title: Text('إشراف ${party?.name ?? ''}')),
      body: party == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  KpiStrip(
                    items: [
                      KpiItem('النسبة', '${party.supervisionPercent}.00', tint: c.identityTint),
                      KpiItem('التحصيل', collected.toStringAsFixed(2), tint: c.cashTint),
                      KpiItem('أتعاب الإشراف', fee.toStringAsFixed(2), tint: c.calculatedTint),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'تحسب أتعاب الإشراف كنسبة من التحصيل النقدي للعميل.',
                    style: TextStyle(color: c.ivoryMuted),
                  ),
                ],
              ),
            ),
    );
  }
}

class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({super.key});

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
  List<CustomerReportRow> _rows = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    sl<ReportRepository>().customers().then((rows) {
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
        title: const ScreenTitle('تقرير العملاء'),
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
                                  id: row.id,
                                  title: row.name,
                                  subtitle:
                                      'مبيعات ${formatMoney(row.sales)} · تحصيل ${formatMoney(row.collect)}',
                                  amount: row.closing,
                                  accent: c.brass,
                                  badge: 'ختامي',
                                ),
                                onTap: () => context
                                    .push('/customers/${row.id}/statement'),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}
