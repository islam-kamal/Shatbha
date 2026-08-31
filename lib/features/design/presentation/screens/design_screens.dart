import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shatbha/core/core.dart';

import '../../../projects/data/models/project_models.dart';
import '../../../projects/data/repositories/project_repository.dart';
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const ScreenTitle('التصميم', subtitle: 'لوحة · مخططات · BOQ'),
          toolbarHeight: 88,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'لوحة الإلهام'),
              Tab(text: 'مخططات'),
              Tab(text: 'BOQ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MoodBoardTab(projectId: projectId),
            _FloorPlansTab(projectId: projectId),
            _BoqTab(projectId: projectId),
          ],
        ),
      ),
    );
  }
}

class _MoodBoardTab extends StatelessWidget {
  const _MoodBoardTab({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return BlocBuilder<DesignCubit, DesignState>(
      builder: (context, state) {
        if (state.loading && state.designBoards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.designBoards.isEmpty) {
          return StatusView.error(body: state.error!);
        }
        final items = [...state.designBoards, ...state.inspiration];
        if (items.isEmpty) {
          return StatusView.empty(
            title: 'لوحة فارغة',
            body: 'أضف صور إلهام وتصاميم للمشروع.',
            actionLabel: 'إضافة عنصر',
            onAction: () =>
                context.push('/projects/$projectId/design/mood-board/add'),
          );
        }
        return IvorySheet(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final title = i < state.designBoards.length
                  ? state.designBoards[i].title
                  : state.inspiration[i - state.designBoards.length].title;
              final imageUrl = i < state.designBoards.length
                  ? state.designBoards[i].imageUrl
                  : state.inspiration[i - state.designBoards.length].imageUrl;
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: c.ivory,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.brass.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: imageUrl != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(11),
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_outlined,
                                  color: c.brass,
                                  size: 40,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.palette_outlined,
                                color: c.brass,
                                size: 40,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FloorPlansTab extends StatelessWidget {
  const _FloorPlansTab({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return BlocBuilder<DesignCubit, DesignState>(
      builder: (context, state) {
        if (state.loading && state.floorPlans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.floorPlans.isEmpty) {
          return StatusView.empty(
            title: 'لا توجد مخططات',
            body: 'أضف مخططات أرضية للمشروع.',
            actionLabel: 'إضافة مخطط',
            onAction: () =>
                context.push('/projects/$projectId/design/floor-plans/add'),
          );
        }
        return IvorySheet(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: state.floorPlans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final p = state.floorPlans[i];
              return LedgerCard(
                row: LedgerRow(
                  id: p.id,
                  title: p.title,
                  subtitle: p.scale ?? p.notes ?? '',
                  amount: '—',
                  accent: c.brass,
                  badge: p.scale,
                ),
              );
            },
          ),
        );
      },
    );
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
        if (state.boqLines.isEmpty) {
          return StatusView.empty(
            title: 'لا توجد بنود',
            body: 'أضف بنود BOQ / تكعيب للمشروع.',
            actionLabel: 'إضافة بند',
            onAction: () => context.push('/projects/$projectId/design/boq/add'),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
            Expanded(
              child: IvorySheet(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: state.boqLines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final line = state.boqLines[i];
                    return LedgerCard(
                      row: LedgerRow(
                        id: line.id,
                        title: line.title,
                        subtitle:
                            '${line.qty} ${line.unit ?? ''} × ${line.unitPrice}',
                        amount: line.total,
                        accent: c.terracotta,
                        badge: line.category,
                      ),
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

class AddBoqLineScreen extends StatefulWidget {
  const AddBoqLineScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<AddBoqLineScreen> createState() => _AddBoqLineScreenState();
}

class _AddBoqLineScreenState extends State<AddBoqLineScreen> {
  final _title = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _unit = TextEditingController();
  final _price = TextEditingController();
  final _category = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
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
        'title': _title.text.trim(),
        'qty': _qty.text.trim(),
        if (_unit.text.trim().isNotEmpty) 'unit': _unit.text.trim(),
        if (_price.text.trim().isNotEmpty) 'unit_price': _price.text.trim(),
        if (_category.text.trim().isNotEmpty) 'category': _category.text.trim(),
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
  const AddMoodBoardItemScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<AddMoodBoardItemScreen> createState() => _AddMoodBoardItemScreenState();
}

class _AddMoodBoardItemScreenState extends State<AddMoodBoardItemScreen> {
  final _title = TextEditingController();
  final _imageUrl = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _imageUrl.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await sl<DesignRepository>().createDesignBoard(widget.projectId, {
        'title': _title.text.trim(),
        if (_imageUrl.text.trim().isNotEmpty)
          'image_url': _imageUrl.text.trim(),
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
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
            TextField(
              controller: _imageUrl,
              decoration: const InputDecoration(labelText: 'رابط الصورة'),
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
  final _scale = TextEditingController();
  final _imageUrl = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _scale.dispose();
    _imageUrl.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await sl<DesignRepository>().createFloorPlan(widget.projectId, {
        'title': _title.text.trim(),
        if (_scale.text.trim().isNotEmpty) 'scale': _scale.text.trim(),
        if (_imageUrl.text.trim().isNotEmpty)
          'image_url': _imageUrl.text.trim(),
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
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
            TextField(
              controller: _scale,
              decoration: const InputDecoration(labelText: 'المقياس'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrl,
              decoration: const InputDecoration(labelText: 'رابط الصورة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
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
