import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di.dart';
import '../../core/failures.dart';
import '../../core/format.dart';
import '../../data/models/models.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../theme/atelier_theme.dart';
import '../../widgets/widgets.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  List<ContractorJob> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await sl<JobRepository>().list();
      if (!mounted) return;
      setState(() {
        _rows = rows;
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
    final remaining = _rows.fold<double>(
      0,
      (s, e) => s + (double.tryParse(e.remaining) ?? 0),
    );
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('حسابات المقاولين'),
        toolbarHeight: 76,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!)
              : _rows.isEmpty
                  ? StatusView.empty(
                      title: 'لا توجد أعمال',
                      body: 'أضف اتفاق مقاول ليظهر المتبقي هنا.',
                      actionLabel: 'عمل جديد',
                      onAction: () async {
                        await context.push('/jobs/add');
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
                                'المتبقي',
                                remaining.toStringAsFixed(2),
                                tint: c.calculatedTint,
                                icon: Icons.account_balance_wallet_outlined,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: IvorySheet(
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              itemCount: _rows.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final job = _rows[i];
                                return LedgerCard(
                                  row: LedgerRow(
                                    id: job.id,
                                    title: job.title,
                                    subtitle:
                                        '${job.contractor?.name ?? ''} · إجمالي ${formatEgp(job.total)}',
                                    amount: job.remaining,
                                    accent: c.brass,
                                    badge: 'متبقي',
                                  ),
                                  onTap: () async {
                                    await context.push('/jobs/${job.id}/pay');
                                    _load();
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: AtelierButton(
                              label: 'عمل جديد',
                              icon: Icons.add,
                              onPressed: () async {
                                await context.push('/jobs/add');
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

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  List<Party> _contractors = [];
  int? _contractorId;
  final _title = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _price = TextEditingController();

  @override
  void initState() {
    super.initState();
    sl<CatalogRepository>().parties('contractor').then((rows) {
      if (mounted) setState(() => _contractors = rows);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('عمل جديد'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int>(
            initialValue: _contractorId,
            hint: const Text('المقاول'),
            items: [
              for (final p in _contractors)
                DropdownMenuItem(value: p.id, child: Text(p.name)),
            ],
            onChanged: (v) => setState(() => _contractorId = v),
          ),
          const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'البيان')),
          const SizedBox(height: 12),
          TextField(
            controller: _qty,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'الكمية'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'سعر الوحدة'),
          ),
          const SizedBox(height: 24),
          AtelierButton(
            label: 'حفظ',
            onPressed: () async {
              if (_contractorId == null) return;
              await sl<JobRepository>().create({
                'contractor_id': _contractorId,
                'title': _title.text.trim(),
                'qty': _qty.text.trim(),
                'unit_price': _price.text.trim(),
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ العمل')),
                );
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class PayJobScreen extends StatefulWidget {
  const PayJobScreen({super.key, required this.jobId});
  final int jobId;

  @override
  State<PayJobScreen> createState() => _PayJobScreenState();
}

class _PayJobScreenState extends State<PayJobScreen> {
  ContractorJob? _job;
  final _amount = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    sl<JobRepository>().list().then((rows) {
      if (mounted) {
        setState(() {
          _job = rows.where((j) => j.id == widget.jobId).firstOrNull;
        });
      }
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('صرف دفعة'),
        toolbarHeight: 76,
      ),
      body: job == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('المتبقي ${formatMoney(job.remaining)}', style: TextStyle(color: c.brass)),
                const SizedBox(height: 16),
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
                  label: 'صرف',
                  kind: AtelierButtonKind.teal,
                  onPressed: () async {
                    await sl<JobRepository>().pay(widget.jobId, {
                      'amount': _amount.text.trim(),
                      'paid_on': formatDate(_date),
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم صرف الدفعة')),
                      );
                      context.pop();
                    }
                  },
                ),
              ],
            ),
    );
  }
}

class ContractorReportScreen extends StatefulWidget {
  const ContractorReportScreen({super.key});

  @override
  State<ContractorReportScreen> createState() => _ContractorReportScreenState();
}

class _ContractorReportScreenState extends State<ContractorReportScreen> {
  List<ContractorReportRow> _rows = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    sl<ReportRepository>().contractors().then((rows) {
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
        title: const ScreenTitle('تقرير المقاولين'),
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
                                  subtitle: 'المتبقي على الأعمال',
                                  amount: row.remaining,
                                  accent: c.brass,
                                  badge: 'متبقي',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}
