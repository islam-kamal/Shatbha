import 'package:flutter/material.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';
import '../../data/project_os_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Audit Screen
// ─────────────────────────────────────────────────────────────────────────────

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  List<AuditEvent> _events = [];
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
      final items = await sl<ProjectOsApi>().listAudit(widget.projectId);
      if (!mounted) return;
      setState(() {
        _events = items;
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
        title:
            const ScreenTitle('سجل المراجعة', subtitle: 'تاريخ الأحداث'),
        toolbarHeight: 88,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _events.isEmpty
                  ? const StatusView.empty(
                      title: 'لا أحداث',
                      body:
                          'لم تُسجَّل أحداث مراجعة لهذا المشروع بعد.')
                  : IvorySheet(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: _events.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final event = _events[i];
                          return SheetCard(
                            child: ListTile(
                              leading: Icon(Icons.history, color: c.brass),
                              title: Text(
                                event.event ?? '—',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                [
                                  if (event.description != null)
                                    event.description!,
                                  if (event.causedBy != null)
                                    'بواسطة: ${event.causedBy}',
                                  if (event.createdAt != null)
                                    event.createdAt!.length >= 10
                                        ? event.createdAt!.substring(0, 10)
                                        : event.createdAt!,
                                ].join(' · '),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
