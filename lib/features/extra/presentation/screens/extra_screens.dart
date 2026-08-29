import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/catalog/data/models/catalog_models.dart';
import 'package:shatbha/features/catalog/data/repositories/catalog_repository.dart';

import '../../data/datasources/extra_store.dart';
import '../widgets/kit.dart';

class OtherRevenuesScreen extends StatelessWidget {
  const OtherRevenuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ExtraStore.instance,
      builder: (context, _) {
        final rows = ExtraStore.instance.revenues;
        final total = rows.fold<double>(
          0,
          (s, e) => s + (double.tryParse(e.amount) ?? 0),
        );
        return MoneyJournalScreen(
          title: 'إيرادات أخرى',
          heroLabel: 'إيرادات أخرى',
          heroAmount: total.toStringAsFixed(0),
          lines: rows,
          addLabel: 'إضافة إيراد',
          addPath: '/revenues/add',
        );
      },
    );
  }
}

class AddRevenueScreen extends StatelessWidget {
  const AddRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleAddScreen(
      title: 'إضافة إيراد',
      successBody: 'تم تسجيل الإيراد بنجاح',
      fields: const [
        AddFieldSpec('title', 'البيان'),
        AddFieldSpec('amount', 'المبلغ', kind: AddFieldKind.amount),
        AddFieldSpec('date', 'التاريخ', kind: AddFieldKind.date),
        AddFieldSpec('notes', 'ملاحظات', kind: AddFieldKind.notes),
      ],
      onSave: (v) {
        ExtraStore.instance.addRevenue(
          DemoLine(
            title: v['title'] ?? 'إيراد',
            amount: v['amount'] ?? '0',
            date: v['date'] ?? '',
          ),
        );
      },
    );
  }
}

class SupplierJournalScreen extends StatelessWidget {
  const SupplierJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ExtraStore.instance,
      builder: (context, _) {
        return MoneyJournalScreen(
          title: 'يومية الموردين',
          subtitle: 'مشتريات وسداد',
          kpis: const [
            KpiItem('مشتريات', '7200', icon: Icons.shopping_bag_outlined),
            KpiItem('سداد', '3000', icon: Icons.payments_outlined),
          ],
          lines: ExtraStore.instance.supplierEntries,
          addLabel: 'قيد مورد',
          addPath: '/suppliers/journal/add',
        );
      },
    );
  }
}

class AddSupplierEntryScreen extends StatelessWidget {
  const AddSupplierEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleAddScreen(
      title: 'قيد مورد',
      successBody: 'تم تسجيل قيد المورد',
      fields: const [
        AddFieldSpec('title', 'البيان'),
        AddFieldSpec('amount', 'المبلغ', kind: AddFieldKind.amount),
        AddFieldSpec(
          'kind',
          'النوع',
          kind: AddFieldKind.dropdown,
          options: ['شراء', 'سداد', 'مرتجع'],
        ),
        AddFieldSpec('date', 'التاريخ', kind: AddFieldKind.date),
      ],
      onSave: (v) {
        ExtraStore.instance.addSupplierEntry(
          DemoLine(
            title: v['title'] ?? 'قيد',
            amount: v['amount'] ?? '0',
            date: v['date'] ?? '',
            badge: v['kind'],
            negative: true,
          ),
        );
      },
    );
  }
}

class GeneralJournalScreen extends StatelessWidget {
  const GeneralJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ExtraStore.instance,
      builder: (context, _) {
        return MoneyJournalScreen(
          title: 'يومية مجمعة',
          subtitle: 'جميع الأنواع',
          kpis: const [
            KpiItem('إيرادات', '18750', tint: Color(0xFFD5E6E2)),
            KpiItem('مصروفات', '12450', tint: Color(0xFFE8C9BC)),
            KpiItem('صافي اليوم', '6300'),
          ],
          lines: ExtraStore.instance.generalJournal,
          addLabel: 'قيد جديد',
          addPath: '/journal/add',
        );
      },
    );
  }
}

