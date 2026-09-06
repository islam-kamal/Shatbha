import 'package:flutter/material.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';
import '../../data/project_os_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payment Plan Screen
// ─────────────────────────────────────────────────────────────────────────────

class PaymentPlanScreen extends StatefulWidget {
  const PaymentPlanScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<PaymentPlanScreen> createState() => _PaymentPlanScreenState();
}

class _PaymentPlanScreenState extends State<PaymentPlanScreen> {
  List<PaymentInstallment> _installments = [];
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
      final items =
          await sl<ProjectOsApi>().listInstallments(widget.projectId);
      if (!mounted) return;
      setState(() {
        _installments = items;
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

  Future<void> _markPaid(int id) async {
    try {
      final updated = await sl<ProjectOsApi>().markPaid(id);
      if (!mounted) return;
      setState(() {
        _installments = _installments
            .map((inst) => inst.id == id ? updated : inst)
            .toList();
      });
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;

    // Compute totals
    double totalPaid = 0;
    double totalDue = 0;
    for (final inst in _installments) {
      final amount =
          double.tryParse(inst.amount.replaceAll(',', '')) ?? 0;
      if (inst.status == 'paid') {
        totalPaid += amount;
      } else {
        totalDue += amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('خطة الدفع', subtitle: 'الأقساط والمدفوعات'),
        toolbarHeight: 88,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addInstallment,
        icon: const Icon(Icons.add),
        label: const Text('قسط جديد'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _installments.isEmpty
                  ? const StatusView.empty(
                      title: 'لا أقساط',
                      body: 'أضف قسطاً لخطة الدفع.')
                  : IvorySheet(
                      child: ListView(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        children: [
                          KpiStrip(
                            items: [
                              KpiItem(
                                'المدفوع',
                                totalPaid.toStringAsFixed(2),
                                tint: c.teal,
                                icon: Icons.check_circle_outline,
                              ),
                              KpiItem(
                                'المتبقي',
                                totalDue.toStringAsFixed(2),
                                tint: c.expenseTint,
                                icon: Icons.pending_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          for (var i = 0; i < _installments.length; i++) ...[
                            LedgerCard(
                              row: LedgerRow(
                                id: _installments[i].id,
                                title: _installments[i].label ??
                                    'قسط ${i + 1}',
                                subtitle: _installments[i].dueDate != null
                                    ? 'الاستحقاق: ${_installments[i].dueDate}'
                                    : '—',
                                amount: _installments[i].amount,
                                accent: _installments[i].status == 'paid'
                                    ? c.teal
                                    : c.expenseTint,
                                badge: _installments[i].status == 'paid'
                                    ? 'مدفوع'
                                    : 'مستحق',
                              ),
                              onTap: _installments[i].status != 'paid'
                                  ? () => _markPaid(_installments[i].id)
                                  : null,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Future<void> _addInstallment() async {
    final label = TextEditingController();
    final amount = TextEditingController();
    DateTime due = DateTime.now().add(const Duration(days: 30));
    final ok = await showAtelierDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('قسط جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: label,
              decoration: const InputDecoration(labelText: 'الوصف *'),
            ),
            TextField(
              controller: amount,
              decoration: const InputDecoration(labelText: 'المبلغ *'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حفظ')),
        ],
      ),
    );
    if (ok != true || label.text.trim().isEmpty || amount.text.trim().isEmpty) {
      return;
    }
    try {
      await sl<ProjectOsApi>().createInstallment({
        'project_id': widget.projectId,
        'label': label.text.trim(),
        'amount': amount.text.trim(),
        'due_date': due.toIso8601String().substring(0, 10),
      });
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
