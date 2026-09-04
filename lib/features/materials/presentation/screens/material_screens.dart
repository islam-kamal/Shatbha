import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';

import '../../../projects/data/models/project_models.dart';
import '../../../projects/data/repositories/project_repository.dart';
import '../../data/models/material_models.dart';
import '../../data/repositories/material_repository.dart';
import '../cubit/material_cubit.dart';

class MaterialsCatalogScreen extends StatelessWidget {
  const MaterialsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaterialCubit(sl())..loadCatalog(),
      child: const _CatalogView(),
    );
  }
}

class _CatalogView extends StatefulWidget {
  const _CatalogView();

  @override
  State<_CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<_CatalogView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('المواد', subtitle: 'كتalog المنتجات'),
        toolbarHeight: 88,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'بحث في المنتجات...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _search.clear();
                    context.read<MaterialCubit>().loadCatalog();
                  },
                ),
              ),
              onSubmitted: (q) => context.read<MaterialCubit>().search(q),
            ),
          ),
          Expanded(
            child: BlocBuilder<MaterialCubit, MaterialsState>(
              builder: (context, state) {
                if (state.loading && state.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null && state.products.isEmpty) {
                  return StatusView.error(body: state.error!);
                }
                if (state.products.isEmpty) {
                  return StatusView.empty(
                    title: 'لا توجد منتجات',
                    body: 'سيظهر كatalog الموردين هنا.',
                  );
                }
                return IvorySheet(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: state.products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = state.products[i];
                      return LedgerCard(
                        row: LedgerRow(
                          id: p.id,
                          title: p.name,
                          subtitle: [
                            p.category,
                            p.supplierName,
                            p.unit,
                          ].whereType<String>().join(' · '),
                          amount: p.price,
                          accent: c.teal,
                        ),
                        onTap: () => _pickProjectThenAdd(context, p.id, p.name),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProjectThenAdd(
    BuildContext context,
    int productId,
    String productName,
  ) async {
    final projects = await sl<ProjectRepository>().list();
    if (!context.mounted || projects.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أنشئ مشروعاً أولاً لإضافة المواد')),
        );
      }
      return;
    }
    final project = await showAtelierBottomSheet<Project>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          for (final p in projects)
            ListTile(
              title: Text(p.name),
              onTap: () => Navigator.pop(ctx, p),
            ),
        ],
      ),
    );
    if (!context.mounted || project == null) return;
    context.push(
      '/projects/${project.id}/materials/add?product_id=$productId&name=${Uri.encodeComponent(productName)}',
    );
  }
}

class SupplierProductsScreen extends StatelessWidget {
  const SupplierProductsScreen({super.key, required this.supplierId});
  final int supplierId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaterialCubit(sl())..loadCatalog(supplierId: supplierId),
      child: _SupplierProductsView(supplierId: supplierId),
    );
  }
}

class SupplierProductsManageScreen extends StatefulWidget {
  const SupplierProductsManageScreen({super.key});

  @override
  State<SupplierProductsManageScreen> createState() =>
      _SupplierProductsManageScreenState();
}