class PettyCashScreen extends StatelessWidget {
  const PettyCashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('تقرير العهد'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          KpiStrip(
            items: [
              KpiItem(
                'عهد مسلمة',
                '5000',
                icon: Icons.account_balance_wallet_outlined,
              ),
              KpiItem(
                'مصروف منها',
                '3200',
                tint: c.expenseTint,
                icon: Icons.arrow_downward,
              ),
              KpiItem('المتبقي', '1800', icon: Icons.savings_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.raised,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.brass.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, color: c.brass, size: 18),
                    const SizedBox(width: 6),
                    Text('م. محمد', style: TextStyle(color: c.ivory)),
                    const Spacer(),
                    Icon(Icons.event, color: c.brass, size: 18),
                    const SizedBox(width: 6),
                    Text('10/05/2026', style: TextStyle(color: c.ivoryMuted)),
                  ],
                ),
                const SizedBox(height: 18),
                Icon(Icons.villa_outlined, size: 48, color: c.brass),
                const SizedBox(height: 10),
                Text(
                  'عهدة موقع فيلا',
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: c.ivory,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'معدل الصرف من العهدة',
                    style: TextStyle(color: c.ivoryMuted, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 3200 / 5000,
                    minHeight: 10,
                    color: c.terracotta,
                    backgroundColor: c.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '3,200',
                      style: TextStyle(color: c.ivoryMuted, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '5,000 ج.م',
                      style: TextStyle(color: c.ivoryMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'المتبقي من العهدة',
                  style: TextStyle(color: c.ivoryMuted),
                ),
                Text(
                  formatEgp('1800'),
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: c.brass,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CubingScreen extends StatelessWidget {
  const CubingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    const rows = [
      ('نقاشة حوائط', '220 م²', '80', '17600'),
      ('جبس بلدي', '80 م²', '120', '9600'),
      ('ألوميتال', '40 م.ط', '350', '14000'),
      ('كهرباء تشطيب', '80 نقطة', '110', '8800'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('اتفاقات وتكعيب', subtitle: 'BOQ / Cubing'),
        toolbarHeight: 88,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const KpiStrip(
            items: [
              KpiItem('متر تشطيب', '420', icon: Icons.square_foot),
              KpiItem('قيمة الاتفاق', '50000', icon: Icons.payments_outlined),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('تفاصيل بنود الاتفاق'),
          IvoryMenuCard(
            children: [
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.$1,
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontWeight: FontWeight.w700,
                                color: c.stone,
                              ),
                            ),
                            Text(
                              '${row.$2} × ${row.$3}',
                              style: TextStyle(
                                color: c.stone.withValues(alpha: 0.55),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatMoney(row.$4),
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontWeight: FontWeight.w800,
                          color: c.stone,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AtelierButton(
            label: 'عرض الاتفاق كملف PDF',
            kind: AtelierButtonKind.secondary,
            icon: Icons.picture_as_pdf_outlined,
            onPressed: () => context.push('/print'),
          ),
          const SizedBox(height: 10),
          AtelierButton(
            label: 'إضافة بند جديد',
            icon: Icons.add,
            onPressed: () => context.push('/cubing/add'),
          ),
        ],
      ),
    );
  }
}

class AddCubingLineScreen extends StatelessWidget {
  const AddCubingLineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleAddScreen(
      title: 'إضافة بند تكعيب',
      successBody: 'تم إضافة بند الاتفاق',
      fields: [
        AddFieldSpec('title', 'البند'),
        AddFieldSpec('qty', 'الكمية', kind: AddFieldKind.amount),
        AddFieldSpec('price', 'سعر الوحدة', kind: AddFieldKind.amount),
      ],
    );
  }
}

class MaterialOutScreen extends StatelessWidget {
  const MaterialOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ExtraStore.instance,
      builder: (context, _) {
        return MoneyJournalScreen(
          title: 'سحب خامات',
          kpis: const [KpiItem('صرف', '14000', tint: Color(0xFFE8C9BC))],
          lines: ExtraStore.instance.materialOut,
          addLabel: 'سحب خامة',
          addPath: '/inventory/out/add',
        );
      },
    );
  }
}

class AddMaterialOutScreen extends StatelessWidget {
  const AddMaterialOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleAddScreen(
      title: 'سحب خامة',
      successBody: 'تم تسجيل سحب الخامات',
      fields: const [
        AddFieldSpec('title', 'الصنف'),
        AddFieldSpec('qty', 'الكمية', kind: AddFieldKind.amount),
        AddFieldSpec('amount', 'القيمة', kind: AddFieldKind.amount),
        AddFieldSpec('date', 'التاريخ', kind: AddFieldKind.date),
      ],
      onSave: (v) {
        ExtraStore.instance.addMaterialOut(
          DemoLine(
            title: v['title'] ?? 'سحب',
            amount: v['amount'] ?? '0',
            date: v['date'] ?? '',
            subtitle: v['qty'] ?? '',
            negative: true,
            badge: 'صرف',
          ),
        );
      },
    );
  }
}

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ExtraStore.instance,
      builder: (context, _) {
        return MoneyJournalScreen(
          title: 'تسجيل إنتاج',
          lines: ExtraStore.instance.production,
          addLabel: 'تسجيل إنتاج',
          addPath: '/production/add',
        );
      },
    );
  }
}

class AddProductionScreen extends StatelessWidget {
  const AddProductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleAddScreen(
      title: 'تسجيل إنتاج',
      successBody: 'تم تسجيل الإنتاج',
      fields: const [
        AddFieldSpec('title', 'الصنف'),
        AddFieldSpec('qty', 'الكمية', kind: AddFieldKind.amount),
        AddFieldSpec('date', 'التاريخ', kind: AddFieldKind.date),
      ],
      onSave: (v) {
        ExtraStore.instance.addProduction(
          DemoLine(
            title: v['title'] ?? 'إنتاج',
            amount: v['qty'] ?? '0',
            date: v['date'] ?? '',
            badge: 'إنتاج',
          ),
        );
      },
    );
  }
}

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  bool _finished = true;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('الأصناف', subtitle: 'قائمة الأصناف والمخزون'),
        toolbarHeight: 88,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/items/add'),
        icon: const Icon(Icons.add),
        label: const Text('إضافة صنف'),
      ),
      body: ListenableBuilder(
        listenable: ExtraStore.instance,
        builder: (context, _) {
          final items = ExtraStore.instance.items.where((i) {
            if (i.finished != _finished) return false;
            if (_query.isEmpty) return true;
            return i.name.contains(_query) ||
                i.sku.toLowerCase().contains(_query.toLowerCase());
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن صنف…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _seg(c, 'إنتاج تام', true)),
                    const SizedBox(width: 8),
                    Expanded(child: _seg(c, 'خامات', false)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'عدد الأصناف: ${items.length} صنف',
                    style: TextStyle(color: c.ivoryMuted, fontSize: 13),
                  ),
                ),
              ),
              Expanded(
                child: IvorySheet(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return LedgerCard(
                        row: LedgerRow(
                          id: i,
                          title: item.name,
                          subtitle:
                              'SKU: ${item.sku} · ${item.unit} ⇌ ${item.packUnit}',
                          amount: item.balance,
                          accent: c.teal,
                          badge: 'متوفر',
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

  Widget _seg(AtelierColors c, String label, bool finished) {
    final on = _finished == finished;
    return Material(
      color: on ? c.brass : c.raised,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _finished = finished),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSansArabic(
              fontWeight: FontWeight.w700,
              color: on ? c.stone : c.ivory,
            ),
          ),
        ),
      ),
    );
  }
}

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleAddScreen(
      title: 'إضافة صنف',
      successBody: 'تم إضافة الصنف',
      fields: const [
        AddFieldSpec('name', 'اسم الصنف'),
        AddFieldSpec('sku', 'كود الصنف'),
        AddFieldSpec(
          'kind',
          'النوع',
          kind: AddFieldKind.dropdown,
          options: ['إنتاج تام', 'خامات'],
        ),
      ],
      onSave: (v) {
        ExtraStore.instance.addItem(
          DemoItem(
            name: v['name'] ?? 'صنف',
            sku: v['sku'] ?? 'NEW',
            unit: '1 قطعة',
            packUnit: '12 قطعة',
            finished: v['kind'] != 'خامات',
            balance: '0',
          ),
        );
      },
    );
  }
}

