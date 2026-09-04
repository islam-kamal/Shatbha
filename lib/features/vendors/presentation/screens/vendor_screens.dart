import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shatbha/core/core.dart';

import '../../data/models/vendor_models.dart';
import '../../data/repositories/vendor_repository.dart';
import '../cubit/vendor_cubit.dart';

class VendorsScreen extends StatelessWidget {
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VendorCubit(sl())..load(),
      child: const _VendorsView(),
    );
  }
}

class _VendorsView extends StatelessWidget {
  const _VendorsView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const ScreenTitle('السوق', subtitle: 'مقاولون وموردون'),
          toolbarHeight: 88,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'مقاولون'),
              Tab(text: 'موردون'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _VendorList(type: 'contractor'),
            _VendorList(type: 'supplier'),
          ],
        ),
      ),
    );
  }
}

class _VendorList extends StatelessWidget {
  const _VendorList({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) {
        if (state.loading && state.vendors.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.vendors.isEmpty) {
          return StatusView.error(body: state.error!);
        }
        final rows = state.vendors.where((v) => v.type == type).toList();
        if (rows.isEmpty) {
          return StatusView.empty(
            title: type == 'contractor' ? 'لا يوجد مقاولون' : 'لا يوجد موردون',
            body: 'سيظهر ${type == 'contractor' ? 'المقاولون' : 'الموردون'} المسجلون هنا.',
          );
        }
        return IvorySheet(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final v = rows[i];
              return LedgerCard(
                row: LedgerRow(
                  id: v.id,
                  title: v.name,
                  subtitle: [
                    if (v.location != null) v.location,
                    if (v.specialties.isNotEmpty) v.specialties.join(' · '),
                  ].whereType<String>().join(' · '),
                  amount: v.rating > 0 ? v.rating.toStringAsFixed(1) : '—',
                  accent: type == 'contractor'
                      ? context.atelier.terracotta
                      : context.atelier.teal,
                  badge: v.reviewCount > 0 ? '${v.reviewCount} تقييم' : null,
                ),
                onTap: () => context.push('/vendors/${v.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key, required this.vendorId});
  final int vendorId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VendorCubit(sl())..loadProfile(vendorId),
      child: _VendorProfileView(vendorId: vendorId),
    );
  }
}

class _VendorProfileView extends StatelessWidget {
  const _VendorProfileView({required this.vendorId});
  final int vendorId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) {
        if (state.loading && state.selected == null) {
          return Scaffold(
            appBar: AppBar(title: const ScreenTitle('ملف المورد')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.error != null && state.selected == null) {
          return Scaffold(
            appBar: AppBar(title: const ScreenTitle('ملف المورد')),
            body: StatusView.error(body: state.error!),
          );
        }
        final v = state.selected!;
        return Scaffold(
          appBar: AppBar(
            title: ScreenTitle(v.name, subtitle: v.isContractor ? 'مقاول' : 'مورد'),
            toolbarHeight: 88,
          ),
          body: IvorySheet(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (v.rating > 0)
                  KpiStrip(
                    items: [
                      KpiItem(
                        'التقييم',
                        v.rating.toStringAsFixed(1),
                        tint: c.brass,
                        icon: Icons.star_outline,
                      ),
                      KpiItem(
                        'التقييمات',
                        '${v.reviewCount}',
                        tint: c.dateTint,
                        icon: Icons.rate_review_outlined,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (v.description != null)
                  Text(v.description!, style: const TextStyle(height: 1.5)),
                if (v.phone != null) ...[
                  const SizedBox(height: 12),
                  Text('هاتف: ${v.phone}'),
                ],
                if (v.location != null) ...[
                  const SizedBox(height: 8),
                  Text('الموقع: ${v.location}'),
                ],
                if (v.specialties.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const SectionLabel('التخصصات'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in v.specialties)
                        Chip(label: Text(s)),
                    ],
                  ),
                ],
                if (state.reviews.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const SectionLabel('التقييمات'),
                  IvoryMenuCard(
                    children: [
                      for (final r in state.reviews)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    r.authorName ?? 'مستخدم',
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text('${r.rating}/5'),
                                ],
                              ),
                              if (r.comment != null)
                                Text(
                                  r.comment!,
                                  style: TextStyle(
                                    color: c.stone.withValues(alpha: 0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (v.isContractor)
                  AtelierButton(
                    label: 'طلب عرض سعر',
                    icon: Icons.request_quote_outlined,
                    onPressed: () =>
                        context.push('/contractors/$vendorId/request-quote'),
                  ),
                if (v.isSupplier)
                  AtelierButton(
                    label: 'منتجات المورد',
                    kind: AtelierButtonKind.secondary,
                    icon: Icons.inventory_2_outlined,
                    onPressed: () =>
                        context.push('/materials/supplier/$vendorId'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VendorPortfolioManageScreen extends StatefulWidget {
  const VendorPortfolioManageScreen({super.key});

  @override
  State<VendorPortfolioManageScreen> createState() =>
      _VendorPortfolioManageScreenState();
}

class _VendorPortfolioManageScreenState extends State<VendorPortfolioManageScreen> {
  final _repo = sl<VendorRepository>();
  List<PortfolioItem> _items = [];
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
      final rows = await _repo.portfolio();
      if (!mounted) return;
      setState(() {
        _items = rows;
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

  Future<void> _addItem() async {
    final title = TextEditingController();
    final workType = TextEditingController();
    final description = TextEditingController();
    final ok = await showAtelierDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة عمل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ),
            TextField(
              controller: workType,
              decoration: const InputDecoration(labelText: 'نوع العمل'),
            ),
            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: 'الوصف'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (ok != true || title.text.trim().isEmpty) return;
    try {
      await _repo.createPortfolioItem({
        'title': title.text.trim(),
        if (workType.text.trim().isNotEmpty) 'work_type': workType.text.trim(),
        if (description.text.trim().isNotEmpty) 'description': description.text.trim(),
      });
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _repo.deletePortfolioItem(id);
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('معرض الأعمال', subtitle: 'أعمال منفذة'),
        toolbarHeight: 88,
        actions: [
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _items.isEmpty
                  ? StatusView.empty(
                      title: 'لا أعمال',
                      body: 'أضف صور أعمالك لتظهر في ملفك للعملاء.',
                      actionLabel: 'إضافة عمل',
                      onAction: _addItem,
                    )
                  : IvorySheet(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (context, i) {
                          final item = _items[i];
                          return Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deleteItem(item.id),
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 16),
                              color: c.terracotta,
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: item.mediaUrl != null
                                        ? Image.network(
                                            item.mediaUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                ColoredBox(color: c.stone.withValues(alpha: 0.2)),
                                          )
                                        : ColoredBox(
                                            color: c.stone.withValues(alpha: 0.15),
                                            child: Icon(Icons.image_outlined, color: c.stone),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.ibmPlexSansArabic(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (item.workType != null)
                                          Text(
                                            item.workType!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: c.stone.withValues(alpha: 0.7),
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
                    ),
    );
  }
}
