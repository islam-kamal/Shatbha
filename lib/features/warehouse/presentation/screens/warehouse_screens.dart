import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';

import '../cubit/warehouse_cubit.dart';

class WarehouseHubScreen extends StatelessWidget {
  const WarehouseHubScreen({super.key, this.projectId});
  final int? projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WarehouseCubit(sl())..load(),
      child: _WarehouseHubView(projectId: projectId),
    );
  }
}

class _WarehouseHubView extends StatelessWidget {
  const _WarehouseHubView({this.projectId});
  final int? projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(
          'المخازن',
          subtitle: projectId != null ? 'مشروع #$projectId' : 'إدارة المخزون',
        ),
        toolbarHeight: 88,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            IvoryMenuCard(
              children: [
                HubRow(
                  title: 'قائمة المخازن',
                  subtitle: 'عرض وإضافة مخازن',
                  icon: Icons.warehouse_outlined,
                  onTap: () => context.push('/warehouse/list'),
                ),
                HubRow(
                  title: 'مستويات المخزون',
                  subtitle: 'الكميات المتاحة',
                  icon: Icons.inventory_outlined,
                  onTap: () => context.push('/warehouse/stock'),
                ),
                HubRow(
                  title: 'صرف لمشروع',
                  subtitle: 'إصدار مواد للموقع',
                  icon: Icons.output_outlined,
                  onTap: () => context.push(
                    projectId != null
                        ? '/warehouse/issue?projectId=$projectId'
                        : '/warehouse/issue',
                  ),
                ),
                HubRow(
                  title: 'تحويل بين مخازن',
                  subtitle: 'نقل مخزون',
                  icon: Icons.swap_horiz,
                  onTap: () => context.push('/warehouse/transfer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WarehouseListScreen extends StatelessWidget {
  const WarehouseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WarehouseCubit(sl())..load(),
      child: const _WarehouseListView(),
    );
  }
}

class _WarehouseListView extends StatelessWidget {
  const _WarehouseListView();

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('المخازن'),
        toolbarHeight: 76,
      ),
      body: BlocBuilder<WarehouseCubit, WarehouseState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.warehouses.isEmpty) {
            return StatusView.error(body: state.error!);
          }
          if (state.warehouses.isEmpty) {
            return const StatusView.empty(
              title: 'لا مخازن',
              body: 'أضف مخزنًا من لوحة الإدارة.',
            );
          }
          return IvorySheet(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: state.warehouses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final wh = state.warehouses[i];
                return Material(
                  color: c.ivory,
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    leading: Icon(Icons.warehouse, color: c.brass),
                    title: Text(
                      wh.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.stone,
                      ),
                    ),
                    subtitle: Text(wh.location ?? ''),
                    trailing: wh.isDefault
                        ? Chip(
                            label: const Text('افتراضي'),
                            backgroundColor: c.dateTint,
                          )
                        : null,
                    onTap: () => context.push('/warehouse/stock?warehouseId=${wh.id}'),
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

class StockLevelsScreen extends StatelessWidget {
  const StockLevelsScreen({super.key, this.warehouseId});
  final int? warehouseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WarehouseCubit(sl())..load(warehouseId: warehouseId),
      child: _StockLevelsView(warehouseId: warehouseId),
    );
  }
}

class _StockLevelsView extends StatelessWidget {
  const _StockLevelsView({this.warehouseId});
  final int? warehouseId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('مستويات المخزون'),
        toolbarHeight: 76,
      ),
      body: BlocBuilder<WarehouseCubit, WarehouseState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.stock.isEmpty) {
            return const StatusView.empty(
              title: 'لا مخزون',
              body: 'لا توجد كميات مسجلة.',
            );
          }
          return IvorySheet(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: state.stock.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final row = state.stock[i];
                return LedgerCard(
                  row: LedgerRow(
                    id: row.id,
                    title: row.productName ?? 'منتج #${row.productId}',
                    subtitle: row.unit ?? '',
                    amount: row.quantity,
                    accent: c.teal,
                    badge: 'متاح',
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

class IssueToProjectScreen extends StatefulWidget {
  const IssueToProjectScreen({super.key, this.projectId});
  final int? projectId;

  @override
  State<IssueToProjectScreen> createState() => _IssueToProjectScreenState();
}

class _IssueToProjectScreenState extends State<IssueToProjectScreen> {
  final _warehouseId = TextEditingController();
  final _projectId = TextEditingController();
  final _productId = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      _projectId.text = widget.projectId.toString();
    }
  }

  @override
  void dispose() {
    _warehouseId.dispose();
    _projectId.dispose();
    _productId.dispose();
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final cubit = WarehouseCubit(sl())..load();
    final ok = await cubit.issueToProject(
      warehouseId: int.parse(_warehouseId.text.trim()),
      projectId: int.parse(_projectId.text.trim()),
      productId: int.parse(_productId.text.trim()),
      quantity: _quantity.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      await showAtelierSuccess(context, body: 'تم صرف المواد للمشروع');
      if (mounted) context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.state.error ?? 'تعذر الصرف')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('صرف لمشروع'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FieldLabel('المخزن'),
          TextField(
            controller: _warehouseId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'معرف المخزن'),
          ),
          const SizedBox(height: 12),
          const FieldLabel('المشروع'),
          TextField(
            controller: _projectId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'معرف المشروع'),
          ),
          const SizedBox(height: 12),
          const FieldLabel('المنتج'),
          TextField(
            controller: _productId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'معرف المنتج'),
          ),
          const SizedBox(height: 12),
          const FieldLabel('الكمية'),
          TextField(
            controller: _quantity,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          const FieldLabel('ملاحظات'),
          TextField(controller: _notes, maxLines: 2),
          const SizedBox(height: 24),
          AtelierButton(
            label: _saving ? 'جاري الصرف…' : 'تأكيد الصرف',
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class TransferStockScreen extends StatefulWidget {
  const TransferStockScreen({super.key});

  @override
  State<TransferStockScreen> createState() => _TransferStockScreenState();
}

class _TransferStockScreenState extends State<TransferStockScreen> {
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _productId = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _productId.dispose();
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final cubit = WarehouseCubit(sl());
    final ok = await cubit.transfer(
      fromWarehouseId: int.parse(_from.text.trim()),
      toWarehouseId: int.parse(_to.text.trim()),
      productId: int.parse(_productId.text.trim()),
      quantity: _quantity.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      await showAtelierSuccess(context, body: 'تم التحويل بين المخازن');
      if (mounted) context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.state.error ?? 'تعذر التحويل')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('تحويل مخزون'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FieldLabel('من مخزن'),
          TextField(controller: _from, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          const FieldLabel('إلى مخزن'),
          TextField(controller: _to, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          const FieldLabel('المنتج'),
          TextField(controller: _productId, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          const FieldLabel('الكمية'),
          TextField(controller: _quantity, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          const FieldLabel('ملاحظات'),
          TextField(controller: _notes, maxLines: 2),
          const SizedBox(height: 24),
          AtelierButton(
            label: _saving ? 'جاري التحويل…' : 'تأكيد التحويل',
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}
