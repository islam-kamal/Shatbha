import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';

import '../../../auth/presentation/cubit/auth_bloc.dart';
import '../../../projects/data/models/project_models.dart';
import '../../../projects/data/repositories/project_repository.dart';
import '../../data/repositories/quote_repository.dart';
import '../cubit/quote_cubit.dart';

class ContractorsMarketplaceScreen extends StatelessWidget {
  const ContractorsMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuoteCubit(sl(), sl())..loadContractors(),
      child: const _ContractorsView(),
    );
  }
}

class _ContractorsView extends StatelessWidget {
  const _ContractorsView();

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('المقاولون', subtitle: 'اكتشف واطلب عروض'),
        toolbarHeight: 88,
        actions: [
          IconButton(
            icon: const Icon(Icons.request_quote_outlined),
            onPressed: () => context.push('/quotes'),
          ),
        ],
      ),
      body: BlocBuilder<QuoteCubit, QuoteState>(
        builder: (context, state) {
          if (state.loading && state.contractors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.contractors.isEmpty) {
            return StatusView.error(body: state.error!);
          }
          if (state.contractors.isEmpty) {
            return StatusView.empty(
              title: 'لا يوجد مقاولون',
              body: 'سيظهر المقاولون المسجلون في السوق هنا.',
            );
          }
          return IvorySheet(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: state.contractors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final v = state.contractors[i];
                return LedgerCard(
                  row: LedgerRow(
                    id: v.id,
                    title: v.name,
                    subtitle: v.specialties.join(' · '),
                    amount: v.rating > 0 ? v.rating.toStringAsFixed(1) : '—',
                    accent: c.terracotta,
                    badge: v.location,
                  ),
                  onTap: () =>
                      context.push('/contractors/${v.id}/request-quote'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class RequestQuoteScreen extends StatefulWidget {
  const RequestQuoteScreen({super.key, required this.contractorId});
  final int contractorId;

  @override
  State<RequestQuoteScreen> createState() => _RequestQuoteScreenState();
}

class _RequestQuoteScreenState extends State<RequestQuoteScreen> {
  final _description = TextEditingController();
  final _notes = TextEditingController();
  List<Project> _projects = [];
  Project? _selected;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final rows = await sl<ProjectRepository>().list();
      if (!mounted) return;
      setState(() {
        _projects = rows;
        _selected = rows.isNotEmpty ? rows.first : null;
        _loading = false;
      });
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  void dispose() {
    _description.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selected == null || _description.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await sl<QuoteRepository>().create({
        'project_id': _selected!.id,
        'vendor_account_id': widget.contractorId,
        'title': _description.text.trim(),
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب العرض')),
      );
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
        title: const ScreenTitle('طلب عرض سعر'),
        toolbarHeight: 76,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : IvorySheet(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (_projects.isEmpty)
                    const Text('أنشئ مشروعاً أولاً لطلب عرض سعر.')
                  else ...[
                    DropdownButtonFormField<Project>(
                      initialValue: _selected,
                      decoration: const InputDecoration(labelText: 'المشروع'),
                      items: [
                        for (final p in _projects)
                          DropdownMenuItem(value: p, child: Text(p.name)),
                      ],
                      onChanged: (p) => setState(() => _selected = p),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _description,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'وصف الأعمال *',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notes,
                      decoration: const InputDecoration(labelText: 'ملاحظات'),
                    ),
                    const SizedBox(height: 24),
                    AtelierButton(
                      label: _saving ? 'جاري الإرسال...' : 'إرسال الطلب',
                      icon: Icons.send_outlined,
                      onPressed: _saving || _projects.isEmpty ? null : _submit,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class QuotesListScreen extends StatelessWidget {
  const QuotesListScreen({super.key, this.projectId});
  final int? projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuoteCubit(sl(), sl())..loadQuotes(projectId: projectId),
      child: _QuotesListView(projectId: projectId),
    );
  }
}

class _QuotesListView extends StatelessWidget {
  const _QuotesListView({this.projectId});
  final int? projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final isVendor = context.select<AuthBloc, bool>(
      (b) =>
          b.state is AuthAuthenticated &&
          (b.state as AuthAuthenticated).user.isVendor,
    );
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('عروض الأسعار'),
        toolbarHeight: 76,
      ),
      body: BlocBuilder<QuoteCubit, QuoteState>(
        builder: (context, state) {
          if (state.loading && state.quotes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.quotes.isEmpty) {
            return StatusView.error(body: state.error!);
          }
          if (state.quotes.isEmpty) {
            return StatusView.empty(
              title: 'لا توجد طلبات',
              body: isVendor
                  ? 'ستظهر هنا طلبات العروض المرسلة إليك من شركات التشطيب.'
                  : 'اطلب عروضاً من المقاولين ليظهر هنا.',
              actionLabel: isVendor ? null : 'اكتشف مقاولين',
              onAction: isVendor ? null : () => context.push('/contractors'),
            );
          }
          return IvorySheet(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: state.quotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final q = state.quotes[i];
                final title = isVendor
                    ? (q.projectName ?? 'مشروع #${q.projectId}')
                    : (q.contractorName ?? 'مقاول #${q.contractorId}');
                final subtitle = isVendor
                    ? '${q.description ?? q.notes ?? ''} · ${_statusLabel(q.status)}'
                    : '${q.projectName ?? ''} · ${_statusLabel(q.status)}';
                return LedgerCard(
                  row: LedgerRow(
                    id: q.id,
                    title: title,
                    subtitle: subtitle,
                    amount: q.amount ?? '—',
                    accent: q.isAccepted
                        ? c.teal
                        : q.isResponded
                            ? c.brass
                            : c.dateTint,
                    badge: !isVendor && q.isResponded && !q.isAccepted
                        ? 'قبول'
                        : null,
                  ),
                  onTap: !isVendor && q.isResponded && !q.isAccepted
                      ? () => _accept(context, q.id)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _accept(BuildContext context, int id) async {
    final ok = await context.read<QuoteCubit>().acceptQuote(id);
    if (context.mounted && ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول العرض')),
      );
    }
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'pending':
    case 'draft':
      return 'قيد الانتظار';
    case 'responded':
    case 'sent':
      return 'تم الرد';
    case 'accepted':
      return 'مقبول';
    case 'rejected':
      return 'مرفوض';
    default:
      return status;
  }
}