class AddSupplierScreen extends StatelessWidget {
  const AddSupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleAddScreen(
      title: 'إضافة مورد',
      successBody: 'تم حفظ المورد',
      fields: [
        AddFieldSpec('name', 'اسم المورد'),
        AddFieldSpec('phone', 'رقم الجوال'),
        AddFieldSpec('opening', 'الرصيد الافتتاحي', kind: AddFieldKind.amount),
        AddFieldSpec(
          'class',
          'التصنيف',
          kind: AddFieldKind.dropdown,
          options: ['غزل', 'خامات', 'تشطيبات'],
        ),
      ],
    );
  }
}

class WorkTypesScreen extends StatefulWidget {
  const WorkTypesScreen({super.key});

  @override
  State<WorkTypesScreen> createState() => _WorkTypesScreenState();
}

class _WorkTypesScreenState extends State<WorkTypesScreen> {
  List<NamedItem> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await sl<CatalogRepository>().workTypes();
      if (mounted)
        setState(() {
          _rows = rows;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('أنواع الأعمال'),
        toolbarHeight: 76,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text('إدارة أنواع الأعمال المستخدمة في المشاريع'),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _rows.isEmpty
                ? const StatusView.empty(title: 'لا توجد أنواع أعمال')
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      IvoryMenuCard(
                        children: [
                          for (final row in _rows)
                            HubRow(
                              title: row.name,
                              icon: Icons.handyman_outlined,
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
                label: 'إضافة نوع',
                icon: Icons.add,
                onPressed: () async {
                  await context.push('/definitions');
                  if (mounted) _load();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryReportScreen extends StatelessWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final items = ExtraStore.instance.items.where((e) => e.finished).toList();
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('تقرير أصناف إنتاج تام'),
        toolbarHeight: 76,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: KpiStrip(
              items: [
                KpiItem('أول المدة', '3000'),
                KpiItem('إنتاج', '1000'),
                KpiItem('مبيعات', '15'),
                KpiItem('رصيد', '3987'),
              ],
            ),
          ),
          Expanded(
            child: IvorySheet(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return LedgerCard(
                    row: LedgerRow(
                      id: i,
                      title: item.name,
                      subtitle:
                          '${item.opening} + ${item.produced} − ${item.sold} + ${item.returned}',
                      amount: item.balance,
                      accent: c.stone,
                      badge: 'الرصيد الحالي',
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SupplierReportScreen extends StatelessWidget {
  const SupplierReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoneyJournalScreen(
      title: 'تقرير الموردين',
      kpis: [KpiItem('مستحق', '70000'), KpiItem('مدفوع', '3000')],
      lines: [
        DemoLine(
          title: 'موردين غزل',
          subtitle: 'رصيد افتتاحي',
          amount: '70000',
          badge: 'غزل',
        ),
        DemoLine(
          title: 'مورد تشطيبات',
          subtitle: 'خامات',
          amount: '14000',
          badge: 'تشطيب',
        ),
      ],
    );
  }
}

class MfgCustomersScreen extends StatelessWidget {
  const MfgCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoneyJournalScreen(
      title: 'عملاء التصنيع',
      kpis: [KpiItem('تحصيل', '18500'), KpiItem('متبقي', '4200')],
      lines: [
        DemoLine(
          title: 'خالد',
          subtitle: 'فاتورة إنتاج',
          amount: '8500',
          date: '12/05/2026',
        ),
        DemoLine(
          title: 'بدير',
          subtitle: 'فاتورة إنتاج',
          amount: '10250',
          date: '18/05/2026',
        ),
      ],
    );
  }
}

class ChecksScreen extends StatefulWidget {
  const ChecksScreen({super.key});

  @override
  State<ChecksScreen> createState() => _ChecksScreenState();
}

class _ChecksScreenState extends State<ChecksScreen> {
  bool _receivable = true;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final rows = _receivable
        ? const [
            DemoLine(
              title: '100001',
              subtitle: 'شركة النور للتجارة',
              amount: '2500',
              date: '2024/06/15',
            ),
            DemoLine(
              title: '100002',
              subtitle: 'خالد',
              amount: '7500',
              date: '2024/06/20',
            ),
          ]
        : const [
            DemoLine(
              title: '200011',
              subtitle: 'موردين غزل',
              amount: '4000',
              date: '2024/06/18',
              negative: true,
            ),
          ];
    return Scaffold(
      appBar: AppBar(title: const ScreenTitle('الشيكات'), toolbarHeight: 76),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _tab(c, 'شيكات عملاء مستحقة القبض', true, '10000'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _tab(c, 'شيكات موردين مستحقة الدفع', false, '4000'),
                ),
              ],
            ),
          ),
          Expanded(
            child: IvorySheet(
              child: LedgerList(
                rows: [
                  for (var i = 0; i < rows.length; i++)
                    LedgerRow(
                      id: i,
                      title: 'شيك ${rows[i].title}',
                      subtitle: '${rows[i].subtitle} · ${rows[i].date}',
                      amount: rows[i].amount,
                      accent: rows[i].negative ? c.terracotta : c.teal,
                      badge: 'ر.س',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(AtelierColors c, String label, bool receivable, String total) {
    final on = _receivable == receivable;
    return Material(
      color: c.raised,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => setState(() => _receivable = receivable),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: on ? c.brass : c.brass.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: c.ivory,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatMoney(total),
                style: TextStyle(color: c.brass, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoneyJournalScreen(
      title: 'تقرير المبيعات',
      kpis: [
        KpiItem('إجمالي المبيعات', '1250850.75'),
        KpiItem('عدد الفواتير', '356'),
      ],
      lines: [
        DemoLine(
          title: 'شركة الأمل للتجارة',
          subtitle: 'INV-100356',
          amount: '25850',
          date: '2024/05/31',
          badge: 'فاتورة',
        ),
        DemoLine(
          title: 'خالد',
          subtitle: 'INV-100350',
          amount: '8500',
          date: '2024/05/28',
          badge: 'فاتورة',
        ),
      ],
    );
  }
}

class FoodIncomeScreen extends StatelessWidget {
  const FoodIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatementLinesScreen(
      title: 'قائمة الدخل',
      subtitle: 'صناعات غذائية',
      net: '99000',
      lines: [
        ('إيرادات مبيعات خامات', '100000', Icons.shopping_cart_outlined, false),
        ('مصنعية تركيب', '10000', Icons.handyman_outlined, false),
        ('إجمالي إيرادات', '110000', Icons.payments_outlined, false),
        ('تكلفة خامات مباعة', '-10000', Icons.inventory_2_outlined, true),
        ('مجمل ربح', '100000', Icons.trending_up, false),
        ('إكراميات وبدلات', '1000', Icons.groups_outlined, true),
      ],
    );
  }
}

class AluminumIncomeScreen extends StatelessWidget {
  const AluminumIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatementLinesScreen(
      title: 'قائمة الدخل',
      subtitle: 'ألوميتال',
      heroBrand: 'ALU MAS  ·  ALUMINUM MANUFACTURING',
      net: '900',
      lines: [
        ('إجمالي توريدات نقدية', '1000', Icons.payments_outlined, false),
        ('مصاريف تصنيع', '—', Icons.settings_outlined, false),
        ('تكاليف سحب خامات', '—', Icons.inventory_2_outlined, false),
        ('إجمالي مصاريف إدارية', '100', Icons.work_outline, true),
        ('اشتراكات', '100', Icons.receipt_long_outlined, true),
      ],
    );
  }
}

class PrintPreviewScreen extends StatelessWidget {
  const PrintPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle(
          'طباعة / تصدير',
          subtitle: 'معاينة قائمة الدخل',
        ),
        toolbarHeight: 88,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.ivory,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'شطبها',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: c.stone,
                      ),
                    ),
                    Text(
                      'للمحاسبة وإدارة الأعمال',
                      style: TextStyle(
                        color: c.stone.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const BrassDiamond(),
                    const SizedBox(height: 12),
                    Text(
                      'قائمة الدخل',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: c.stone,
                      ),
                    ),
                    Text(
                      'الفترة من 01 مايو 2024 إلى 31 مايو 2024',
                      style: TextStyle(
                        color: c.stone.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _printRow(context, 'إجمالي التحصيل', '1000'),
                    _printRow(context, 'إجمالي المصاريف', '100'),
                    const Divider(),
                    _printRow(context, 'صافي الربح', '900', highlight: true),
                    const Spacer(),
                    Text(
                      'تاريخ الطباعة: 15 مايو 2024 09:41 ص',
                      style: TextStyle(
                        color: c.stone.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: AtelierButton(
                      label: 'طباعة',
                      icon: Icons.print_outlined,
                      onPressed: () => showAtelierSuccess(
                        context,
                        title: 'جاهز',
                        body: 'أُرسل أمر الطباعة',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AtelierButton(
                      label: 'PDF',
                      kind: AtelierButtonKind.secondary,
                      onPressed: () =>
                          showAtelierSuccess(context, body: 'تم تجهيز ملف PDF'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AtelierButton(
                      label: 'Excel',
                      kind: AtelierButtonKind.secondary,
                      onPressed: () => showAtelierSuccess(
                        context,
                        body: 'تم تجهيز ملف Excel',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _printRow(
    BuildContext context,
    String label,
    String amount, {
    bool highlight = false,
  }) {
    final c = context.atelier;
    final color = highlight ? c.brass : c.stone;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            formatMoney(amount),
            style: GoogleFonts.ibmPlexSansArabic(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _q = TextEditingController(text: 'خالد');

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final q = _q.text.trim();
    final show = q.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('البحث العالمي'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          TextField(
            controller: _q,
            decoration: const InputDecoration(
              hintText: 'ابحث عن عميل أو قيد…',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (show) ...[
            const SizedBox(height: 12),
            Text(
              '3 نتائج مطابقة لـ «$q»',
              style: TextStyle(color: c.ivoryMuted),
            ),
            const SizedBox(height: 12),
            const SectionLabel('العملاء (1)'),
            DarkMenuCard(
              children: [
                HubRow(
                  dark: true,
                  title: 'عميل $q',
                  subtitle: 'عميل نشط · رقم العميل: C-1023',
                  icon: Icons.person_outline,
                  onTap: () => context.push('/customers/picker'),
                ),
              ],
            ),
            const SectionLabel('الاتفاقات (1)'),
            DarkMenuCard(
              children: [
                HubRow(
                  dark: true,
                  title: 'اتفاق نقاشة',
                  subtitle: 'العميل: $q · 2024/05/22',
                  icon: Icons.description_outlined,
                  onTap: () => context.push('/jobs'),
                ),
              ],
            ),
            const SectionLabel('الأقساط (1)'),
            DarkMenuCard(
              children: [
                HubRow(
                  dark: true,
                  title: 'قسط ب.101',
                  subtitle: 'العميل: $q · 1,250.00',
                  icon: Icons.event_note_outlined,
                  onTap: () => context.push('/installments'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('النسخ الاحتياطي'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Icon(Icons.cloud_sync_outlined, size: 72, color: c.brass),
          const SizedBox(height: 12),
          Text(
            'قم بعمل نسخة احتياطية لبياناتك بشكل آمن واستعدها عند الحاجة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.ivoryMuted, height: 1.6),
          ),
          const SizedBox(height: 20),
          DarkMenuCard(
            children: [
              ListTile(
                leading: Icon(Icons.event, color: c.brass),
                title: const Text('آخر نسخة احتياطية'),
                trailing: const Text('2024/05/24 - 10:30 م'),
              ),
              ListTile(
                leading: Icon(Icons.storage_outlined, color: c.brass),
                title: const Text('حجم ملف قاعدة البيانات'),
                trailing: const Text('24.8 MB'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AtelierButton(
            label: 'إنشاء نسخة احتياطية الآن',
            icon: Icons.cloud_upload_outlined,
            onPressed: () =>
                showAtelierSuccess(context, body: 'تم إنشاء النسخة الاحتياطية'),
          ),
          const SizedBox(height: 10),
          AtelierButton(
            label: 'استعادة نسخة احتياطية',
            kind: AtelierButtonKind.secondary,
            icon: Icons.cloud_download_outlined,
            onPressed: () => showAtelierSuccess(
              context,
              title: 'استعادة',
              body: 'تمت محاكاة الاستعادة دون استبدال البيانات الحية',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.terracotta.withValues(alpha: 0.7)),
              color: c.terracotta.withValues(alpha: 0.12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: c.terracotta),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'تنبيه مهم: قد تؤدي عملية الاستعادة إلى استبدال البيانات الحالية. يرجى التأكد من وجود نسخة احتياطية حديثة.',
                    style: TextStyle(
                      color: c.ivoryMuted,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FixedAssetsScreen extends StatelessWidget {
  const FixedAssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoneyJournalScreen(
      title: 'الأصول الثابتة',
      kpis: [
        KpiItem('تكلفة', '185000'),
        KpiItem('إهلاك', '22000'),
        KpiItem('صافي', '163000'),
      ],
      lines: [
        DemoLine(
          title: 'سيارة نقل',
          subtitle: 'إهلاك سنوي',
          amount: '85000',
          badge: 'مركبة',
        ),
        DemoLine(
          title: 'معدات ورشة',
          subtitle: 'إنتاج',
          amount: '100000',
          badge: 'آلة',
        ),
      ],
    );
  }
}
