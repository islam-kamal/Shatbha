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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _installments.isEmpty
                  ? const StatusView.empty(
                      title: 'لا أقساط',
                      body: 'لم تُحدَّد خطة دفع لهذا المشروع.')
                  : IvorySheet(
                      child: ListView(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
}
