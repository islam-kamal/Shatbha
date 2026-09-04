import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';

import '../../../project_os/data/project_os_api.dart';
import '../../../project_os/data/project_os_models.dart';
import '../../data/repositories/project_repository.dart';
import '../cubit/project_cubit.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectCubit(sl())..load(),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatelessWidget {
  const _ProjectsView();

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('المشاريع', subtitle: 'إدارة مشاريع التشطيب'),
        toolbarHeight: 88,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/projects/add');
          if (context.mounted) context.read<ProjectCubit>().load();
        },
        icon: const Icon(Icons.add),
        label: const Text('مشروع جديد'),
      ),
      body: BlocBuilder<ProjectCubit, ProjectState>(
        builder: (context, state) {
          if (state.loading && state.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.projects.isEmpty) {
            return StatusView.error(body: state.error!);
          }
          if (state.isEmpty) {
            return StatusView.empty(
              title: 'لا توجد مشاريع',
              body: 'أنشئ أول مشروع تشطيب لتتبع التصميم والمواد.',
              actionLabel: 'مشروع جديد',
              onAction: () => context.push('/projects/add'),
            );
          }
          return IvorySheet(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: state.projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = state.projects[i];
                return LedgerCard(
                  row: LedgerRow(
                    id: p.id,
                    title: p.name,
                    subtitle:
                        '${_statusLabel(p.status)} · ${p.clientName ?? '—'} · ${p.address ?? ''}',
                    amount: p.budget,
                    accent: c.brass,
                    badge: p.areaSqm != null ? '${p.areaSqm} م²' : null,
                  ),
                  onTap: () => context.push('/projects/${p.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectCubit(sl())..loadDetail(projectId),
      child: _ProjectDetailView(projectId: projectId),
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  const _ProjectDetailView({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        if (state.loading && state.selected == null) {
          return Scaffold(
            appBar: AppBar(title: const ScreenTitle('تفاصيل المشروع')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.error != null && state.selected == null) {
          return Scaffold(
            appBar: AppBar(title: const ScreenTitle('تفاصيل المشروع')),
            body: StatusView.error(body: state.error!),
          );
        }
        final p = state.selected!;
        return Scaffold(
          appBar: AppBar(
            title: ScreenTitle(p.name, subtitle: _statusLabel(p.status)),
            toolbarHeight: 88,
          ),
          body: IvorySheet(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // ── Lifecycle / next action / progress ───────────────────────
                _LifecycleSection(projectId: projectId),
                const SizedBox(height: 8),
                _ProjectFinancialSummary(projectId: projectId),
                const SizedBox(height: 16),
                if (p.clientName != null)
                  _DetailRow(label: 'العميل', value: p.clientName!),
                if (p.address != null)
                  _DetailRow(label: 'العنوان', value: p.address!),
                if (p.areaSqm != null)
                  _DetailRow(label: 'المساحة', value: '${p.areaSqm} م²'),
                _DetailRow(label: 'الميزانية', value: formatMoney(p.budget)),
                if (p.description != null && p.description!.isNotEmpty)
                  _DetailRow(label: 'الوصف', value: p.description!),
                const SizedBox(height: 16),
                const SectionLabel('أقسام المشروع'),
                IvoryMenuCard(
                  children: [
                    HubRow(
                      title: 'التصميم',
                      subtitle: 'لوحة الإلهام · مخططات · BOQ',
                      icon: Icons.palette_outlined,
                      onTap: () => context.push('/projects/$projectId/design'),
                    ),
                    HubRow(
                      title: 'اختيارات العميل',
                      subtitle: 'المواد والتشطيبات المختارة',
                      icon: Icons.checklist_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/selections'),
                    ),
                    HubRow(
                      title: 'أوامر التغيير',
                      subtitle: 'تعديلات وزيادات العقد',
                      icon: Icons.edit_note_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/change-orders'),
                    ),
                    HubRow(
                      title: 'إدارة المشروع',
                      subtitle: 'مهام · ميزانية · جدول · صور',
                      icon: Icons.view_timeline_outlined,
                      onTap: () => context.push('/projects/$projectId/pm'),
                    ),
                    HubRow(
                      title: 'المشتريات',
                      subtitle: 'أوامر شراء · استلام بضاعة',
                      icon: Icons.shopping_cart_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/procurement'),
                    ),
                    HubRow(
                      title: 'المخازن',
                      subtitle: 'مخزون · صرف · تحويل',
                      icon: Icons.warehouse_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/warehouse'),
                    ),
                    HubRow(
                      title: 'السجل اليومي',
                      subtitle: 'متابعة الموقع يوماً بيوم',
                      icon: Icons.today_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/daily-logs'),
                    ),
                    HubRow(
                      title: 'التسليم',
                      subtitle: 'قائمة فحص · عيوب · توقيع',
                      icon: Icons.key_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/handover'),
                    ),
                    HubRow(
                      title: 'خطة الدفع',
                      subtitle: 'الأقساط والمدفوعات',
                      icon: Icons.payments_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/payment-plan'),
                    ),
                    HubRow(
                      title: 'الضمان',
                      subtitle: 'بلاغات ما بعد التسليم',
                      icon: Icons.verified_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/warranty'),
                    ),
                    HubRow(
                      title: 'مواد المشروع',
                      subtitle: 'قائمة المواد والتوريد',
                      icon: Icons.inventory_2_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/materials'),
                    ),
                    HubRow(
                      title: 'طلبات عروض',
                      subtitle: 'عروض المقاولين',
                      icon: Icons.request_quote_outlined,
                      onTap: () =>
                          context.push('/quotes?project_id=$projectId'),
                    ),
                    HubRow(
                      title: 'فريق المشروع',
                      subtitle: 'أعضاء · دعوة عميل',
                      icon: Icons.groups_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/team'),
                    ),
                    HubRow(
                      title: 'الطلبات',
                      subtitle: 'موافقات ومتابعة',
                      icon: Icons.assignment_turned_in_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/requests'),
                    ),
                    HubRow(
                      title: 'سجل المراجعة',
                      subtitle: 'تاريخ الأحداث والتعديلات',
                      icon: Icons.history_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/audit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lifecycle Section — lifecycle status chip + next action CTA + progress strips
// ─────────────────────────────────────────────────────────────────────────────

class _LifecycleSection extends StatefulWidget {
  const _LifecycleSection({required this.projectId});
  final int projectId;

  @override
  State<_LifecycleSection> createState() => _LifecycleSectionState();
}

class _LifecycleSectionState extends State<_LifecycleSection> {
  ProjectLifecycle? _lifecycle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final lc = await sl<ProjectOsApi>().getLifecycle(widget.projectId);
      if (!mounted) return;
      setState(() {
        _lifecycle = lc;
        _loading = false;
      });
    } on Failure {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      );
    }
    if (_lifecycle == null) return const SizedBox.shrink();
    final lc = _lifecycle!;
    final c = context.atelier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status chip + gate message
        Row(
          children: [
            _LifecycleChip(status: lc.lifecycleStatus, c: c),
            if (!lc.executionUnlocked) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.terracotta.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: c.terracotta.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    'التنفيذ مغلق — أكمل التصميم والعقد أولاً',
                    style: TextStyle(
                        color: c.terracotta,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
        // Next action CTA
        if (lc.nextAction != null) ...[
          const SizedBox(height: 10),
          Material(
            color: c.brass.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: lc.nextActionRoute != null
                  ? () => context.push(lc.nextActionRoute!)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: c.brass, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lc.nextAction!,
                        style: TextStyle(
                          color: c.stone,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (lc.nextActionRoute != null)
                      Icon(Icons.chevron_left, color: c.stone.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
          ),
        ],
        // Progress strips
        const SizedBox(height: 12),
        _ProgressStrip(label: 'التصميم', progress: lc.designProgress, color: c.teal),
        const SizedBox(height: 6),
        _ProgressStrip(
            label: 'المشتريات',
            progress: lc.procurementProgress,
            color: c.brass),
        const SizedBox(height: 6),
        _ProgressStrip(
            label: 'التنفيذ',
            progress: lc.executionProgress,
            color: lc.executionUnlocked ? c.teal : c.stone.withValues(alpha: 0.3)),
        const SizedBox(height: 6),
        _ProgressStrip(
            label: 'المالية',
            progress: lc.financeProgress,
            color: c.expenseTint),
      ],
    );
  }
}

class _LifecycleChip extends StatelessWidget {
  const _LifecycleChip({required this.status, required this.c});
  final String status;
  final AtelierColors c;

  @override
  Widget build(BuildContext context) {
    final color = _lifecycleColor(status, c);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        _lifecycleLabel(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({
    required this.label,
    required this.progress,
    required this.color,
  });
  final String label;
  final int progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final pct = (progress / 100).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: c.stone.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: c.stone.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '$progress%',
            textAlign: TextAlign.end,
            style: TextStyle(
                fontSize: 11,
                color: c.stone.withValues(alpha: 0.65),
                fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

String _lifecycleLabel(String status) => switch (status) {
      'planning' => 'تخطيط',
      'design' => 'تصميم',
      'procurement' => 'مشتريات',
      'execution' => 'تنفيذ',
      'handover' => 'تسليم',
      'warranty' => 'ضمان',
      'completed' => 'مكتمل',
      _ => status,
    };

Color _lifecycleColor(String status, AtelierColors c) => switch (status) {
      'execution' || 'handover' => c.teal,
      'completed' => c.teal,
      'procurement' => c.brass,
      _ => c.dateTint,
    };

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _budget = TextEditingController();
  final _area = TextEditingController();
  final _description = TextEditingController();
  int? _customerId;
  String? _customerName;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _budget.dispose();
    _area.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final picked =
        await context.push<Map<String, dynamic>>('/customers/picker?return=1');
    if (picked == null) return;
    setState(() {
      _customerId = picked['id'] as int?;
      _customerName = picked['name'] as String?;
    });
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر العميل')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final project = await sl<ProjectRepository>().create({
        'title': _name.text.trim(),
        'customer_id': _customerId,
        if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
        if (_budget.text.trim().isNotEmpty) 'budget': _budget.text.trim(),
        if (_area.text.trim().isNotEmpty) 'area_sqm': _area.text.trim(),
        if (_description.text.trim().isNotEmpty)
          'description': _description.text.trim(),
        'status': 'planning',
      });
      if (!mounted) return;
      context.pop(project);
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
        title: const ScreenTitle('مشروع جديد'),
        toolbarHeight: 76,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'اسم المشروع *'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_customerName ?? 'اختر العميل *'),
              subtitle: _customerId == null
                  ? const Text('مطلوب لربط حساب العميل')
                  : Text('#$_customerId'),
              trailing: const Icon(Icons.chevron_left),
              onTap: _pickCustomer,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _area,
              decoration: const InputDecoration(labelText: 'المساحة م²'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _budget,
              decoration: const InputDecoration(labelText: 'الميزانية'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'الوصف'),
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

class _ProjectFinancialSummary extends StatefulWidget {
  const _ProjectFinancialSummary({required this.projectId});
  final int projectId;

  @override
  State<_ProjectFinancialSummary> createState() =>
      _ProjectFinancialSummaryState();
}

class _ProjectFinancialSummaryState extends State<_ProjectFinancialSummary> {
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data =
          await sl<ProjectRepository>().financialSummary(widget.projectId);
      if (!mounted) return;
      setState(() {
        _summary = data;
        _loading = false;
      });
    } on Failure {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      );
    }
    if (_summary == null) return const SizedBox.shrink();
    final s = _summary!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('الملخص المالي'),
        KpiStrip(
          items: [
            KpiItem(
              'الميزانية',
              _money(s['budget'] ?? s['planned_total']),
              tint: c.dateTint,
              icon: Icons.account_balance_outlined,
            ),
            KpiItem(
              'الفعلي',
              _money(s['actual_total'] ?? s['spent']),
              tint: c.expenseTint,
              icon: Icons.payments_outlined,
            ),
            KpiItem(
              'المتبقي',
              _money(s['remaining'] ?? s['balance']),
              tint: c.calculatedTint,
              icon: Icons.savings_outlined,
            ),
          ],
        ),
      ],
    );
  }

  String _money(dynamic value) {
    if (value == null) return '—';
    return value.toString();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
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
            child: Text(
              label,
              style: TextStyle(color: c.stone.withValues(alpha: 0.6)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'planning':
    case 'draft':
      return 'تخطيط';
    case 'active':
    case 'in_progress':
      return 'قيد التنفيذ';
    case 'delivered':
      return 'تسليم';
    case 'handed_over':
    case 'completed':
      return 'مكتمل';
    default:
      return status;
  }
}