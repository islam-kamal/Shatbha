import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/catalog/data/repositories/catalog_repository.dart';

import '../cubit/catalog_cubit.dart';

class DefinitionsScreen extends StatelessWidget {
  const DefinitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DefinitionsCubit(sl())..load(),
      child: const _DefinitionsView(),
    );
  }
}

class _DefinitionsView extends StatelessWidget {
  const _DefinitionsView();

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const ScreenTitle('التعريفات'),
          toolbarHeight: 76,
          actions: [
            IconButton(
              icon: const Icon(Icons.category_outlined),
              onPressed: () => context.push('/items'),
            ),
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              onPressed: () => context.push('/definitions/add-supplier'),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Material(
                color: c.raised,
                borderRadius: BorderRadius.circular(12),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: c.brass,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tabs: const [
                    Tab(text: 'عملاء'),
                    Tab(text: 'مقاولون'),
                    Tab(text: 'أعمال'),
                    Tab(text: 'بنود'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<DefinitionsCubit, DefinitionsState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return StatusView.error(body: state.error!);
            }
            return TabBarView(
              children: [
                _PartyList(
                  rows: state.customers,
                  empty: 'لا يوجد عملاء',
                  onAdd: () async {
                    await context.push('/definitions/add-customer');
                    if (context.mounted) {
                      context.read<DefinitionsCubit>().load();
                    }
                  },
                ),
                _PartyList(
                  rows: state.contractors,
                  empty: 'لا يوجد مقاولون',
                  onAdd: () async {
                    await context.push('/definitions/add-contractor');
                    if (context.mounted) {
                      context.read<DefinitionsCubit>().load();
                    }
                  },
                ),
                _NamedList(
                  rows: state.workTypes,
                  empty: 'لا توجد أنواع أعمال',
                  onAdd: () => _promptName(context, 'نوع عمل', (n) {
                    context.read<DefinitionsCubit>().addWorkType(n);
                  }),
                ),
                _NamedList(
                  rows: state.categories,
                  empty: 'لا توجد بنود مصروف',
                  onAdd: () => _promptName(context, 'بند مصروف', (n) {
                    context.read<DefinitionsCubit>().addCategory(n);
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PartyList extends StatelessWidget {
  const _PartyList({
    required this.rows,
    required this.empty,
    required this.onAdd,
  });
  final List rows;
  final String empty;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: rows.isEmpty
              ? StatusView.empty(
                  title: empty,
                  body: 'أضف عنصراً ليظهر في القائمة.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  children: [
                    IvoryMenuCard(
                      children: [
                        for (final p in rows)
                          HubRow(
                            title: p.name as String,
                            subtitle: [
                              if (p.phone != null) p.phone,
                              if (p.kind == 'supervision')
                                'عميل إشراف ${p.supervisionPercent}%',
                              if (p.kind == 'agreement') 'عميل اتفاق',
                            ].whereType<String>().join(' · '),
                            icon: p.type == 'customer'
                                ? Icons.person_outline
                                : Icons.engineering_outlined,
                            onTap: p.type == 'customer'
                                ? () => context.push(
                                    '/customers/${p.id}/statement',
                                  )
                                : () {},
                          ),
                      ],
                    ),
                  ],
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AtelierButton(
              label: 'إضافة',
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ),
        ),
      ],
    );
  }
}

class _NamedList extends StatelessWidget {
  const _NamedList({
    required this.rows,
    required this.empty,
    required this.onAdd,
  });
  final List rows;
  final String empty;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: rows.isEmpty
              ? StatusView.empty(title: empty, body: 'أضف بنداً جديداً.')
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  children: [
                    IvoryMenuCard(
                      children: [
                        for (final item in rows)
                          HubRow(
                            title: item.name as String,
                            icon: Icons.label_outline,
                            onTap: () {},
                          ),
                      ],
                    ),
                  ],
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AtelierButton(
              label: 'إضافة',
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _promptName(
  BuildContext context,
  String label,
  ValueChanged<String> onSave,
) async {
  final controller = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(label),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('حفظ'),
        ),
      ],
    ),
  );
  if (ok == true && controller.text.trim().isNotEmpty) {
    onSave(controller.text.trim());
  }
}

class AddPartyScreen extends StatefulWidget {
  const AddPartyScreen({super.key, required this.type});
  final String type;

  @override
  State<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String _kind = 'agreement';
  final _percent = TextEditingController(text: '8');

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _percent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = widget.type == 'customer';
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(isCustomer ? 'عميل جديد' : 'مقاول جديد'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'الاسم'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'الهاتف'),
          ),
          if (isCustomer) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _kind,
              items: const [
                DropdownMenuItem(value: 'agreement', child: Text('اتفاق')),
                DropdownMenuItem(value: 'supervision', child: Text('إشراف')),
              ],
              onChanged: (v) => setState(() => _kind = v ?? 'agreement'),
              decoration: const InputDecoration(labelText: 'النوع'),
            ),
            if (_kind == 'supervision') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _percent,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'نسبة الإشراف %'),
              ),
            ],
          ],
          const SizedBox(height: 24),
          AtelierButton(
            label: 'حفظ',
            onPressed: () async {
              await sl<CatalogRepository>().createParty({
                'type': widget.type,
                'name': _name.text.trim(),
                'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                'kind': isCustomer ? _kind : 'agreement',
                if (_kind == 'supervision')
                  'supervision_percent': int.tryParse(_percent.text) ?? 8,
              });
              if (context.mounted) {
                await showAtelierSuccess(context, body: 'تم الحفظ');
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