class _SupplierProductsManageScreenState
    extends State<SupplierProductsManageScreen> {
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await sl<MaterialRepository>().vendorProducts();
      if (!mounted) return;
      setState(() {
        _products = rows;
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

  Future<void> _showForm({Product? product}) async {
    final name = TextEditingController(text: product?.name ?? '');
    final price = TextEditingController(text: product?.price ?? '');
    final unit = TextEditingController(text: product?.unit ?? '');
    final category = TextEditingController(text: product?.category ?? '');
    final ok = await showAtelierDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product == null ? 'منتج جديد' : 'تعديل منتج'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'الاسم *'),
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'السعر'),
            ),
            TextField(
              controller: unit,
              decoration: const InputDecoration(labelText: 'الوحدة'),
            ),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'التصنيف'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty || !mounted) return;
    final body = {
      'name': name.text.trim(),
      if (price.text.trim().isNotEmpty) 'price': price.text.trim(),
      if (unit.text.trim().isNotEmpty) 'unit': unit.text.trim(),
      if (category.text.trim().isNotEmpty) 'category': category.text.trim(),
    };
    try {
      if (product == null) {
        await sl<MaterialRepository>().createVendorProduct(body);
      } else {
        await sl<MaterialRepository>().updateVendorProduct(product.id, body);
      }
      if (!mounted) return;
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _delete(Product product) async {
    try {
      await sl<MaterialRepository>().deleteVendorProduct(product.id);
      if (!mounted) return;
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('إدارة منتجاتي'),
        toolbarHeight: 76,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _products.isEmpty
                  ? StatusView.empty(
                      title: 'لا منتجات',
                      body: 'أضف أول منتج ليظهر في الكتalog.',
                      actionLabel: 'منتج جديد',
                      onAction: () => _showForm(),
                    )
                  : IvorySheet(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final p = _products[i];
                          return Dismissible(
                            key: ValueKey(p.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              color: c.terracotta,
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) => _delete(p),
                            child: LedgerCard(
                              row: LedgerRow(
                                id: p.id,
                                title: p.name,
                                subtitle: p.category ?? '',
                                amount: p.price,
                                accent: c.teal,
                              ),
                              onTap: () => _showForm(product: p),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _SupplierProductsView extends StatelessWidget {
  const _SupplierProductsView({required this.supplierId});
  final int supplierId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('منتجات المورد'),
        toolbarHeight: 76,
      ),
      body: BlocBuilder<MaterialCubit, MaterialsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return StatusView.error(body: state.error!);
          }
          return IvorySheet(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: state.products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = state.products[i];
                return LedgerCard(
                  row: LedgerRow(
                    id: p.id,
                    title: p.name,
                    subtitle: p.category ?? '',
                    amount: p.price,
                    accent: c.teal,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ProjectMaterialsScreen extends StatelessWidget {
  const ProjectMaterialsScreen({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaterialCubit(sl())..loadProjectMaterials(projectId),
      child: _ProjectMaterialsView(projectId: projectId),
    );
  }
}

class _ProjectMaterialsView extends StatelessWidget {
  const _ProjectMaterialsView({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('مواد المشروع', subtitle: 'BOM'),
        toolbarHeight: 88,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/materials'),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'إنشاء أمر شراء',
            onPressed: () => _generatePo(context),
          ),
        ],
      ),
      body: BlocBuilder<MaterialCubit, MaterialsState>(
        builder: (context, state) {
          if (state.loading && state.projectMaterials.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.projectMaterials.isEmpty) {
            return StatusView.error(body: state.error!);
          }
          if (state.projectMaterials.isEmpty) {
            return StatusView.empty(
              title: 'لا توجد مواد',
              body: 'أضف منتجات من الكتalog إلى قائمة مواد المشروع.',
              actionLabel: 'تصفح الكتalog',
              onAction: () => context.push('/materials'),
            );
          }
          final total = state.projectMaterials.fold<double>(
            0,
            (s, m) => s + (double.tryParse(m.total) ?? 0),
          );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: KpiStrip(
                  items: [
                    KpiItem(
                      'إجمالي المواد',
                      total.toStringAsFixed(2),
                      tint: c.calculatedTint,
                      icon: Icons.inventory_2_outlined,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IvorySheet(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: state.projectMaterials.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final m = state.projectMaterials[i];
                      return LedgerCard(
                        row: LedgerRow(
                          id: m.id,
                          title: m.productName ?? 'منتج #${m.productId}',
                          subtitle: '${m.qty} ${m.unit ?? ''}',
                          amount: m.total,
                          accent: c.teal,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _generatePo(BuildContext context) async {
    try {
      final result =
          await sl<MaterialRepository>().generatePo(projectId);
      if (!context.mounted) return;
      final poId = result['id'] ?? result['purchase_order_id'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            poId != null ? 'تم إنشاء أمر الشراء #$poId' : 'تم إنشاء أمر الشراء',
          ),
        ),
      );
      if (poId != null) {
        context.push('/procurement/$poId');
      }
    } on Failure catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class AddProjectMaterialScreen extends StatefulWidget {
  const AddProjectMaterialScreen({
    super.key,
    required this.projectId,
    required this.productId,
    this.productName,
  });

  final int projectId;
  final int productId;
  final String? productName;

  @override
  State<AddProjectMaterialScreen> createState() =>
      _AddProjectMaterialScreenState();
}

class _AddProjectMaterialScreenState extends State<AddProjectMaterialScreen> {
  final _qty = TextEditingController(text: '1');
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _qty.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await sl<MaterialRepository>().addToProject(widget.projectId, {
        'product_id': widget.productId,
        'qty': _qty.text.trim(),
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
        title: ScreenTitle(
          'إضافة للمشروع',
          subtitle: widget.productName,
        ),
        toolbarHeight: 88,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            TextField(
              controller: _qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'الكمية'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
            ),
            const SizedBox(height: 24),
            AtelierButton(
              label: _saving ? 'جاري الإضافة...' : 'إضافة للمشروع',
              icon: Icons.add,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
