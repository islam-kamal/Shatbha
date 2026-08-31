import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';

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
                      title: 'إدارة المشروع',
                      subtitle: 'مهام · ميزانية · جدول · صور',
                      icon: Icons.view_timeline_outlined,
                      onTap: () => context.push('/projects/$projectId/pm'),
                    ),
                    HubRow(
                      title: 'المشتريات',
                      subtitle: 'أوامر شراء · استلام بضاعة',
                      icon: Icons.shopping_cart_outlined,
                      onTap: () => context.push('/projects/$projectId/procurement'),
                    ),
                    HubRow(
                      title: 'المخازن',
                      subtitle: 'مخزون · صرف · تحويل',
                      icon: Icons.warehouse_outlined,
                      onTap: () => context.push('/projects/$projectId/warehouse'),
                    ),
                    HubRow(
                      title: 'التسليم',
                      subtitle: 'قائمة فحص · عيوب · توقيع',
                      icon: Icons.key_outlined,
                      onTap: () => context.push('/projects/$projectId/handover'),
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
                      onTap: () => context.push('/quotes?project_id=$projectId'),
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

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _name = TextEditingController();
  final _client = TextEditingController();
  final _address = TextEditingController();
  final _budget = TextEditingController();
  final _area = TextEditingController();
  final _description = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _client.dispose();
    _address.dispose();
    _budget.dispose();
    _area.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final project = await sl<ProjectRepository>().create({
        'title': _name.text.trim(),
        if (_client.text.trim().isNotEmpty) 'client_name': _client.text.trim(),
        if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
        if (_budget.text.trim().isNotEmpty) 'budget': _budget.text.trim(),
        if (_area.text.trim().isNotEmpty) 'area_sqm': _area.text.trim(),
        if (_description.text.trim().isNotEmpty)
          'description': _description.text.trim(),
        'status': 'draft',
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
            TextField(
              controller: _client,
              decoration: const InputDecoration(labelText: 'اسم العميل'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _area,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المساحة (م²)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'الميزانية'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
            const SizedBox(height: 24),
            AtelierButton(
              label: _saving ? 'جاري الحفظ...' : 'حفظ المشروع',
              icon: Icons.check,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
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
    case 'active':
    case 'in_progress':
      return 'نشط';
    case 'completed':
      return 'مكتمل';
    case 'draft':
      return 'مسودة';
    default:
      return status;
  }
}