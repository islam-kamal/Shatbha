import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';
import '../../data/project_os_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Leads List Screen
// ─────────────────────────────────────────────────────────────────────────────

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  List<Lead> _leads = [];
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
      final leads = await sl<ProjectOsApi>().listLeads();
      if (!mounted) return;
      setState(() {
        _leads = leads;
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
        title: const ScreenTitle('العملاء المحتملون', subtitle: 'إدارة خط المبيعات'),
        toolbarHeight: 88,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/leads/add');
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة عميل'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _leads.isEmpty
                  ? StatusView.empty(
                      title: 'لا عملاء محتملون',
                      body: 'أضف أول عميل محتمل لبدء خط المبيعات.',
                      actionLabel: 'إضافة عميل',
                      onAction: () async {
                        await context.push('/leads/add');
                        _load();
                      },
                    )
                  : IvorySheet(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _leads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final lead = _leads[i];
                          return LedgerCard(
                            row: LedgerRow(
                              id: lead.id,
                              title: lead.name,
                              subtitle:
                                  '${_leadStatusLabel(lead.status)} · ${lead.phone ?? '—'} · ${lead.address ?? ''}',
                              amount: _leadSourceLabel(lead.source ?? ''),
                              accent: _leadStatusColor(lead.status, c),
                              badge: _leadStatusLabel(lead.status),
                            ),
                            onTap: () => context.push('/leads/${lead.id}'),
                          );
                        },
                      ),
                    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lead Form Screen (add / edit)
// ─────────────────────────────────────────────────────────────────────────────

class LeadFormScreen extends StatefulWidget {
  const LeadFormScreen({super.key, this.leadId});
  final int? leadId;

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  String _source = 'referral';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الاسم مطلوب')));
      return;
    }
    setState(() => _saving = true);
    try {
      final body = {
        'name': _name.text.trim(),
        if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
        if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
        'source': _source,
      };
      Lead lead;
      if (widget.leadId != null) {
        lead = await sl<ProjectOsApi>().updateLead(widget.leadId!, body);
      } else {
        lead = await sl<ProjectOsApi>().createLead(body);
      }
      if (!mounted) return;
      context.pop(lead);
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
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(
            widget.leadId != null ? 'تعديل العميل' : 'عميل محتمل جديد'),
        toolbarHeight: 76,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'الاسم *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _source,
              decoration: const InputDecoration(labelText: 'المصدر'),
              items: const [
                DropdownMenuItem(value: 'referral', child: Text('إحالة')),
                DropdownMenuItem(
                    value: 'social_media', child: Text('وسائل التواصل')),
                DropdownMenuItem(
                    value: 'website', child: Text('الموقع الإلكتروني')),
                DropdownMenuItem(
                    value: 'walk_in', child: Text('زيارة مباشرة')),
                DropdownMenuItem(value: 'other', child: Text('أخرى')),
              ],
              onChanged: (v) => setState(() => _source = v ?? 'referral'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
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

// ─────────────────────────────────────────────────────────────────────────────
// Lead Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

class LeadDetailScreen extends StatefulWidget {
  const LeadDetailScreen({super.key, required this.leadId});
  final int leadId;

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  Lead? _lead;
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
      final lead = await sl<ProjectOsApi>().getLead(widget.leadId);
      if (!mounted) return;
      setState(() {
        _lead = lead;
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

  Future<void> _updateStatus(String status) async {
    try {
      final updated =
          await sl<ProjectOsApi>().updateLead(widget.leadId, {'status': status});
      if (!mounted) return;
      setState(() => _lead = updated);
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    if (_loading && _lead == null) {
      return Scaffold(
        appBar: AppBar(title: const ScreenTitle('العميل المحتمل')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null && _lead == null) {
      return Scaffold(
        appBar: AppBar(title: const ScreenTitle('العميل المحتمل')),
        body: StatusView.error(body: _error!, onAction: _load),
      );
    }
    final lead = _lead!;
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(lead.name, subtitle: _leadStatusLabel(lead.status)),
        toolbarHeight: 88,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Status chip
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _leadStatusColor(lead.status, c)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _leadStatusColor(lead.status, c)
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    _leadStatusLabel(lead.status),
                    style: TextStyle(
                      color: _leadStatusColor(lead.status, c),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (lead.phone != null)
              _LeadDetailRow(label: 'الهاتف', value: lead.phone!),
            if (lead.address != null)
              _LeadDetailRow(label: 'العنوان', value: lead.address!),
            if (lead.source != null)
              _LeadDetailRow(
                  label: 'المصدر', value: _leadSourceLabel(lead.source!)),
            if (lead.notes != null && lead.notes!.isNotEmpty)
              _LeadDetailRow(label: 'ملاحظات', value: lead.notes!),
            const SizedBox(height: 16),
            const SectionLabel('الإجراءات'),
            IvoryMenuCard(
              children: [
                HubRow(
                  title: 'جدولة زيارة موقع',
                  icon: Icons.location_on_outlined,
                  onTap: () => _scheduleVisit(context),
                ),
                HubRow(
                  title: 'إنشاء عرض سعر',
                  icon: Icons.description_outlined,
                  onTap: () => _createProposal(context),
                ),
                HubRow(
                  title: 'معالج الإتمام',
                  subtitle: 'تحويل العميل لمشروع وعقد',
                  icon: Icons.flag_outlined,
                  onTap: () =>
                      context.push('/leads/${lead.id}/win-wizard'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SectionLabel('تحديث الحالة'),
            IvoryMenuCard(
              children: [
                for (final s in [
                  'new',
                  'contacted',
                  'site_visited',
                  'proposal_sent',
                  'won',
                  'lost'
                ])
                  HubRow(
                    title: _leadStatusLabel(s),
                    icon: lead.status == s
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    onTap: () {
                      if (lead.status != s) _updateStatus(s);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleVisit(BuildContext context) async {
    await showAtelierBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ScheduleVisitSheet(leadId: widget.leadId),
    );
  }

  Future<void> _createProposal(BuildContext context) async {
    await showAtelierBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CreateProposalSheet(leadId: widget.leadId),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet helpers
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleVisitSheet extends StatefulWidget {
  const _ScheduleVisitSheet({required this.leadId});
  final int leadId;

  @override
  State<_ScheduleVisitSheet> createState() => _ScheduleVisitSheetState();
}

class _ScheduleVisitSheetState extends State<_ScheduleVisitSheet> {
  final _notes = TextEditingController();
  DateTime? _scheduledAt;
  bool _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدد تاريخ الزيارة')));
      return;
    }
    setState(() => _saving = true);
    try {
      await sl<ProjectOsApi>().createSiteVisit({
        'lead_id': widget.leadId,
        'scheduled_at': _scheduledAt!.toIso8601String(),
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم جدولة الزيارة')));
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
          const Text('جدولة زيارة موقع',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _scheduledAt == null
                  ? 'اختر التاريخ'
                  : _scheduledAt!.toString().substring(0, 10),
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null && mounted) setState(() => _scheduledAt = d);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'ملاحظات'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          AtelierButton(
            label: _saving ? 'جاري الحفظ…' : 'جدولة الزيارة',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _CreateProposalSheet extends StatefulWidget {
  const _CreateProposalSheet({required this.leadId});
  final int leadId;

  @override
  State<_CreateProposalSheet> createState() => _CreateProposalSheetState();
}

class _CreateProposalSheetState extends State<_CreateProposalSheet> {
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_amount.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('أدخل المبلغ')));
      return;
    }
    setState(() => _saving = true);
    try {
      await sl<ProjectOsApi>().createProposal({
        'lead_id': widget.leadId,
        'total_amount': _amount.text.trim(),
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء عرض السعر')));
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
          const Text('إنشاء عرض سعر',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(labelText: 'الإجمالي *'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'ملاحظات'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          AtelierButton(
            label: _saving ? 'جاري الحفظ…' : 'إنشاء عرض السعر',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────────────────────────────────────────────

class _LeadDetailRow extends StatelessWidget {
  const _LeadDetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(color: c.stone.withValues(alpha: 0.6))),
          ),
          Expanded(
            child:
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

String _leadStatusLabel(String status) => switch (status) {
      'new' => 'جديد',
      'contacted' => 'تم التواصل',
      'site_visited' => 'تمت الزيارة',
      'proposal_sent' => 'عرض مُرسل',
      'won' => 'مكتسب',
      'lost' => 'خسارة',
      _ => status,
    };

String _leadSourceLabel(String source) => switch (source) {
      'referral' => 'إحالة',
      'social_media' => 'وسائل التواصل',
      'website' => 'الموقع الإلكتروني',
      'walk_in' => 'زيارة مباشرة',
      _ => source.isEmpty ? '—' : source,
    };

Color _leadStatusColor(String status, AtelierColors c) => switch (status) {
      'won' => c.teal,
      'lost' => c.terracotta,
      'proposal_sent' => c.brass,
      _ => c.dateTint,
    };
