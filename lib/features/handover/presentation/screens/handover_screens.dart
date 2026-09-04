import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/models/handover_models.dart';
import '../cubit/handover_cubit.dart';

class HandoverScreen extends StatelessWidget {
  const HandoverScreen({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HandoverCubit(sl())..load(projectId),
      child: _HandoverView(projectId: projectId),
    );
  }
}

class _HandoverView extends StatefulWidget {
  const _HandoverView({required this.projectId});
  final int projectId;

  @override
  State<_HandoverView> createState() => _HandoverViewState();
}

class _HandoverViewState extends State<_HandoverView>
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
        title: ScreenTitle('التسليم', subtitle: 'مشروع #${widget.projectId}'),
        toolbarHeight: 88,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: c.brass,
          labelColor: c.brass,
          unselectedLabelColor: c.ivoryMuted,
          isScrollable: true,
          tabs: const [
            Tab(text: 'قائمة الفحص'),
            Tab(text: 'العيوب'),
            Tab(text: 'التوقيع'),
            Tab(text: 'إتمام'),
          ],
        ),
      ),
      body: BlocBuilder<HandoverCubit, HandoverState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.checklist.isEmpty) {
            return StatusView.error(
              body: state.error!,
              onAction: () =>
                  context.read<HandoverCubit>().load(widget.projectId),
            );
          }
          return TabBarView(
            controller: _tabs,
            children: [
              _ChecklistTab(projectId: widget.projectId, state: state),
              _SnagTab(projectId: widget.projectId, state: state),
              _SignOffTab(projectId: widget.projectId, state: state),
              _CompleteTab(projectId: widget.projectId, state: state),
            ],
          );
        },
      ),
    );
  }
}

