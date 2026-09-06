import 'package:flutter/material.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';
import '../../data/project_os_models.dart';

class DesignVersionsScreen extends StatefulWidget {
  const DesignVersionsScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<DesignVersionsScreen> createState() => _DesignVersionsScreenState();
}

class _DesignVersionsScreenState extends State<DesignVersionsScreen> {
  List<DesignVersion> _versions = [];
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
          await sl<ProjectOsApi>().listDesignVersions(widget.projectId);
      if (!mounted) return;
      setState(() {
        _versions = items;
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

  Future<void> _createDraft() async {
    try {
      await sl<ProjectOsApi>().createDesignVersion({
        'project_id': widget.projectId,
        'notes': 'مسودة جديدة',
      });
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _submit(int id) async {
    try {
      await sl<ProjectOsApi>().submitDesignVersion(id);
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _approve(int id) async {
    try {
      await sl<ProjectOsApi>().approveDesignVersion(id);
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _reject(int id) async {
    try {
      await sl<ProjectOsApi>().rejectDesignVersion(id, reason: 'طلب تعديلات');
      await _load();
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
        title: const ScreenTitle('إصدارات التصميم',
            subtitle: 'سجل المراجعات والاعتمادات'),
        toolbarHeight: 88,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createDraft,
        icon: const Icon(Icons.add),
        label: const Text('مسودة جديدة'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _versions.isEmpty
                  ? const StatusView.empty(
                      title: 'لا إصدارات',
                      body: 'أنشئ مسودة تصميم ثم أرسلها للعميل.',
                    )
                  : IvorySheet(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _versions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final v = _versions[i];
                          return SheetCard(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'الإصدار ${v.versionNumber}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Text(
                                        _dvStatusLabel(v.status),
                                        style: TextStyle(
                                          color: _dvStatusColor(v.status, c),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ((v.notes ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(v.notes!),
                                  ],
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (v.status == 'draft')
                                        TextButton(
                                          onPressed: () => _submit(v.id),
                                          child: const Text('إرسال للعميل'),
                                        ),
                                      if (v.status == 'submitted') ...[
                                        TextButton(
                                          onPressed: () => _approve(v.id),
                                          child: const Text('اعتماد'),
                                        ),
                                        TextButton(
                                          onPressed: () => _reject(v.id),
                                          child: const Text('رفض'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

String _dvStatusLabel(String status) => switch (status) {
      'approved' => 'معتمد',
      'rejected' => 'مرفوض',
      'submitted' => 'مُرسل للاعتماد',
      _ => 'مسودة',
    };

Color _dvStatusColor(String status, AtelierColors c) => switch (status) {
      'approved' => c.teal,
      'rejected' => c.terracotta,
      'submitted' => c.brass,
      _ => c.dateTint,
    };
