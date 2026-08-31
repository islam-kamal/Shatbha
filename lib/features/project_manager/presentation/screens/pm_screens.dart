import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/media/presentation/widgets/media_upload_tile.dart';
import 'package:shatbha/features/project_manager/data/models/pm_models.dart';

import '../cubit/pm_cubit.dart';

class ProjectManagerScreen extends StatelessWidget {
  const ProjectManagerScreen({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PmCubit(sl())..load(projectId),
      child: _ProjectManagerView(projectId: projectId),
    );
  }
}

class _ProjectManagerView extends StatefulWidget {
  const _ProjectManagerView({required this.projectId});
  final int projectId;

  @override
  State<_ProjectManagerView> createState() => _ProjectManagerViewState();
}

class _ProjectManagerViewState extends State<_ProjectManagerView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle('إدارة المشروع', subtitle: '#${widget.projectId}'),
        toolbarHeight: 88,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: c.brass,
          labelColor: c.brass,
          unselectedLabelColor: c.ivoryMuted,
          tabs: const [
            Tab(text: 'المهام'),
            Tab(text: 'الميزانية'),
            Tab(text: 'الجدول'),
            Tab(text: 'الصور'),
          ],
        ),
      ),
      body: BlocBuilder<PmCubit, PmState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.tasks.isEmpty) {
            return StatusView.error(
              body: state.error!,
              onAction: () => context.read<PmCubit>().load(widget.projectId),
            );
          }
          return TabBarView(
            controller: _tabs,
            children: [
              _TasksTab(projectId: widget.projectId, state: state),
              _BudgetTab(projectId: widget.projectId, state: state),
              _TimelineTab(state: state),
              _PhotosTab(projectId: widget.projectId, state: state),
            ],
          );
        },
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab({required this.projectId, required this.state});
  final int projectId;
  final PmState state;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Column(
      children: [
        if (state.milestones.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: KpiStrip(
              items: [
                KpiItem(
                  'معالم',
                  state.milestones.length.toString(),
                  tint: c.dateTint,
                  icon: Icons.flag_outlined,
                ),
                KpiItem(
                  'مكتملة',
                  state.tasks.where((t) => t.status == 'done').length.toString(),
                  tint: c.teal,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
        Expanded(
          child: state.tasks.isEmpty
              ? StatusView.empty(
                  title: 'لا مهام',
                  body: 'أضف أول مهمة للمشروع.',
                  actionLabel: 'مهمة جديدة',
                  onAction: () => _showAddTask(context),
                )
              : IvorySheet(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: state.tasks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final task = state.tasks[i];
                      return _TaskCard(task: task);
                    },
                  ),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AtelierButton(
              label: 'مهمة جديدة',
              icon: Icons.add,
              onPressed: () => _showAddTask(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddTask(BuildContext context) async {
    final title = TextEditingController();
    final assignee = TextEditingController();
    final due = TextEditingController(text: formatDate(DateTime.now()));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مهمة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ),
            TextField(
              controller: assignee,
              decoration: const InputDecoration(labelText: 'المسؤول'),
            ),
            TextField(
              controller: due,
              decoration: const InputDecoration(labelText: 'تاريخ الاستحقاق'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (ok != true || title.text.trim().isEmpty || !context.mounted) return;
    await context.read<PmCubit>().addTask(projectId, {
      'title': title.text.trim(),
      if (assignee.text.trim().isNotEmpty) 'assignee': assignee.text.trim(),
      'due_date': due.text.trim(),
      'status': 'pending',
    });
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});
  final ProjectTask task;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final done = task.status == 'done';
    return Material(
      color: c.ivory,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? c.teal : c.brass,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.stone,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.assignee != null || task.dueDate != null)
                    Text(
                      [
                        if (task.assignee != null) task.assignee,
                        if (task.dueDate != null) displayDate(task.dueDate!),
                      ].join(' · '),
                      style: TextStyle(
                        color: c.stone.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetTab extends StatelessWidget {
  const _BudgetTab({required this.projectId, required this.state});
  final int projectId;
  final PmState state;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: KpiStrip(
            items: [
              KpiItem(
                'مخطط',
                state.plannedTotal.toStringAsFixed(2),
                tint: c.dateTint,
                icon: Icons.account_balance_outlined,
              ),
              KpiItem(
                'فعلي',
                state.actualTotal.toStringAsFixed(2),
                tint: c.expenseTint,
                icon: Icons.payments_outlined,
              ),
            ],
          ),
        ),
        Expanded(
          child: state.budget.isEmpty
              ? StatusView.empty(
                  title: 'لا بنود ميزانية',
                  body: 'أضف بندًا لمتابعة التكلفة.',
                  actionLabel: 'بند جديد',
                  onAction: () => _showAddBudget(context),
                )
              : IvorySheet(
                  child: LedgerList(
                    rows: [
                      for (final line in state.budget)
                        LedgerRow(
                          id: line.id,
                          title: line.category,
                          subtitle: line.description ?? '',
                          amount: line.actualAmount,
                          accent: c.brass,
                          badge: formatEgp(line.plannedAmount),
                        ),
                    ],
                  ),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AtelierButton(
              label: 'بند ميزانية',
              icon: Icons.add,
              onPressed: () => _showAddBudget(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddBudget(BuildContext context) async {
    final category = TextEditingController();
    final planned = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('بند ميزانية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'الفئة'),
            ),
            TextField(
              controller: planned,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ المخطط'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (ok != true || category.text.trim().isEmpty || !context.mounted) return;
    await context.read<PmCubit>().addBudgetLine(projectId, {
      'category': category.text.trim(),
      'planned_amount': planned.text.trim().isEmpty ? '0' : planned.text.trim(),
    });
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.state});
  final PmState state;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    if (state.timeline.isEmpty) {
      return const StatusView.empty(
        title: 'لا أحداث',
        body: 'سيظهر جدول المشروع هنا.',
      );
    }
    return IvorySheet(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: state.timeline.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final event = state.timeline[i];
          return Material(
            color: c.ivory,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.event_note, color: c.brass),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: c.stone,
                          ),
                        ),
                        if (event.eventDate != null)
                          Text(
                            displayDate(event.eventDate!),
                            style: TextStyle(
                              color: c.stone.withValues(alpha: 0.55),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({required this.projectId, required this.state});
  final int projectId;
  final PmState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MediaUploadTile(
            projectId: projectId,
            uploading: state.uploadingPhoto,
            onUploaded: (media) =>
                context.read<PmCubit>().addPhotoEvent(projectId, media),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.photos.isEmpty
                ? const StatusView.empty(
                    title: 'لا صور',
                    body: 'ارفع صور موقع المشروع.',
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: state.photos.length,
                    itemBuilder: (context, i) {
                      final photo = state.photos[i];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photo.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
