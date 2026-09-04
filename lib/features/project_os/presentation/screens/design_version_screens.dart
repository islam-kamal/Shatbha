import 'package:flutter/material.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';
import '../../data/project_os_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design Versions Screen
// Shows revision history with submit / approve / reject actions (company view).
// ─────────────────────────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('إصدارات التصميم',
            subtitle: 'سجل المراجعات والاعتمادات'),
        toolbarHeight: 88,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _versions.isEmpty
                  ? const StatusView.empty(
                      title: 'لا إصدارات',
                      body: 'لم يُرفع أي إصدار تصميم بعد.',
                    )
                  : IvorySheet(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: _versions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final v = _versions[i];
                          return LedgerCard(
                            row: LedgerRow(
                              id: v.id,
                              title:
                                  'الإصدار ${v.versionNumber}',
                              subtitle: v.notes ?? '—',
                              amount: _dvStatusLabel(v.status),
                              accent: _dvStatusColor(v.status, c),
                              badge: _dvStatusLabel(v.status),
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
