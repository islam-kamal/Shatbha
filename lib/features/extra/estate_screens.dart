import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/format.dart';
import '../../theme/atelier_theme.dart';
import '../../widgets/widgets.dart';
import 'extra_store.dart';
import 'kit.dart';

class UnitSalesScreen extends StatelessWidget {
  const UnitSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    const units = [
      ('101-b', '101-ب', 'خالد', '140', '1800000', '600000', '1200000', 0.33),
      ('102-b', '102-ب', 'عميل 1', '120', '1500000', '900000', '600000', 0.60),
      ('201-c', '201-ج', 'بدير', '160', '1500000', '250000', '1250000', 0.17),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('مبيعات وحدات', subtitle: 'إجمالي أداء المبيعات'),
        toolbarHeight: 88,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          const KpiStrip(
            items: [
              KpiItem('وحدات مباعة', '3'),
              KpiItem('قيمة البيوع', '4800000'),
              KpiItem('محصل', '1200000'),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('تفاصيل الوحدات المباعة'),
          for (final u in units)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: c.raised,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/units/${u.$1}'),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.apartment_outlined, color: c.brass),
                            const SizedBox(width: 8),
                            Text(
                              u.$2,
                              style: GoogleFonts.ibmPlexSansArabic(
                                color: c.brass,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                            Text(u.$3, style: TextStyle(color: c.ivory)),
                            const SizedBox(width: 8),
                            Text('${u.$4} م²', style: TextStyle(color: c.ivoryMuted, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _mini(context, 'إجمالي', u.$5),
                            _mini(context, 'المحصل', u.$6),
                            _mini(context, 'المتبقي', u.$7),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: u.$8,
                            minHeight: 8,
                            color: c.brass,
                            backgroundColor: c.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _mini(BuildContext context, String label, String value) {
    final c = context.atelier;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(color: c.ivoryMuted, fontSize: 11)),
          Text(formatMoney(value), style: TextStyle(color: c.ivory, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class UnitDetailScreen extends StatelessWidget {
  const UnitDetailScreen({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle('تفاصيل الوحدة', subtitle: code),
        toolbarHeight: 88,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          DarkMenuCard(
            children: [
              ListTile(title: const Text('الوحدة'), trailing: Text(code == '201-c' ? '201-ج' : code)),
              ListTile(title: const Text('العميل'), trailing: const Text('بدير')),
              ListTile(title: const Text('المساحة'), trailing: const Text('160 م²')),
              ListTile(title: const Text('إجمالي السعر'), trailing: Text(formatMoney('1500000'))),
              ListTile(title: const Text('المحصل'), trailing: Text(formatMoney('250000'))),
              ListTile(
                title: const Text('المتبقي'),
                trailing: Text(formatMoney('1250000'), style: TextStyle(color: c.brass)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AtelierButton(
            label: 'تحصيل قسط',
            icon: Icons.payments_outlined,
            onPressed: () => context.push('/units/$code/collect'),
          ),
        ],
      ),
    );
  }
}

class CollectInstallmentScreen extends StatefulWidget {
  const CollectInstallmentScreen({super.key, this.code = '201-c'});
  final String code;

  @override
  State<CollectInstallmentScreen> createState() => _CollectInstallmentScreenState();
}

class _CollectInstallmentScreenState extends State<CollectInstallmentScreen> {
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  bool _cash = true;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('تحصيل قسط', subtitle: 'تسجيل تحصيل قسط للعميل'),
        toolbarHeight: 88,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          DarkMenuCard(
            children: [
              ListTile(
                leading: Icon(Icons.person_outline, color: c.brass),
                title: const Text('بدير'),
                subtitle: Text('الوحدة ${widget.code == '201-c' ? '201-ج' : widget.code}'),
                trailing: Text(
                  widget.code == '201-c' ? '201-ج' : widget.code,
                  style: TextStyle(color: c.brass),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DarkMenuCard(
            children: [
              ListTile(
                leading: Icon(Icons.event, color: c.brass),
                title: const Text('تاريخ الاستحقاق'),
                trailing: const Text('01/06/2026'),
              ),
              ListTile(
                leading: Icon(Icons.payments_outlined, color: c.brass),
                title: const Text('المبلغ المستحق'),
                trailing: Text(formatMoney('150000')),
              ),
              ListTile(
                leading: Icon(Icons.schedule, color: c.terracotta),
                title: const Text('حالة القسط'),
                trailing: Text('متأخر', style: TextStyle(color: c.terracotta)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('بيانات التحصيل'),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'مبلغ التحصيل', suffixText: 'ج.م'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _method(c, 'نقدي', true, Icons.payments_outlined)),
              const SizedBox(width: 8),
              Expanded(child: _method(c, 'شيك', false, Icons.credit_card)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
          ),
          const SizedBox(height: 20),
          AtelierButton(
            label: 'تأكيد التحصيل',
            icon: Icons.verified_outlined,
            onPressed: () async {
              await showAtelierSuccess(context, body: 'تم تسجيل التحصيل بنجاح');
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _method(AtelierColors c, String label, bool cash, IconData icon) {
    final on = _cash == cash;
    return Material(
      color: c.raised,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _cash = cash),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: on ? c.brass : c.brass.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: c.brass, size: 18),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: c.ivory, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class ContractingScreen extends StatelessWidget {
  const ContractingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoneyJournalScreen(
      title: 'أعمال مقاولات',
      kpis: const [
        KpiItem('مشاريع', '2'),
        KpiItem('قيمة', '420000'),
      ],
      lines: const [
        DemoLine(title: 'فيلا الساكت', subtitle: 'نقاشة + جبس', amount: '250000', path: '/cubing'),
        DemoLine(title: 'عمارة المعادي', subtitle: 'كهرباء تشطيب', amount: '170000', path: '/cubing'),
      ],
      addLabel: 'مشروع جديد',
      addPath: '/jobs/add',
    );
  }
}

class InstallmentsScreen extends StatelessWidget {
  const InstallmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoneyJournalScreen(
      title: 'تقرير الأقساط',
      kpis: const [
        KpiItem('مستحق', '150000'),
        KpiItem('محصل', '250000'),
        KpiItem('متأخر', '150000', tint: Color(0xFFE8C9BC)),
      ],
      lines: const [
        DemoLine(
          title: 'قسط ب.101',
          subtitle: 'بدير · الوحدة 201-ج',
          amount: '150000',
          date: '01/06/2026',
          badge: 'متأخر',
          path: '/units/201-c/collect',
        ),
        DemoLine(
          title: 'قسط 101-ب',
          subtitle: 'خالد',
          amount: '200000',
          date: '01/05/2026',
          badge: 'محصل',
        ),
      ],
    );
  }
}

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoneyJournalScreen(
      title: 'تقرير الشركاء',
      kpis: [
        KpiItem('رأس المال', '2000000'),
        KpiItem('أرباح', '20000'),
      ],
      lines: [
        DemoLine(title: 'الشريك أ', subtitle: 'حصة 60%', amount: '1200000', badge: '60%'),
        DemoLine(title: 'الشريك ب', subtitle: 'حصة 40%', amount: '800000', badge: '40%'),
      ],
    );
  }
}

class PartnersJournalScreen extends StatelessWidget {
  const PartnersJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ExtraStore.instance,
      builder: (context, _) {
        return MoneyJournalScreen(
          title: 'يومية الشركاء',
          lines: ExtraStore.instance.partnerEntries,
          addLabel: 'قيد شريك',
          addPath: '/partners/journal/add',
        );
      },
    );
  }
}

class AddPartnerEntryScreen extends StatelessWidget {
  const AddPartnerEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleAddScreen(
      title: 'قيد شريك',
      successBody: 'تم تسجيل قيد الشريك',
      fields: const [
        AddFieldSpec('title', 'البيان'),
        AddFieldSpec('amount', 'المبلغ', kind: AddFieldKind.amount),
        AddFieldSpec('date', 'التاريخ', kind: AddFieldKind.date),
      ],
      onSave: (v) {
        ExtraStore.instance.addPartnerEntry(
          DemoLine(title: v['title'] ?? 'قيد', amount: v['amount'] ?? '0', date: v['date'] ?? ''),
        );
      },
    );
  }
}

class PartnerAgreeScreen extends StatelessWidget {
  const PartnerAgreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle(
          'اتفاق شركاء',
          subtitle: 'إعداد توزيع الحصص بين الشركاء',
        ),
        toolbarHeight: 88,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          DarkMenuCard(
            children: [
              ListTile(
                leading: Icon(Icons.balance, color: c.brass),
                title: const Text('إجمالي رأس المال'),
                trailing: Text(
                  formatMoney('2000000'),
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: c.brass,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('توزيع الحصص'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.raised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.brass.withValues(alpha: 0.28)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: CustomPaint(painter: _SharePie(c.brass, c.muted)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الشريك أ  ·  60%  ·  ${formatMoney('1200000')}', style: TextStyle(color: c.ivory)),
                      const SizedBox(height: 8),
                      Text('الشريك ب  ·  40%  ·  ${formatMoney('800000')}', style: TextStyle(color: c.ivoryMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionLabel('تفاصيل الشركاء'),
          DarkMenuCard(
            children: const [
              HubRow(dark: true, title: 'الشريك أ', subtitle: '60% · 1,200,000', icon: Icons.person_outline, onTap: _noop),
              HubRow(dark: true, title: 'الشريك ب', subtitle: '40% · 800,000', icon: Icons.person_outline, onTap: _noop),
            ],
          ),
          const SizedBox(height: 16),
          AtelierButton(
            label: 'حفظ الاتفاق ومتابعة',
            onPressed: () => showAtelierSuccess(context, body: 'تم حفظ اتفاق الشركاء'),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

class _SharePie extends CustomPainter {
  _SharePie(this.brass, this.muted);
  final Color brass;
  final Color muted;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * 0.6, true, Paint()..color = brass);
    canvas.drawArc(
      rect,
      -math.pi / 2 + math.pi * 2 * 0.6,
      math.pi * 2 * 0.4,
      true,
      Paint()..color = muted,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('الميزانية العمومية'),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _block(
            context,
            'أصول',
            Icons.layers_outlined,
            const [
              ('رصيد العملاء', '1380', Icons.groups_outlined),
              ('شيكات عملاء', '10000', Icons.credit_card),
              ('مخزون غزل', '84067', Icons.inventory_2_outlined),
            ],
            'إجمالي الأصول',
            '95447',
          ),
          const SizedBox(height: 14),
          _block(
            context,
            'خصوم',
            Icons.account_balance_outlined,
            [
              ('موردين غزل', '70000', Icons.local_shipping_outlined),
              ('صافي الربح', '-2360', Icons.trending_down),
              ('رأس المال', '27807', Icons.shield_outlined),
            ],
            'إجمالي الخصوم',
            '95447',
            negativeKey: 'صافي الربح',
            terracotta: c.terracotta,
          ),
        ],
      ),
    );
  }

  Widget _block(
    BuildContext context,
    String title,
    IconData icon,
    List<(String, String, IconData)> rows,
    String totalLabel,
    String total, {
    String? negativeKey,
    Color? terracotta,
  }) {
    final c = context.atelier;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.brass.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: c.brass),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: c.brass, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          for (final row in rows)
            RaisedInfoRow(
              label: row.$1,
              value: formatMoney(row.$2),
              icon: row.$3,
              accent: row.$1 == negativeKey ? terracotta : null,
            ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: c.brass,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.pie_chart_outline, color: c.stone),
                const SizedBox(width: 8),
                Text(totalLabel, style: TextStyle(color: c.stone, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(
                  formatMoney(total),
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: c.stone,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
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
