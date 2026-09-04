import 'package:flutter/material.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';
import '../../data/project_os_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Selections Screen (company & client view)
// ─────────────────────────────────────────────────────────────────────────────

class SelectionsScreen extends StatefulWidget {
  const SelectionsScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<SelectionsScreen> createState() => _SelectionsScreenState();
}

class _SelectionsScreenState extends State<SelectionsScreen> {
  List<ClientSelection> _selections = [];
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
      final items = await sl<ProjectOsApi>().listSelections(widget.projectId);
      if (!mounted) return;
      setState(() {
        _selections = items;
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
      final updated = await sl<ProjectOsApi>().approveSelection(id);
      if (!mounted) return;
      setState(() {
        _selections =
            _selections.map((s) => s.id == id ? updated : s).toList();
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
        title: const ScreenTitle('اختيارات العميل',
            subtitle: 'المواد والتشطيبات'),
        toolbarHeight: 88,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showAtelierBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => _AddSelectionSheet(projectId: widget.projectId),
          );
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('اختيار جديد'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _selections.isEmpty
                  ? const StatusView.empty(
                      title: 'لا اختيارات',
                      body:
                          'أضف اختيارات العميل للمواد والتشطيبات.')
                  : IvorySheet(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _selections.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final s = _selections[i];
                          return SheetCard(
                            child: ListTile(
                              title: Text(
                                s.itemName ?? s.category,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                  '${s.category} · ${_selStatusLabel(s.status)}'),
                              trailing: s.status == 'pending'
                                  ? FilledButton.tonal(
                                      onPressed: () => _approve(s.id),
                                      child: const Text('اعتماد'),
                                    )
                                  : Icon(
                                      s.status == 'approved'
                                          ? Icons.check_circle_outline
                                          : Icons.cancel_outlined,
                                      color: s.status == 'approved'
                                          ? c.teal
                                          : c.terracotta,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add selection sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddSelectionSheet extends StatefulWidget {
  const _AddSelectionSheet({required this.projectId});
  final int projectId;

  @override
  State<_AddSelectionSheet> createState() => _AddSelectionSheetState();
}

class _AddSelectionSheetState extends State<_AddSelectionSheet> {
  final _category = TextEditingController();
  final _itemName = TextEditingController();
  final _clientNote = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _category.dispose();
    _itemName.dispose();
    _clientNote.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_category.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الفئة مطلوبة')));
      return;
    }
    setState(() => _saving = true);
    try {
      await sl<ProjectOsApi>().createSelection({
        'project_id': widget.projectId,
        'category': _category.text.trim(),
        if (_itemName.text.trim().isNotEmpty)
          'item_name': _itemName.text.trim(),
        if (_clientNote.text.trim().isNotEmpty)
          'client_note': _clientNote.text.trim(),
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
          const Text('اختيار جديد',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 12),
          TextField(
            controller: _category,
            decoration: const InputDecoration(labelText: 'الفئة *'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _itemName,
            decoration: const InputDecoration(labelText: 'اسم الصنف'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _clientNote,
            decoration:
                const InputDecoration(labelText: 'ملاحظة العميل'),
            maxLines: 2,
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

String _selStatusLabel(String status) => switch (status) {
      'approved' => 'معتمد',
      'rejected' => 'مرفوض',
      _ => 'بانتظار الاعتماد',
    };
