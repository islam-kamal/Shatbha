import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shatbha/core/core.dart';

import '../../../projects/data/models/project_models.dart';
import '../../../projects/data/repositories/project_repository.dart';
import '../../../auth/presentation/cubit/auth_bloc.dart';
import '../../../media/presentation/widgets/media_attach_picker.dart';
import '../../../media/data/repositories/media_repository.dart';
import '../../data/models/design_models.dart';
import '../../data/repositories/design_repository.dart';
import '../cubit/design_cubit.dart';

class DesignHubScreen extends StatelessWidget {
  const DesignHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProjectPickerView(
      title: 'التصميم',
      subtitle: 'اختر مشروعاً',
      routeBuilder: (id) => '/projects/$id/design',
    );
  }
}

class ProjectDesignScreen extends StatelessWidget {
  const ProjectDesignScreen({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DesignCubit(sl())..load(projectId),
      child: _ProjectDesignView(projectId: projectId),
    );
  }
}

class _ProjectDesignView extends StatelessWidget {
  const _ProjectDesignView({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final isClient = context.select<AuthBloc, bool>(
      (b) =>
          b.state is AuthAuthenticated &&
          (b.state as AuthAuthenticated).user.isClient,
    );
    return BlocBuilder<DesignCubit, DesignState>(
      builder: (context, state) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: ScreenTitle(
                'التصميم',
                subtitle: designStatusLabel(state.designStatus),
              ),
              toolbarHeight: 88,
              actions: [
                if (isClient)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'اعتماد التصميم',
                    onPressed: () => context.push(
                      '/client/projects/$projectId/design-approval',
                    ),
                  )
                else if (state.canEdit)
                  TextButton(
                    onPressed: state.submitting
                        ? null
                        : () async {
                            final cubit = context.read<DesignCubit>();
                            final ok = await cubit.submitToClient(projectId);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'تم إرسال التصميم للعميل'
                                      : (cubit.state.error ??
                                          'أضف مخططاً وبند BOQ قبل الإرسال'),
                                ),
                              ),
                            );
                            if (ok) await cubit.load(projectId);
                          },
                    child: Text(
                      state.submitting ? 'جاري الإرسال...' : 'إرسال للعميل',
                    ),
                  ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'لوحة الإلهام'),
                  Tab(text: 'مخططات'),
                  Tab(text: 'BOQ'),
                ],
              ),
            ),
            body: Column(
              children: [
                if (state.designStatus == 'pending')
                  _StatusBanner(
                    text: 'بانتظار اعتماد العميل — التعديل مقفل',
                    color: context.atelier.brass,
                  ),
                if (state.designStatus == 'approved')
                  _StatusBanner(
                    text: 'التصميم معتمد من العميل',
                    color: context.atelier.teal,
                  ),
                if (state.designStatus == 'rejected')
                  _StatusBanner(
                    text: state.designRejectReason == null
                        ? 'العميل رفض التصميم — عدّل ثم أعد الإرسال'
                        : 'مرفوض: ${state.designRejectReason}',
                    color: context.atelier.terracotta,
                  ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _InspirationTab(projectId: projectId),
                      _PlansTab(projectId: projectId),
                      _BoqTab(projectId: projectId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withValues(alpha: 0.12),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InspirationTab extends StatelessWidget {
  const _InspirationTab({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return BlocBuilder<DesignCubit, DesignState>(
      builder: (context, state) {
        if (state.loading && state.designBoards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null &&
            state.inspiration.isEmpty &&
            state.designBoards.isEmpty) {
          return StatusView.error(body: state.error!);
        }

        final byRoom = state.inspirationByRoom;
        final board = state.board;

        return IvorySheet(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Row(
                children: [
                  Expanded(
                    child:                     DropdownButtonFormField<String?>(
                      value: board?.style,
                      decoration: const InputDecoration(labelText: 'الأسلوب'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('—'),
                        ),
                        ...kBoardStyles.map(
                          (s) => DropdownMenuItem<String?>(
                            value: s,
                            child: Text(kStyleLabels[s] ?? s),
                          ),
                        ),
                      ],
                      onChanged: !state.canEdit
                          ? null
                          : (v) {
                              context.read<DesignCubit>().updateBoard(
                                projectId,
                                {'style': v},
                              );
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (board?.designerNotes != null &&
                  board!.designerNotes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    board.designerNotes!,
                    style: TextStyle(color: c.stone.withValues(alpha: 0.8)),
                  ),
                ),
              if (state.canEdit)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => _editDesignerNotes(
                      context,
                      projectId,
                      board?.designerNotes,
                    ),
                    icon: const Icon(Icons.edit_note),
                    label: const Text('ملاحظات المصمم'),
                  ),
                ),
              const SizedBox(height: 16),
              ...kDesignRooms.map((room) {
                final items = byRoom[room] ?? [];
                return ExpansionTile(
                  initiallyExpanded: items.isNotEmpty,
                  title: Text(
                    '${kRoomLabels[room] ?? room} (${items.length})',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  children: [
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          'لا عناصر في هذه الغرفة',
                          style: TextStyle(
                            color: c.stone.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ...items.map(
                      (item) => ListTile(
                        leading: _MediaThumb(item: item),
                        title: Text(item.title),
                        subtitle: Text(
                          kCategoryLabels[item.category ?? ''] ??
                              item.category ??
                              '',
                        ),
                      ),
                    ),
                    if (state.canEdit)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () => _openAddInspiration(
                            context,
                            projectId,
                            room: room,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة عنصر'),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _MediaThumb extends StatelessWidget {
  const _MediaThumb({required this.item});
  final InspirationItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    if (item.isPdf) {
      return Icon(Icons.picture_as_pdf_outlined, color: c.terracotta);
    }
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          item.imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.image_outlined, color: c.brass),
        ),
      );
    }
    return Icon(Icons.palette_outlined, color: c.brass);
  }
}

class _PlansTab extends StatelessWidget {
  const _PlansTab({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return BlocBuilder<DesignCubit, DesignState>(
      builder: (context, state) {
        if (state.loading && state.plans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final plans = state.filteredPlans;
        return IvorySheet(
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text('الكل'),
                        selected: state.planTypeFilter == null,
                        onSelected: (_) =>
                            context.read<DesignCubit>().setPlanTypeFilter(null),
                      ),
                    ),
                    ...kPlanTypes.map(
                      (t) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(kPlanTypeLabels[t] ?? t),
                          selected: state.planTypeFilter == t,
                          onSelected: (_) => context
                              .read<DesignCubit>()
                              .setPlanTypeFilter(t),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.canEdit)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: AtelierButton(
                    label: 'إضافة مخطط',
                    icon: Icons.add,
                    kind: AtelierButtonKind.secondary,
                    onPressed: () => _openAddPlan(context, projectId),
                  ),
                ),
              Expanded(
                child: plans.isEmpty
                    ? StatusView.empty(
                        title: 'لا توجد مخططات',
                        body: 'أضف مخططات التصميم للمشروع.',
                        actionLabel: state.canEdit ? 'إضافة مخطط' : null,
                        onAction: state.canEdit
                            ? () => _openAddPlan(context, projectId)
                            : null,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: plans.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final p = plans[i];
                          return LedgerCard(
                            row: LedgerRow(
                              id: p.id,
                              title: p.title,
                              subtitle:
                                  '${kPlanTypeLabels[p.type] ?? p.type} · v${p.version}${p.room != null ? ' · ${kRoomLabels[p.room!] ?? p.room}' : ''}',
                              amount: planStatusLabel(p.status),
                              accent: c.brass,
                              badge: p.isPdf ? 'PDF' : null,
                            ),
                            onTap: () => context.push(
                              '/projects/$projectId/design/plans/${p.id}',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _editDesignerNotes(
  BuildContext context,
  int projectId,
  String? current,
) async {
  final controller = TextEditingController(text: current ?? '');
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('ملاحظات المصمم'),
      content: TextField(
        controller: controller,
        maxLines: 4,
        decoration: const InputDecoration(hintText: 'اكتب ملاحظاتك'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('حفظ'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    await context.read<DesignCubit>().updateBoard(projectId, {
      'designer_notes': controller.text.trim(),
    });
  }
  controller.dispose();
}

Future<void> _openAddInspiration(
  BuildContext context,
  int projectId, {
  String? room,
}) async {
  final q = room == null ? '' : '?room=$room';
  final ok = await context.push<bool>(
    '/projects/$projectId/design/inspiration/add$q',
  );
  if (context.mounted && ok == true) {
    await context.read<DesignCubit>().load(projectId);
  }
}

Future<void> _openAddPlan(BuildContext context, int projectId) async {
  final ok = await context.push<bool>(
    '/projects/$projectId/design/plans/add',
  );
  if (context.mounted && ok == true) {
    await context.read<DesignCubit>().load(projectId);
  }
}

class _BoqTab extends StatelessWidget {
  const _BoqTab({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return BlocBuilder<DesignCubit, DesignState>(
      builder: (context, state) {
        if (state.loading && state.boqLines.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: KpiStrip(
                items: [
                  KpiItem(
                    'قيمة BOQ',
                    state.boqTotal.toStringAsFixed(2),
                    tint: c.calculatedTint,
                    icon: Icons.payments_outlined,
                  ),
                  KpiItem(
                    'البنود',
                    '${state.boqLines.length}',
                    tint: c.dateTint,
                    icon: Icons.list_alt_outlined,
                  ),
                ],
              ),
            ),
            if (state.canEdit)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: AtelierButton(
                        label: 'إضافة بند',
                        icon: Icons.add,
                        kind: AtelierButtonKind.secondary,
                        onPressed: () async {
                          final ok = await context.push<bool>(
                            '/projects/$projectId/design/boq/add',
                          );
                          if (context.mounted && ok == true) {
                            await context.read<DesignCubit>().load(projectId);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AtelierButton(
                        label: 'من الإلهام',
                        icon: Icons.auto_awesome_outlined,
                        kind: AtelierButtonKind.secondary,
                        onPressed: state.inspiration.isEmpty
                            ? null
                            : () => _pickInspirationForBoq(context, projectId),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: state.boqLines.isEmpty
                  ? StatusView.empty(
                      title: 'لا توجد بنود',
                      body: 'أضف بنود BOQ أو أنشئها من الإلهام.',
                    )
                  : IvorySheet(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: state.boqLines.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final line = state.boqLines[i];
                          final card = LedgerCard(
                            row: LedgerRow(
                              id: line.id,
                              title: line.title,
                              subtitle:
                                  '${line.room ?? '—'} · ${line.qty} ${line.unit ?? ''} × ${line.unitPrice}',
                              amount: line.total,
                              accent: c.terracotta,
                              badge: line.category,
                            ),
                          );
                          if (!state.canEdit) return card;
                          return Dismissible(
                            key: ValueKey(line.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              color: c.terracotta,
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) async {
                              await context
                                  .read<DesignCubit>()
                                  .deleteBoqLine(projectId, line.id);
                            },
                            child: card,
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _pickInspirationForBoq(BuildContext context, int projectId) async {
  final cubit = context.read<DesignCubit>();
  final items = cubit.state.inspiration;
  final picked = await showModalBottomSheet<InspirationItem>(
    context: context,
    builder: (ctx) => SafeArea(
      child: ListView(
        children: [
          const ListTile(title: Text('اختر عنصر إلهام')),
          ...items.map(
            (item) => ListTile(
              title: Text(item.title),
              subtitle: Text(
                '${kRoomLabels[item.room ?? ''] ?? item.room ?? ''} · ${kCategoryLabels[item.category ?? ''] ?? ''}',
              ),
              onTap: () => Navigator.pop(ctx, item),
            ),
          ),
        ],
      ),
    ),
  );
  if (picked == null || !context.mounted) return;
  final ok = await cubit.createBoqFromInspiration(projectId, picked.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(ok ? 'تمت إضافة البند' : (cubit.state.error ?? 'فشل'))),
  );
}

class DesignPlanDetailScreen extends StatelessWidget {
  const DesignPlanDetailScreen({
    super.key,
    required this.projectId,
    required this.planId,
  });
  final int projectId;
  final int planId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DesignCubit(sl())..load(projectId),
      child: _DesignPlanDetailView(projectId: projectId, planId: planId),
    );
  }
}

class _DesignPlanDetailView extends StatefulWidget {
  const _DesignPlanDetailView({
    required this.projectId,
    required this.planId,
  });
  final int projectId;
  final int planId;

  @override
  State<_DesignPlanDetailView> createState() => _DesignPlanDetailViewState();
}

class _DesignPlanDetailViewState extends State<_DesignPlanDetailView> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DesignCubit, DesignState>(
      builder: (context, state) {
        DesignPlan? plan;
        for (final p in state.plans) {
          if (p.id == widget.planId) plan = p;
        }
        return Scaffold(
          appBar: AppBar(
            title: ScreenTitle(
              plan?.title ?? 'المخطط',
              subtitle: plan == null
                  ? null
                  : '${kPlanTypeLabels[plan.type] ?? plan.type} · v${plan.version}',
            ),
            toolbarHeight: 88,
          ),
          body: state.loading && plan == null
              ? const Center(child: CircularProgressIndicator())
              : plan == null
                  ? StatusView.error(body: state.error ?? 'المخطط غير موجود')
                  : IvorySheet(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: [
                          Text('الحالة: ${planStatusLabel(plan.status)}'),
                          const SizedBox(height: 12),
                          if (plan.imageUrl != null && !plan.isPdf)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                plan.imageUrl!,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            )
                          else if (plan.isPdf)
                            const ListTile(
                              leading: Icon(Icons.picture_as_pdf),
                              title: Text('ملف PDF مرفق'),
                            ),
                          const SizedBox(height: 16),
                          if (state.canEdit) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (plan.status == 'draft' ||
                                    plan.status == 'rejected')
                                  AtelierButton(
                                    label: 'إرسال للمراجعة',
                                    onPressed: () async {
                                      await context
                                          .read<DesignCubit>()
                                          .submitPlan(
                                            widget.projectId,
                                            widget.planId,
                                          );
                                    },
                                  ),
                                if (plan.status == 'in_review') ...[
                                  AtelierButton(
                                    label: 'اعتماد داخلي',
                                    kind: AtelierButtonKind.teal,
                                    onPressed: () async {
                                      await context
                                          .read<DesignCubit>()
                                          .approvePlan(
                                            widget.projectId,
                                            widget.planId,
                                          );
                                    },
                                  ),
                                  AtelierButton(
                                    label: 'رفض',
                                    kind: AtelierButtonKind.secondary,
                                    onPressed: () async {
                                      await context
                                          .read<DesignCubit>()
                                          .rejectPlan(
                                            widget.projectId,
                                            widget.planId,
                                          );
                                    },
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          const SectionLabel('التعليقات'),
                          ...plan.comments.map(
                            (c) => ListTile(
                              title: Text(c.body),
                              subtitle: Text(c.authorLabel ?? ''),
                            ),
                          ),
                          TextField(
                            controller: _comment,
                            decoration: const InputDecoration(
                              labelText: 'تعليق جديد',
                            ),
                          ),
                          const SizedBox(height: 8),
                          AtelierButton(
                            label: 'إضافة تعليق',
                            onPressed: () async {
                              final text = _comment.text.trim();
                              if (text.isEmpty) return;
                              final ok = await context
                                  .read<DesignCubit>()
                                  .addPlanComment(
                                    widget.projectId,
                                    widget.planId,
                                    text,
                                  );
                              if (ok) _comment.clear();
                            },
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}

class AddBoqLineScreen extends StatefulWidget {
  const AddBoqLineScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<AddBoqLineScreen> createState() => _AddBoqLineScreenState();
}

class _AddBoqLineScreenState extends State<AddBoqLineScreen> {
  final _title = TextEditingController();
  final _room = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _unit = TextEditingController(text: 'م²');
  final _price = TextEditingController();
  final _category = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _room.dispose();
    _qty.dispose();
    _unit.dispose();
    _price.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await sl<DesignRepository>().createBoqLine(widget.projectId, {
        'description': _title.text.trim(),
        'qty': _qty.text.trim().isEmpty ? '1' : _qty.text.trim(),
        'rate': _price.text.trim().isEmpty ? '0' : _price.text.trim(),
        if (_unit.text.trim().isNotEmpty) 'unit': _unit.text.trim(),
        if (_category.text.trim().isNotEmpty) 'trade': _category.text.trim(),
        if (_room.text.trim().isNotEmpty) 'room': _room.text.trim(),
      });
      if (!mounted) return;
      context.pop(true);
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
        title: const ScreenTitle('إضافة بند BOQ'),
        toolbarHeight: 76,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'البند *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _room,
              decoration: const InputDecoration(labelText: 'الغرفة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'التصنيف'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'الكمية'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _unit,
              decoration: const InputDecoration(labelText: 'الوحدة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'سعر الوحدة'),
            ),
            const SizedBox(height: 24),
            AtelierButton(
              label: _saving ? 'جاري الحفظ...' : 'حفظ البند',
              icon: Icons.check,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class AddMoodBoardItemScreen extends StatefulWidget {
  const AddMoodBoardItemScreen({
    super.key,
    required this.projectId,
    this.initialRoom,
  });
  final int projectId;
  final String? initialRoom;

  @override
  State<AddMoodBoardItemScreen> createState() => _AddMoodBoardItemScreenState();
}

class _AddMoodBoardItemScreenState extends State<AddMoodBoardItemScreen> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  late String _room;
  String _category = 'reference';
  List<LocalMediaPick> _files = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _room = widget.initialRoom ?? 'Living';
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final boards =
          await sl<DesignRepository>().designBoards(widget.projectId);
      final board = boards.isNotEmpty
          ? boards.first
          : await sl<DesignRepository>().createDesignBoard(widget.projectId, {
              'title': 'لوحة الإلهام',
            });

      Future<void> createOne({String? title, int? mediaId}) {
        return sl<DesignRepository>().createInspiration(
          widget.projectId,
          board.id,
          {
            'title': title ?? _title.text.trim(),
            'room': _room,
            'category': _category,
            if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
            if (mediaId != null) 'media_id': mediaId,
          },
        );
      }

      if (_files.isEmpty) {
        await createOne();
      } else {
        for (var i = 0; i < _files.length; i++) {
          final file = _files[i];
          final media = await sl<MediaRepository>().upload(
            file.path,
            filename: file.name,
            projectId: widget.projectId,
          );
          final label = _files.length == 1
              ? _title.text.trim()
              : '${_title.text.trim()} (${i + 1})';
          await createOne(title: label, mediaId: media.id);
        }
      }
      if (!mounted) return;
      context.pop(true);
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
        title: const ScreenTitle('إضافة للوحة الإلهام'),
        toolbarHeight: 76,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'العنوان *'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _room,
              decoration: const InputDecoration(labelText: 'الغرفة'),
              items: kDesignRooms
                  .map(
                    (r) => DropdownMenuItem(
                      value: r,
                      child: Text(kRoomLabels[r] ?? r),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _room = v ?? _room),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'التصنيف'),
              items: kInspirationCategories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(kCategoryLabels[c] ?? c),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 12),
            MediaPickField(
              files: _files,
              enabled: !_saving,
              emptyLabel: 'إضافة صور أو PDF',
              hint: 'اضغط للاختيار — الرفع عند الحفظ فقط',
              onChanged: (files) => setState(() => _files = files),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
            ),
            const SizedBox(height: 24),
            AtelierButton(
              label: _saving ? 'جاري الحفظ...' : 'حفظ',
              icon: Icons.check,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class AddFloorPlanScreen extends StatefulWidget {
  const AddFloorPlanScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<AddFloorPlanScreen> createState() => _AddFloorPlanScreenState();
}

class _AddFloorPlanScreenState extends State<AddFloorPlanScreen> {
  final _title = TextEditingController();
  String _type = 'floor';
  String? _room;
  List<LocalMediaPick> _files = [];
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      int? mediaId;
      if (_files.isNotEmpty) {
        final media = await sl<MediaRepository>().upload(
          _files.first.path,
          filename: _files.first.name,
          projectId: widget.projectId,
        );
        mediaId = media.id;
      }
      await sl<DesignRepository>().createPlan(widget.projectId, {
        'type': _type,
        'title': _title.text.trim(),
        if (_room != null) 'room': _room,
        if (mediaId != null) 'media_id': mediaId,
      });
      if (!mounted) return;
      context.pop(true);
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
        title: const ScreenTitle('إضافة مخطط'),
        toolbarHeight: 76,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'اسم المخطط *'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'النوع'),
              items: kPlanTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(kPlanTypeLabels[t] ?? t),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _room,
              decoration: const InputDecoration(labelText: 'الغرفة (اختياري)'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('—')),
                ...kDesignRooms.map(
                  (r) => DropdownMenuItem<String?>(
                    value: r,
                    child: Text(kRoomLabels[r] ?? r),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _room = v),
            ),
            const SizedBox(height: 12),
            const SectionLabel('الملفات'),
            const SizedBox(height: 8),
            MediaAttachPicker(
              files: _files,
              enabled: !_saving,
              onChanged: (files) => setState(() => _files = files),
            ),
            const SizedBox(height: 24),
            AtelierButton(
              label: _saving ? 'جاري الحفظ...' : 'حفظ المخطط',
              icon: Icons.check,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectPickerView extends StatefulWidget {
  const _ProjectPickerView({
    required this.title,
    required this.subtitle,
    required this.routeBuilder,
  });

  final String title;
  final String subtitle;
  final String Function(int projectId) routeBuilder;

  @override
  State<_ProjectPickerView> createState() => _ProjectPickerViewState();
}

class _ProjectPickerViewState extends State<_ProjectPickerView> {
  List<Project> _projects = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await sl<ProjectRepository>().list();
      if (!mounted) return;
      setState(() {
        _projects = rows;
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
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(widget.title, subtitle: widget.subtitle),
        toolbarHeight: 88,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/projects/add'),
        icon: const Icon(Icons.add),
        label: const Text('مشروع جديد'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!)
              : _projects.isEmpty
                  ? StatusView.empty(
                      title: 'لا توجد مشاريع',
                      body: 'أنشئ مشروعاً للبدء.',
                      actionLabel: 'مشروع جديد',
                      onAction: () => context.push('/projects/add'),
                    )
                  : IvorySheet(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _projects.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final p = _projects[i];
                          return LedgerCard(
                            row: LedgerRow(
                              id: p.id,
                              title: p.name,
                              subtitle: p.clientName ?? p.address ?? '',
                              amount: p.budget,
                              accent: context.atelier.brass,
                            ),
                            onTap: () =>
                                context.push(widget.routeBuilder(p.id)),
                          );
                        },
                      ),
                    ),
    );
  }
}
