import 'package:flutter/material.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';
import '../../data/project_os_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Warranty Screen
// ─────────────────────────────────────────────────────────────────────────────

class WarrantyScreen extends StatefulWidget {
  const WarrantyScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _WarrantyScreenState extends State<WarrantyScreen> {
  List<WarrantyClaim> _claims = [];
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
          await sl<ProjectOsApi>().listWarrantyClaims(widget.projectId);
      if (!mounted) return;
      setState(() {
        _claims = items;
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

  Future<void> _resolve(int id) async {
    try {
      final updated = await sl<ProjectOsApi>().resolveWarrantyClaim(id);
      if (!mounted) return;
      setState(() {
        _claims = _claims.map((c) => c.id == id ? updated : c).toList();
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
        title: const ScreenTitle('الضمان', subtitle: 'بلاغات ما بعد التسليم'),
        toolbarHeight: 88,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showAtelierBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => _AddWarrantySheet(projectId: widget.projectId),
          );
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('بلاغ ضمان'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _claims.isEmpty
                  ? const StatusView.empty(
                      title: 'لا بلاغات',
                      body: 'لم يُسجَّل أي بلاغ ضمان لهذا المشروع.')
                  : IvorySheet(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _claims.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final claim = _claims[i];
                          return LedgerCard(
                            row: LedgerRow(
                              id: claim.id,
                              title: claim.title,
                              subtitle: claim.description ?? '—',
                              amount: _warrantyStatusLabel(claim.status),
                              accent: claim.status == 'open'
                                  ? c.terracotta
                                  : c.teal,
                              badge:
                                  claim.status == 'open' ? 'مفتوح' : 'محلول',
                            ),
                            onTap: claim.status == 'open'
                                ? () => _resolve(claim.id)
                                : null,
                          );
                        },
                      ),
                    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Warranty Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddWarrantySheet extends StatefulWidget {
  const _AddWarrantySheet({required this.projectId});
  final int projectId;

  @override
  State<_AddWarrantySheet> createState() => _AddWarrantySheetState();
}

class _AddWarrantySheetState extends State<_AddWarrantySheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
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
      await sl<ProjectOsApi>().createWarrantyClaim({
        'project_id': widget.projectId,
        'title': _title.text.trim(),
        if (_description.text.trim().isNotEmpty)
          'description': _description.text.trim(),
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
          const Text('بلاغ ضمان جديد',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration:
                const InputDecoration(labelText: 'عنوان البلاغ *'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'الوصف'),
            maxLines: 3,
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

String _warrantyStatusLabel(String status) => switch (status) {
      'resolved' => 'تم الحل',
      'in_progress' => 'قيد المعالجة',
      _ => 'مفتوح',
    };
