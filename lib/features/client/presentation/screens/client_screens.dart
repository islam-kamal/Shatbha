import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';

import '../cubit/client_cubit.dart';

class ClientProjectsScreen extends StatelessWidget {
  const ClientProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientCubit(sl())..loadProjects(),
      child: const _ClientProjectsView(),
    );
  }
}

class _ClientProjectsView extends StatelessWidget {
  const _ClientProjectsView();

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('مشاريعي', subtitle: 'متابعة التشطيب'),
        toolbarHeight: 88,
      ),
      body: BlocBuilder<ClientCubit, ClientState>(
        builder: (context, state) {
          if (state.loading && state.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.projects.isEmpty) {
            return StatusView.error(
              body: state.error!,
              onAction: () => context.read<ClientCubit>().loadProjects(),
            );
          }
          if (state.projects.isEmpty) {
            return const StatusView.empty(
              title: 'لا مشاريع',
              body: 'لا توجد مشاريع مرتبطة بحسابك حالياً.',
            );
          }
          return IvorySheet(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: state.projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = state.projects[i];
                return LedgerCard(
                  row: LedgerRow(
                    id: p.id,
                    title: p.name,
                    subtitle: '${_statusLabel(p.status)} · ${p.address ?? ''}',
                    amount: p.budget,
                    accent: c.teal,
                    badge: '${p.progressPercent}%',
                  ),
                  onTap: () => context.push('/client/projects/${p.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ClientProjectDetailScreen extends StatelessWidget {
  const ClientProjectDetailScreen({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientCubit(sl())..loadProject(projectId),
      child: _ClientProjectDetailView(projectId: projectId),
    );
  }
}

class _ClientProjectDetailView extends StatelessWidget {
  const _ClientProjectDetailView({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return BlocBuilder<ClientCubit, ClientState>(
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
                KpiStrip(
                  items: [
                    KpiItem(
                      'التقدم',
                      '${p.progressPercent}%',
                      tint: c.teal,
                      icon: Icons.trending_up,
                    ),
                    KpiItem(
                      'المهام',
                      '${p.tasksDone}/${p.tasksTotal}',
                      tint: c.dateTint,
                      icon: Icons.task_alt_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (p.address != null)
                  _DetailRow(label: 'العنوان', value: p.address!),
                _DetailRow(label: 'الميزانية', value: formatMoney(p.budget)),
                _DetailRow(
                  label: 'التصميم',
                  value: _designStatusLabel(p.designStatus),
                ),
                const SizedBox(height: 16),
                const SectionLabel('إجراءات'),
                IvoryMenuCard(
                  children: [
                    if (p.designStatus == 'pending')
                      HubRow(
                        title: 'اعتماد التصميم',
                        subtitle: 'راجع ووافق على التصميم',
                        icon: Icons.palette_outlined,
                        onTap: () => context.push(
                          '/client/projects/$projectId/design-approval',
                        ),
                      ),
                    HubRow(
                      title: 'التسليم',
                      subtitle: 'قائمة فحص · عيوب · توقيع',
                      icon: Icons.key_outlined,
                      onTap: () =>
                          context.push('/projects/$projectId/handover'),
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

class ClientDesignApprovalScreen extends StatelessWidget {
  const ClientDesignApprovalScreen({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientCubit(sl())..loadDesignPackage(projectId),
      child: _ClientDesignApprovalView(projectId: projectId),
    );
  }
}

class _ClientDesignApprovalView extends StatelessWidget {
  const _ClientDesignApprovalView({required this.projectId});
  final int projectId;

  Future<void> _reject(BuildContext context) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رفض التصميم'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'سبب الرفض *'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
    final reason = reasonCtrl.text.trim();
    reasonCtrl.dispose();
    if (ok != true || reason.isEmpty || !context.mounted) return;
    final success =
        await context.read<ClientCubit>().rejectDesign(projectId, reason);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض التصميم')),
      );
      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<ClientCubit>().state.error ?? 'فشل الرفض'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return BlocBuilder<ClientCubit, ClientState>(
      builder: (context, state) {
        final package = state.designPackage;
        final canDecide = package?.designStatus == 'pending';
        return Scaffold(
          appBar: AppBar(
            title: const ScreenTitle(
              'اعتماد التصميم',
              subtitle: 'مراجعة حزمة التصميم',
            ),
            toolbarHeight: 88,
          ),
          body: state.loading && package == null
              ? const Center(child: CircularProgressIndicator())
              : package == null
                  ? StatusView.error(body: state.error ?? 'تعذر تحميل التصميم')
                  : IvorySheet(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: [
                          Text(
                            package.project.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'الحالة: ${_designStatusLabel(package.designStatus)}',
                          ),
                          if (package.boards.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const SectionLabel('الأسلوب والملاحظات'),
                            Text(
                              package.boards.first.style == null
                                  ? '—'
                                  : (package.boards.first.style ?? ''),
                            ),
                            if (package.boards.first.designerNotes != null)
                              Text(package.boards.first.designerNotes!),
                          ],
                          const SizedBox(height: 16),
                          const SectionLabel('لوحة الإلهام'),
                          if (package.inspirationByRoom.isEmpty)
                            const Text('لا عناصر إلهام')
                          else
                            ...package.inspirationByRoom.entries.map(
                              (e) => ExpansionTile(
                                title: Text('${e.key} (${e.value.length})'),
                                children: e.value
                                    .map(
                                      (item) => ListTile(
                                        title: Text(item.title),
                                        subtitle: Text(item.category ?? ''),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          const SizedBox(height: 16),
                          const SectionLabel('المخططات'),
                          ...package.plans.map(
                            (p) => ListTile(
                              title: Text(p.title),
                              subtitle: Text(
                                '${p.type} · v${p.version} · ${p.status}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SectionLabel('BOQ'),
                          KpiStrip(
                            items: [
                              KpiItem(
                                'الإجمالي',
                                package.boqTotal,
                                tint: c.calculatedTint,
                                icon: Icons.payments_outlined,
                              ),
                              KpiItem(
                                'البنود',
                                '${package.boqLines.length}',
                                tint: c.dateTint,
                                icon: Icons.list_alt_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...package.boqLines.map(
                            (l) => ListTile(
                              title: Text(l.title),
                              subtitle: Text(
                                '${l.qty} ${l.unit ?? ''} × ${l.unitPrice}',
                              ),
                              trailing: Text(l.total),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (canDecide) ...[
                            AtelierButton(
                              label: state.approving
                                  ? 'جاري الاعتماد...'
                                  : 'اعتماد التصميم',
                              icon: Icons.check_circle_outline,
                              kind: AtelierButtonKind.teal,
                              onPressed: state.approving
                                  ? null
                                  : () async {
                                      final ok = await context
                                          .read<ClientCubit>()
                                          .approveDesign(projectId);
                                      if (!context.mounted) return;
                                      if (ok) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('تم اعتماد التصميم'),
                                          ),
                                        );
                                        context.pop(true);
                                      }
                                    },
                            ),
                            const SizedBox(height: 12),
                            AtelierButton(
                              label: 'رفض مع ملاحظة',
                              kind: AtelierButtonKind.secondary,
                              onPressed:
                                  state.approving ? null : () => _reject(context),
                            ),
                          ] else
                            Text(
                              package.designStatus == 'approved'
                                  ? 'تم اعتماد هذا التصميم.'
                                  : 'تم اتخاذ قرار بشأن التصميم مسبقاً.',
                            ),
                        ],
                      ),
                    ),
        );
      },
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
    case 'in_progress':
    case 'active':
      return 'قيد التنفيذ';
    case 'planning':
      return 'تخطيط';
    case 'delivered':
      return 'تسليم';
    case 'handed_over':
    case 'completed':
      return 'مكتمل';
    default:
      return status;
  }
}

String _designStatusLabel(String status) {
  switch (status) {
    case 'approved':
      return 'معتمد';
    case 'rejected':
      return 'مرفوض';
    case 'pending':
      return 'بانتظار الموافقة';
    case 'draft':
      return 'مسودة';
    default:
      return status;
  }
}
