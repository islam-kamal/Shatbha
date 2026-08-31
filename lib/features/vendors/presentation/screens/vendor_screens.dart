import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shatbha/core/core.dart';

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
