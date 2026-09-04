import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';

import '../../data/project_os_api.dart';

/// Guided win flow: Lead → Project + Contract
class WinWizardScreen extends StatefulWidget {
  const WinWizardScreen({super.key, required this.leadId});
  final int leadId;

  @override
  State<WinWizardScreen> createState() => _WinWizardScreenState();
}

class _WinWizardScreenState extends State<WinWizardScreen> {
  int _step = 0;
  final _projectName = TextEditingController();
  final _contractValue = TextEditingController();
  final _startDate = TextEditingController();
  bool _saving = false;

  static const _stepTitles = [
    'معلومات المشروع',
    'قيمة العقد',
    'تاريخ البدء',
  ];

  @override
  void dispose() {
    _projectName.dispose();
    _contractValue.dispose();
    _startDate.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_projectName.text.trim().isEmpty ||
        _contractValue.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال جميع الحقول المطلوبة')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await sl<ProjectOsApi>().winLead(widget.leadId, {
        'project_name': _projectName.text.trim(),
        'contract_value': _contractValue.text.trim(),
        if (_startDate.text.trim().isNotEmpty)
          'start_date': _startDate.text.trim(),
      });
      if (!mounted) return;
      final project = result['project'] as Map<String, dynamic>?;
      final projectId = project?['id'] as int?;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تهانينا! تم تحويل العميل لمشروع')),
      );
      if (projectId != null) {
        context.go('/projects/$projectId');
      } else {
        context.go('/projects');
      }
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _next() {
    if (_step == 0 && _projectName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل اسم المشروع')),
      );
      return;
    }
    if (_step == 1 && _contractValue.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل قيمة العقد')),
      );
      return;
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final ivoryTheme = buildAtelierIvoryTheme(Theme.of(context));

    return Scaffold(
      backgroundColor: c.stone,
      appBar: AppBar(
        title: const ScreenTitle(
          'معالج الإتمام',
          subtitle: 'تحويل العميل لمشروع',
        ),
        toolbarHeight: 88,
      ),
      body: IvorySheet(
        child: Theme(
          data: ivoryTheme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: List.generate(3, (i) {
                    final active = i <= _step;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                        height: 4,
                        decoration: BoxDecoration(
                          color: active ? c.brass : c.ivoryMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  'الخطوة ${_step + 1} من 3 — ${_stepTitles[_step]}',
                  style: TextStyle(
                    color: c.stone,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    SheetCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _stepBody(c),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: AtelierButton(
                          label: _step == 2
                              ? (_saving ? 'جاري الحفظ…' : 'إتمام')
                              : 'التالي',
                          onPressed: _saving ? null : _next,
                        ),
                      ),
                      if (_step > 0) ...[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _saving
                              ? null
                              : () => setState(() => _step--),
                          child: Text(
                            'السابق',
                            style: TextStyle(
                              color: c.stone.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBody(AtelierColors c) {
    final labelStyle = TextStyle(
      color: c.stone.withValues(alpha: 0.7),
      fontWeight: FontWeight.w600,
      fontSize: 13,
    );
    final fieldDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: c.stone.withValues(alpha: 0.65)),
      hintStyle: TextStyle(color: c.stone.withValues(alpha: 0.4)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.ivoryMuted),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.brass, width: 1.5),
      ),
    );

    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('اسم المشروع *', style: labelStyle),
            const SizedBox(height: 8),
            TextField(
              controller: _projectName,
              style: TextStyle(color: c.stone, fontWeight: FontWeight.w600),
              decoration: fieldDecoration.copyWith(
                hintText: 'مثال: تشطيب شقة المعادي',
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('قيمة العقد (ج.م) *', style: labelStyle),
            const SizedBox(height: 8),
            TextField(
              controller: _contractValue,
              keyboardType: TextInputType.number,
              style: TextStyle(color: c.stone, fontWeight: FontWeight.w600),
              decoration: fieldDecoration.copyWith(hintText: '650000'),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('تاريخ البدء', style: labelStyle),
            const SizedBox(height: 8),
            TextField(
              controller: _startDate,
              keyboardType: TextInputType.datetime,
              style: TextStyle(color: c.stone, fontWeight: FontWeight.w600),
              decoration: fieldDecoration.copyWith(hintText: 'YYYY-MM-DD'),
            ),
            const SizedBox(height: 14),
            Text(
              'سيتم إنشاء المشروع وربط عقد وخطة دفع تلقائياً عند الإتمام.',
              style: TextStyle(
                color: c.stone.withValues(alpha: 0.65),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        );
    }
  }
}
