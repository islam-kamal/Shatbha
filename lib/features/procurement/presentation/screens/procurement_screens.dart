import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/procurement/data/repositories/procurement_repository.dart';

import '../cubit/procurement_cubit.dart';

class ProcurementListScreen extends StatelessWidget {
  const ProcurementListScreen({super.key, this.projectId});
  final int? projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProcurementCubit(sl())..load(projectId: projectId),
      child: _ProcurementListView(projectId: projectId),
    );
  }
}

class _ProcurementListView extends StatelessWidget {
  const _ProcurementListView({this.projectId});
  final int? projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(
          'أوامر الشراء',
          subtitle: projectId != null ? 'مشروع #$projectId' : 'المشتريات',
        ),
        toolbarHeight: 88,
      ),
      body: BlocBuilder<ProcurementCubit, ProcurementState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.orders.isEmpty) {
            return StatusView.error(
              body: state.error!,
              onAction: () =>
                  context.read<ProcurementCubit>().load(projectId: projectId),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: KpiStrip(
                  items: [
                    KpiItem(
                      'معلق',
                      state.pendingTotal.toStringAsFixed(2),
                      tint: c.expenseTint,
                      icon: Icons.pending_actions_outlined,
                    ),
                    KpiItem(
                      'أوامر',
                      state.orders.length.toString(),
                      tint: c.dateTint,
                      icon: Icons.receipt_long_outlined,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.orders.isEmpty
                    ? StatusView.empty(
                        title: 'لا أوامر شراء',
                        body: 'أنشئ أمر شراء من مواد المشروع.',
                        actionLabel: 'أمر جديد',
                        onAction: () => _openCreate(context),
                      )
                    : IvorySheet(
                        child: LedgerList(
                          rows: [
                            for (final po in state.orders)
                              LedgerRow(
                                id: po.id,
                                title: po.poNumber ?? 'PO #${po.id}',
                                subtitle: [
                                  if (po.vendorName != null) po.vendorName,
                                  if (po.projectName != null) po.projectName,
                                  _statusLabel(po.status),
                                ].whereType<String>().join(' · '),
                                amount: po.total,
                                accent: po.status == 'received' ? c.teal : c.brass,
                                badge: _statusLabel(po.status),
                              ),
                          ],
                          onTap: (row) => context.push(
                            '/procurement/${row.id}/receive',
                          ),
                        ),
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: AtelierButton(
                    label: 'أمر شراء جديد',
                    icon: Icons.add_shopping_cart,
                    onPressed: () => _openCreate(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openCreate(BuildContext context) {
    final path = projectId != null
        ? '/procurement/add?projectId=$projectId'
        : '/procurement/add';
    context.push(path).then((_) {
      if (context.mounted) {
        context.read<ProcurementCubit>().load(projectId: projectId);
      }
    });
  }

  String _statusLabel(String status) => switch (status) {
        'received' => 'مستلم',
        'ordered' => 'مُرسَل',
        'draft' => 'مسودة',
        _ => status,
      };
}

class CreatePurchaseOrderScreen extends StatefulWidget {
  const CreatePurchaseOrderScreen({super.key, this.projectId});
  final int? projectId;

  @override
  State<CreatePurchaseOrderScreen> createState() =>
      _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState extends State<CreatePurchaseOrderScreen> {
  final _vendorId = TextEditingController();
  final _notes = TextEditingController();
  final _lines = <Map<String, String>>[
    {'description': '', 'quantity': '1', 'unit_price': '0'},
  ];
  bool _saving = false;

  @override
  void dispose() {
    _vendorId.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await sl<ProcurementRepository>().create({
        if (widget.projectId != null) 'project_id': widget.projectId,
        if (_vendorId.text.trim().isNotEmpty)
          'vendor_id': int.parse(_vendorId.text.trim()),
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
        'lines': [
          for (final line in _lines)
            if (line['description']!.trim().isNotEmpty)
              {
                'description': line['description']!.trim(),
                'quantity': line['quantity']!.trim(),
                'unit_price': line['unit_price']!.trim(),
              },
        ],
      });
      if (!mounted) return;
      await showAtelierSuccess(context, body: 'تم إنشاء أمر الشراء');
      if (!mounted) return;
      context.pop();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('أمر شراء جديد', subtitle: 'من مواد المشروع'),
        toolbarHeight: 88,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.projectId != null)
            FieldLabel('مشروع #${widget.projectId}'),
          const FieldLabel('رقم المورد'),
          TextField(
            controller: _vendorId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'معرف المورد'),
          ),
          const SizedBox(height: 16),
          const FieldLabel('البنود'),
          for (var i = 0; i < _lines.length; i++) ...[
            TextField(
              decoration: InputDecoration(labelText: 'وصف البند ${i + 1}'),
              onChanged: (v) => _lines[i]['description'] = v,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'الكمية'),
                    onChanged: (v) => _lines[i]['quantity'] = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'السعر'),
                    onChanged: (v) => _lines[i]['unit_price'] = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          AtelierButton(
            label: 'إضافة بند',
            kind: AtelierButtonKind.secondary,
            onPressed: () => setState(() {
              _lines.add({'description': '', 'quantity': '1', 'unit_price': '0'});
            }),
          ),
          const SizedBox(height: 16),
          const FieldLabel('ملاحظات'),
          TextField(controller: _notes, maxLines: 2),
          const SizedBox(height: 24),
          AtelierButton(
            label: _saving ? 'جاري الحفظ…' : 'حفظ أمر الشراء',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class ReceiveGoodsScreen extends StatefulWidget {
  const ReceiveGoodsScreen({super.key, required this.poId});
  final int poId;

  @override
  State<ReceiveGoodsScreen> createState() => _ReceiveGoodsScreenState();
}

class _ReceiveGoodsScreenState extends State<ReceiveGoodsScreen> {
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _receive() async {
    setState(() => _saving = true);
    try {
      await sl<ProcurementRepository>().receive(widget.poId, {
        'notes': _notes.text.trim(),
        'received_at': formatDate(DateTime.now()),
      });
      if (!mounted) return;
      await showAtelierSuccess(context, body: 'تم استلام البضاعة');
      if (!mounted) return;
      context.pop();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle('استلام بضاعة', subtitle: 'PO #${widget.poId}'),
        toolbarHeight: 88,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FieldLabel('ملاحظات الاستلام'),
            TextField(controller: _notes, maxLines: 3),
            const Spacer(),
            AtelierButton(
              label: _saving ? 'جاري الاستلام…' : 'تأكيد الاستلام',
              icon: Icons.inventory_2_outlined,
              onPressed: _saving ? null : _receive,
            ),
            const SafeArea(top: false, child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
