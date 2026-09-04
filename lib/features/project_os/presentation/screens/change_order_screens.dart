import 'package:flutter/material.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';
import '../../data/project_os_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Change Orders Screen
// ─────────────────────────────────────────────────────────────────────────────

class ChangeOrdersScreen extends StatefulWidget {
  const ChangeOrdersScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<ChangeOrdersScreen> createState() => _ChangeOrdersScreenState();
}

class _ChangeOrdersScreenState extends State<ChangeOrdersScreen> {
  List<ChangeOrder> _orders = [];
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
          await sl<ProjectOsApi>().listChangeOrders(widget.projectId);
      if (!mounted) return;
      setState(() {
        _orders = items;
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

  Future<void> _approve(int id) async {
    try {
      final updated = await sl<ProjectOsApi>().approveChangeOrder(id);
      if (!mounted) return;
      setState(() {
        _orders = _orders.map((o) => o.id == id ? updated : o).toList();
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
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('أوامر التغيير',
            subtitle: 'تعديلات وزيادات العقد'),
        toolbarHeight: 88,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showAtelierBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) =>
                _AddChangeOrderSheet(projectId: widget.projectId),
          );
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('أمر تغيير'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _orders.isEmpty
                  ? const StatusView.empty(
                      title: 'لا أوامر تغيير',
                      body:
                          'لم يُسجَّل أي تغيير على هذا المشروع.')
                  : IvorySheet(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _orders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final o = _orders[i];
                          return LedgerCard(
                            row: LedgerRow(
                              id: o.id,
                              title: o.title,
                              subtitle: o.description ?? '—',
                              amount: o.amount,
                              accent: _coStatusColor(o.status, c),
                              badge: _coStatusLabel(o.status),
                            ),
                            onTap: o.status == 'pending'
                                ? () => _approve(o.id)
                                : null,
                          );
                        },
                      ),
                    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Change Order Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddChangeOrderSheet extends StatefulWidget {
  const _AddChangeOrderSheet({required this.projectId});
  final int projectId;

  @override
  State<_AddChangeOrderSheet> createState() => _AddChangeOrderSheetState();
}

class _AddChangeOrderSheetState extends State<_AddChangeOrderSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _amount = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('العنوان مطلوب')));
      return;
    }
    setState(() => _saving = true);
    try {
      await sl<ProjectOsApi>().createChangeOrder({
        'project_id': widget.projectId,
        'title': _title.text.trim(),
        if (_description.text.trim().isNotEmpty)
          'description': _description.text.trim(),
        if (_amount.text.trim().isNotEmpty) 'amount': _amount.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('أمر تغيير جديد',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'العنوان *'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'الوصف'),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(labelText: 'المبلغ'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AtelierButton(
            label: _saving ? 'جاري الحفظ…' : 'حفظ',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

String _coStatusLabel(String status) => switch (status) {
      'approved' => 'معتمد',
      'rejected' => 'مرفوض',
      _ => 'بانتظار',
    };

Color _coStatusColor(String status, AtelierColors c) => switch (status) {
      'approved' => c.teal,
      'rejected' => c.terracotta,
      _ => c.brass,
    };
