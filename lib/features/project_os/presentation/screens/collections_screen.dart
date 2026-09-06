import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';
import '../../data/project_os_models.dart';

class InstallmentsScreen extends StatefulWidget {
  const InstallmentsScreen({super.key});

  @override
  State<InstallmentsScreen> createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  List<PaymentInstallment> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await sl<ProjectOsApi>().listAllInstallments();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
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
    double due = 0;
    double paid = 0;
    double overdue = 0;
    final today = DateTime.now();
    for (final i in _items) {
      final amount = double.tryParse(i.amount.replaceAll(',', '')) ?? 0;
      if (i.status == 'paid') {
        paid += amount;
      } else {
        due += amount;
        final d = i.dueDate != null ? DateTime.tryParse(i.dueDate!) : null;
        if (d != null && d.isBefore(today)) overdue += amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('تحصيل الأقساط', subtitle: 'كل المشاريع'),
        toolbarHeight: 88,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : IvorySheet(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      KpiStrip(
                        items: [
                          KpiItem('مستحق', due.toStringAsFixed(0),
                              tint: c.dateTint),
                          KpiItem('محصل', paid.toStringAsFixed(0),
                              tint: c.teal),
                          KpiItem('متأخر', overdue.toStringAsFixed(0),
                              tint: c.expenseTint),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        const StatusView.empty(
                          title: 'لا أقساط',
                          body: 'ستظهر أقساط المشاريع هنا.',
                        )
                      else
                        for (final inst in _items) ...[
                          LedgerCard(
                            row: LedgerRow(
                              id: inst.id,
                              title: inst.label ?? 'قسط',
                              subtitle:
                                  'مشروع #${inst.projectId} · ${inst.dueDate ?? '—'}',
                              amount: inst.amount,
                              accent: inst.status == 'paid'
                                  ? c.teal
                                  : c.expenseTint,
                              badge: inst.status == 'paid' ? 'مدفوع' : 'مستحق',
                            ),
                            onTap: () => context.push(
                              '/projects/${inst.projectId}/payment-plan',
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                    ],
                  ),
                ),
    );
  }
}
