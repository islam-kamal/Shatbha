import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/format.dart';
import '../../theme/atelier_theme.dart';
import '../../widgets/widgets.dart';
import 'extra_store.dart';

class MoneyJournalScreen extends StatelessWidget {
  const MoneyJournalScreen({
    super.key,
    required this.title,
    required this.lines,
    this.subtitle,
    this.kpis = const [],
    this.addLabel,
    this.addPath,
    this.heroAmount,
    this.heroLabel,
  });

  final String title;
  final String? subtitle;
  final List<KpiItem> kpis;
  final List<DemoLine> lines;
  final String? addLabel;
  final String? addPath;
  final String? heroAmount;
  final String? heroLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(title, subtitle: subtitle),
        toolbarHeight: subtitle == null ? 76 : 88,
      ),
      body: Column(
        children: [
          if (heroAmount != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: c.raised,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.brass.withValues(alpha: 0.45)),
                ),
                child: Column(
                  children: [
                    Text(
                      heroLabel ?? title,
                      style: TextStyle(color: c.brass, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatMoney(heroAmount),
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: c.brass,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (kpis.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: KpiStrip(items: kpis),
            ),
          Expanded(
            child: IvorySheet(
              child: LedgerList(
                rows: [
                  for (var i = 0; i < lines.length; i++)
                    LedgerRow(
                      id: i,
                      title: lines[i].title,
                      subtitle: [
                        if (lines[i].subtitle.isNotEmpty) lines[i].subtitle,
                        if (lines[i].date.isNotEmpty) lines[i].date,
                      ].join(' · '),
                      amount: lines[i].amount,
                      accent: lines[i].negative ? c.terracotta : c.teal,
                      badge: lines[i].badge,
                    ),
                ],
                onTap: (row) {
                  final line = lines[row.id];
                  if (line.path != null) context.push(line.path!);
                },
              ),
            ),
          ),
          if (addLabel != null && addPath != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: AtelierButton(
                  label: addLabel!,
                  icon: Icons.add,
                  onPressed: () => context.push(addPath!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AddFieldSpec {
  const AddFieldSpec(this.key, this.label, {this.kind = AddFieldKind.text, this.options});
  final String key;
  final String label;
  final AddFieldKind kind;
  final List<String>? options;
}

enum AddFieldKind { text, amount, date, notes, dropdown }

class SimpleAddScreen extends StatefulWidget {
  const SimpleAddScreen({
    super.key,
    required this.title,
    required this.fields,
    required this.successBody,
    this.saveLabel = 'حفظ',
    this.onSave,
  });

  final String title;
  final List<AddFieldSpec> fields;
  final String successBody;
  final String saveLabel;
  final void Function(Map<String, String> values)? onSave;

  @override
  State<SimpleAddScreen> createState() => _SimpleAddScreenState();
}

class _SimpleAddScreenState extends State<SimpleAddScreen> {
  late final Map<String, TextEditingController> _ctrls;
  late final Map<String, String> _drops;
  DateTime _date = DateTime(2026, 5, 15);

  @override
  void initState() {
    super.initState();
    _ctrls = {
      for (final f in widget.fields)
        if (f.kind != AddFieldKind.date && f.kind != AddFieldKind.dropdown)
          f.key: TextEditingController(),
    };
    _drops = {
      for (final f in widget.fields)
        if (f.kind == AddFieldKind.dropdown) f.key: f.options!.first,
    };
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(widget.title),
        toolbarHeight: 76,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final field in widget.fields) ...[
            _buildField(field),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          AtelierButton(
            label: widget.saveLabel,
            icon: Icons.save_outlined,
            onPressed: () async {
              final values = <String, String>{
                for (final e in _ctrls.entries) e.key: e.value.text.trim(),
                ..._drops,
                'date': formatDate(_date),
              };
              widget.onSave?.call(values);
              if (!context.mounted) return;
              await showAtelierSuccess(context, body: widget.successBody);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildField(AddFieldSpec field) {
    switch (field.kind) {
      case AddFieldKind.date:
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(field.label),
          subtitle: Text(formatDate(_date)),
          trailing: const Icon(Icons.event),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => _date = picked);
          },
        );
      case AddFieldKind.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: _drops[field.key],
          items: [
            for (final o in field.options!)
              DropdownMenuItem(value: o, child: Text(o)),
          ],
          onChanged: (v) => setState(() => _drops[field.key] = v ?? field.options!.first),
          decoration: InputDecoration(labelText: field.label),
        );
      default:
        return TextField(
          controller: _ctrls[field.key],
          keyboardType: field.kind == AddFieldKind.amount
              ? TextInputType.number
              : TextInputType.text,
          maxLines: field.kind == AddFieldKind.notes ? 3 : 1,
          decoration: InputDecoration(labelText: field.label),
        );
    }
  }
}

class StatementLinesScreen extends StatelessWidget {
  const StatementLinesScreen({
    super.key,
    required this.title,
    required this.net,
    required this.lines,
    this.subtitle,
    this.netLabel = 'صافي الربح',
    this.heroBrand,
  });

  final String title;
  final String? subtitle;
  final String net;
  final String netLabel;
  final String? heroBrand;
  final List<(String label, String amount, IconData icon, bool expense)> lines;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(title, subtitle: subtitle),
        toolbarHeight: subtitle == null ? 76 : 88,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          if (heroBrand != null) ...[
            Text(
              heroBrand!,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: c.brass,
                letterSpacing: 2,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            netLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            formatMoney(net),
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: c.brass,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const BrassDiamond(),
          const SizedBox(height: 18),
          IvorySheet(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
              child: Column(
                children: [
                  for (final line in lines)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: line.$4 ? c.expenseTint : c.cashTint,
                        child: Icon(line.$3, color: c.stone, size: 20),
                      ),
                      title: Text(
                        line.$1,
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: line.$4 ? c.terracotta : c.stone,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        line.$2 == '—' ? '—' : formatMoney(line.$2),
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: line.$4 ? c.terracotta : c.stone,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: c.brass,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bar_chart, color: c.stone),
                        const SizedBox(width: 8),
                        Text(
                          netLabel,
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: c.stone,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatMoney(net),
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: c.stone,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                      ],
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
}

class RaisedInfoRow extends StatelessWidget {
  const RaisedInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final color = accent ?? c.ivory;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: c.brass, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: TextStyle(color: c.ivoryMuted, fontSize: 14)),
          ),
          Text(
            value,
            style: GoogleFonts.ibmPlexSansArabic(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