class _ChecklistTab extends StatelessWidget {
  const _ChecklistTab({required this.projectId, required this.state});
  final int projectId;
  final HandoverState state;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    if (state.checklist.isEmpty) {
      return const StatusView.empty(
        title: 'لا بنود',
        body: 'ستظهر قائمة فحص التسليم من الخادم.',
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: KpiStrip(
            items: [
              KpiItem(
                'مكتمل',
                '${state.checkedItems}/${state.checklist.length}',
                tint: c.teal,
                icon: Icons.checklist_rtl,
              ),
            ],
          ),
        ),
        Expanded(
          child: IvorySheet(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: state.checklist.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = state.checklist[i];
                return Material(
                  color: c.ivory,
                  borderRadius: BorderRadius.circular(14),
                  child: CheckboxListTile(
                    value: item.isChecked,
                    activeColor: c.teal,
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: c.stone,
                      ),
                    ),
                    subtitle: item.notes != null ? Text(item.notes!) : null,
                    onChanged: (_) => context
                        .read<HandoverCubit>()
                        .toggleChecklist(projectId, item),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SnagTab extends StatelessWidget {
  const _SnagTab({required this.projectId, required this.state});
  final int projectId;
  final HandoverState state;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Column(
      children: [
        if (state.openSnags > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: KpiStrip(
              items: [
                KpiItem(
                  'عيوب مفتوحة',
                  state.openSnags.toString(),
                  tint: c.expenseTint,
                  icon: Icons.report_problem_outlined,
                ),
              ],
            ),
          ),
        Expanded(
          child: state.snags.isEmpty
              ? StatusView.empty(
                  title: 'لا عيوب',
                  body: 'سجّل أي ملاحظات قبل التسليم.',
                  actionLabel: 'عيب جديد',
                  onAction: () => _addSnag(context),
                )
              : IvorySheet(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: state.snags.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final snag = state.snags[i];
                      return _SnagCard(snag: snag, projectId: projectId);
                    },
                  ),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AtelierButton(
              label: 'تسجيل عيب',
              icon: Icons.add,
              onPressed: () => _addSnag(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addSnag(BuildContext context) async {
    final title = TextEditingController();
    final location = TextEditingController();
    final ok = await showAtelierDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('عيب جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
            TextField(
              controller: location,
              decoration: const InputDecoration(labelText: 'الموقع'),
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
    await context.read<HandoverCubit>().addSnag(projectId, {
      'title': title.text.trim(),
      if (location.text.trim().isNotEmpty) 'location': location.text.trim(),
      'status': 'open',
    });
  }
}

class _SnagCard extends StatelessWidget {
  const _SnagCard({required this.snag, required this.projectId});
  final SnagItem snag;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final open = snag.status == 'open';
    return Material(
      color: c.ivory,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              open ? Icons.warning_amber : Icons.check_circle_outline,
              color: open ? c.terracotta : c.teal,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snag.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.stone,
                    ),
                  ),
                  if (snag.location != null)
                    Text(
                      snag.location!,
                      style: TextStyle(
                        color: c.stone.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (open)
              TextButton(
                onPressed: () => context
                    .read<HandoverCubit>()
                    .resolveSnag(projectId, snag.id),
                child: const Text('حل'),
              ),
          ],
        ),
      ),
    );
  }
}

class _SignOffTab extends StatelessWidget {
  const _SignOffTab({required this.projectId, required this.state});
  final int projectId;
  final HandoverState state;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Column(
      children: [
        Expanded(
          child: state.signOffs.isEmpty
              ? StatusView.empty(
                  title: 'لا توقيعات',
                  body: 'سجّل توقيع العميل أو المقاول.',
                  actionLabel: 'توقيع جديد',
                  onAction: () => _addSignOff(context),
                )
              : IvorySheet(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: state.signOffs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final sign = state.signOffs[i];
                      return Material(
                        color: c.ivory,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          leading: Icon(Icons.draw_outlined, color: c.brass),
                          title: Text(
                            sign.partyName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: c.stone,
                            ),
                          ),
                          subtitle: Text(
                            [
                              if (sign.role != null) sign.role,
                              if (sign.signedAt != null)
                                displayDate(sign.signedAt!),
                            ].whereType<String>().join(' · '),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AtelierButton(
              label: 'توقيع جديد',
              icon: Icons.edit,
              onPressed: () => _addSignOff(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addSignOff(BuildContext context) async {
    final name = TextEditingController();
    final role = TextEditingController();
    final signature = TextEditingController();
    final ok = await showAtelierDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('توقيع'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'الاسم *'),
              ),
              TextField(
                controller: role,
                decoration: const InputDecoration(labelText: 'الصفة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: signature,
                decoration: const InputDecoration(
                  labelText: 'التوقيع (اكتب اسمك)',
                  hintText: 'توقيع إلكتروني',
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: signature,
                  builder: (_, value, __) => Text(
                    value.text.isEmpty ? 'معاينة التوقيع' : value.text,
                    style: TextStyle(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      color: value.text.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty || !context.mounted) return;
    await context.read<HandoverCubit>().addSignOff(projectId, {
      'party_name': name.text.trim(),
      if (role.text.trim().isNotEmpty) 'role': role.text.trim(),
      if (signature.text.trim().isNotEmpty)
        'signature_text': signature.text.trim(),
      'signed_at': formatDate(DateTime.now()),
    });
  }
}

class _CompleteTab extends StatelessWidget {
  const _CompleteTab({required this.projectId, required this.state});
  final int projectId;
  final HandoverState state;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final done = state.summary?.status == 'completed';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KpiStrip(
            items: [
              KpiItem(
                'فحص',
                '${state.checkedItems}/${state.checklist.length}',
                tint: c.dateTint,
                icon: Icons.checklist,
              ),
              KpiItem(
                'عيوب',
                state.openSnags.toString(),
                tint: c.expenseTint,
                icon: Icons.bug_report_outlined,
              ),
              KpiItem(
                'توقيعات',
                state.signOffs.length.toString(),
                tint: c.teal,
                icon: Icons.draw,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (done)
            StatusView.empty(
              title: 'تم التسليم',
              body: state.summary?.completedAt != null
                  ? 'تاريخ الإتمام: ${displayDate(state.summary!.completedAt!)}'
                  : 'اكتمل تسليم المشروع.',
            )
          else ...[
            Text(
              state.canComplete
                  ? 'جميع الشروط مستوفاة — يمكن إتمام التسليم.'
                  : 'أكمل قائمة الفحص، أغلق العيوب، وسجّل توقيعًا واحدًا على الأقل.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.ivoryMuted, height: 1.6),
            ),
            const Spacer(),
            AtelierButton(
              label: state.saving ? 'جاري الإتمام…' : 'إتمام التسليم',
              kind: AtelierButtonKind.teal,
              icon: Icons.key,
              onPressed: state.canComplete && !state.saving
                  ? () async {
                      final ok = await context
                          .read<HandoverCubit>()
                          .completeHandover(projectId);
                      if (!context.mounted) return;
                      if (ok) {
                        await showAtelierSuccess(
                          context,
                          title: 'تم التسليم',
                          body: 'اكتمل تسليم المشروع بنجاح',
                        );
                      }
                    }
                  : null,
            ),
          ],
          const SafeArea(top: false, child: SizedBox()),
        ],
      ),
    );
  }
}
