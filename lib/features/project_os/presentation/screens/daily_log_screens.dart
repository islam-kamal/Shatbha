import 'package:flutter/material.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';
import '../../data/project_os_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Daily Logs Screen
// ─────────────────────────────────────────────────────────────────────────────

class DailyLogsScreen extends StatefulWidget {
  const DailyLogsScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<DailyLogsScreen> createState() => _DailyLogsScreenState();
}

class _DailyLogsScreenState extends State<DailyLogsScreen> {
  List<DailySiteLog> _logs = [];
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
      final items = await sl<ProjectOsApi>().listDailyLogs(widget.projectId);
      if (!mounted) return;
      setState(() {
        _logs = items;
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
            const ScreenTitle('السجل اليومي', subtitle: 'متابعة الموقع'),
        toolbarHeight: 88,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showAtelierBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => _AddDailyLogSheet(projectId: widget.projectId),
          );
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('تسجيل يومي'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _logs.isEmpty
                  ? const StatusView.empty(
                      title: 'لا سجلات',
                      body: 'سجّل أول تقرير يومي للموقع.')
                  : IvorySheet(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _logs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final log = _logs[i];
                          return SheetCard(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        log.logDate,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
                                      ),
                                      const Spacer(),
                                      if (log.workersOnSite != null)
                                        Text(
                                          '${log.workersOnSite} عامل',
                                          style: TextStyle(
                                              color: c.teal, fontSize: 13),
                                        ),
                                    ],
                                  ),
                                  if (log.summary != null) ...[
                                    const SizedBox(height: 6),
                                    Text(log.summary!,
                                        style:
                                            const TextStyle(fontSize: 13)),
                                  ],
                                  if (log.weatherCondition != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'الطقس: ${log.weatherCondition}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: c.stone
                                              .withValues(alpha: 0.6)),
                                    ),
                                  ],
                                  if (log.progressNotes != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      log.progressNotes!,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: c.stone
                                              .withValues(alpha: 0.7)),
                                    ),
                                  ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Add Daily Log Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddDailyLogSheet extends StatefulWidget {
  const _AddDailyLogSheet({required this.projectId});
  final int projectId;

  @override
  State<_AddDailyLogSheet> createState() => _AddDailyLogSheetState();
}

class _AddDailyLogSheetState extends State<_AddDailyLogSheet> {
  final _summary = TextEditingController();
  final _weather = TextEditingController();
  final _workers = TextEditingController();
  final _notes = TextEditingController();
  DateTime _logDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _summary.dispose();
    _weather.dispose();
    _workers.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await sl<ProjectOsApi>().createDailyLog({
        'project_id': widget.projectId,
        'log_date': _logDate.toIso8601String().substring(0, 10),
        if (_summary.text.trim().isNotEmpty)
          'summary': _summary.text.trim(),
        if (_weather.text.trim().isNotEmpty)
          'weather_condition': _weather.text.trim(),
        if (_workers.text.trim().isNotEmpty)
          'workers_on_site': int.tryParse(_workers.text.trim()),
        if (_notes.text.trim().isNotEmpty)
          'progress_notes': _notes.text.trim(),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('تسجيل يومي جديد',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                  'التاريخ: ${_logDate.toIso8601String().substring(0, 10)}'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _logDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null && mounted) setState(() => _logDate = d);
              },
            ),
            TextField(
              controller: _summary,
              decoration:
                  const InputDecoration(labelText: 'ملخص اليوم'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weather,
              decoration:
                  const InputDecoration(labelText: 'حالة الطقس'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _workers,
              decoration:
                  const InputDecoration(labelText: 'عدد العمال'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notes,
              decoration:
                  const InputDecoration(labelText: 'ملاحظات التقدم'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            AtelierButton(
              label: _saving ? 'جاري الحفظ…' : 'حفظ',
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
