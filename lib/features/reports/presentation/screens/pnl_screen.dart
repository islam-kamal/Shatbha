import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/reports/data/models/report_models.dart';
import 'package:shatbha/features/reports/data/repositories/report_repository.dart';

import 'package:shatbha/features/shell/presentation/cubit/date_range_cubit.dart';

class PnLScreen extends StatefulWidget {
  const PnLScreen({super.key});

  @override
  State<PnLScreen> createState() => _PnLScreenState();
}

class _PnLScreenState extends State<PnLScreen> {
  IncomeStatement? _data;
  String? _error;
  bool _forbidden = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final range = context.read<DateRangeCubit>().state;
    try {
      final data = await sl<ReportRepository>().incomeStatement(
        from: range.fromIso,
        to: range.toIso,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
        _forbidden = false;
        _error = null;
      });
    } on ForbiddenFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _forbidden = true;
        _error = e.message;
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
    final c = context.atelier;
    final range = context.watch<DateRangeCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('قائمة الدخل'),
        toolbarHeight: 76,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () => context.push('/print'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _forbidden
              ? const StatusView.forbidden()
              : _error != null
                  ? StatusView.error(body: _error!)
                  : _data == null
                      ? const StatusView.empty()
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: DateRangeChip(
                                label: rangeLabel(range.from, range.to),
                                onTap: () async {
                                  final cubit = context.read<DateRangeCubit>();
                                  final from = await showDatePicker(
                                    context: context,
                                    initialDate: cubit.state.from ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (!context.mounted) return;
                                  final to = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        cubit.state.to ?? from ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  cubit.setRange(from, to);
                                  _load();
                                },
                              ),
                            ),
                            Text(
                              'صافي الربح',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatMoney(_data!.net),
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: c.brass,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const BrassDiamond(),
                            const SizedBox(height: 16),
                            Expanded(
                              child: IvorySheet(
                                child: ListView(
                                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
                                  children: [
                                    for (final line in _data!.lines)
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: line.kind == 'income'
                                              ? c.cashTint
                                              : c.expenseTint,
                                          child: Icon(
                                            line.kind == 'income'
                                                ? Icons.person_outline
                                                : Icons.work_outline,
                                            color: c.stone,
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          line.label,
                                          style: GoogleFonts.ibmPlexSansArabic(
                                            color: line.kind == 'expense'
                                                ? c.terracotta
                                                : c.stone,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        trailing: Text(
                                          formatMoney(line.amount),
                                          style: GoogleFonts.ibmPlexSansArabic(
                                            color: line.kind == 'expense'
                                                ? c.terracotta
                                                : c.stone,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: c.brass,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.bar_chart, color: c.stone),
                                          const SizedBox(width: 8),
                                          Text(
                                            'صافي الربح',
                                            style: GoogleFonts.ibmPlexSansArabic(
                                              color: c.stone,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            formatMoney(_data!.net),
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
