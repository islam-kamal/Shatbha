import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/auth/presentation/cubit/auth_bloc.dart';
import 'package:shatbha/features/auth/data/models/auth_models.dart';
import 'package:shatbha/features/sync/presentation/cubit/sync_cubit.dart';
import '../cubit/date_range_cubit.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final vendorMode =
        auth is AuthAuthenticated && auth.user.isVendor;
    final shellIndex = navigationShell.currentIndex;
    final navIndex = vendorMode ? (shellIndex >= 3 ? 1 : 0) : shellIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        vendorMode: vendorMode,
        index: navIndex,
        onTap: (i) {
          if (vendorMode) {
            navigationShell.goBranch(i == 0 ? 0 : 3);
          } else {
            navigationShell.goBranch(i);
          }
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;
    final isVendor = user?.isVendor ?? false;
    final slogan = isVendor
        ? (user!.role == 'supplier'
            ? 'حساب مورد — إدارة منتجاتك'
            : 'حساب مقاول — طلبات العروض')
        : 'أتيليه التشطيبات والمقاولات';

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: BrandLockup(slogan: slogan),
            ),
          ),
          Expanded(
            child: IvorySheet(
              child: GridView.count(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.22,
                children: isVendor
                    ? _vendorTiles(context, user!)
                    : _companyTiles(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _companyTiles(BuildContext context) => [
        HomeNavTile(
          title: 'المشاريع',
          icon: Icons.apartment_outlined,
          onTap: () => context.push('/projects'),
        ),
        HomeNavTile(
          title: 'التصميم',
          icon: Icons.palette_outlined,
          onTap: () => context.push('/design'),
        ),
        HomeNavTile(
          title: 'المقاولون',
          icon: Icons.engineering_outlined,
          onTap: () => context.push('/contractors'),
        ),
        HomeNavTile(
          title: 'المواد',
          icon: Icons.inventory_2_outlined,
          onTap: () => context.push('/materials'),
        ),
        HomeNavTile(
          title: 'يومية العملاء',
          icon: Icons.groups_outlined,
          onTap: () => context.push('/journal'),
        ),
        HomeNavTile(
          title: 'مصاريف إدارية',
          icon: Icons.account_balance_wallet_outlined,
          onTap: () => context.push('/expenses'),
        ),
        HomeNavTile(
          title: 'اتفاق مقاولين',
          icon: Icons.handshake_outlined,
          onTap: () => context.push('/jobs'),
        ),
        HomeNavTile(
          title: 'قائمة الدخل',
          icon: Icons.show_chart,
          onTap: () => context.push('/pnl'),
        ),
      ];

  List<Widget> _vendorTiles(BuildContext context, AuthUser user) {
    if (user.role == 'supplier') {
      return [
        HomeNavTile(
          title: 'منتجاتي',
          icon: Icons.inventory_2_outlined,
          onTap: () => context.push('/materials/supplier/${user.id}'),
        ),
        HomeNavTile(
          title: 'ملفي',
          icon: Icons.storefront_outlined,
          onTap: () => context.push('/vendors/${user.id}'),
        ),
      ];
    }
    return [
      HomeNavTile(
        title: 'طلبات العروض',
        icon: Icons.request_quote_outlined,
        onTap: () => context.push('/quotes'),
      ),
      HomeNavTile(
        title: 'ملفي',
        icon: Icons.engineering_outlined,
        onTap: () => context.push('/vendors/${user.id}'),
      ),
    ];
  }
}

class LedgerHubScreen extends StatelessWidget {
  const LedgerHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('دفتر'),
        toolbarHeight: 76,
        automaticallyImplyLeading: false,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            IvoryMenuCard(
              children: [
                HubRow(
                  title: 'يومية العملاء',
                  subtitle: 'تحصيل ومصنعيات ومرتجعات',
                  icon: Icons.person_outline,
                  onTap: () => context.push('/journal'),
                ),
                HubRow(
                  title: 'مصاريف إدارية',
                  subtitle: 'حركة المصروف اليومي',
                  icon: Icons.work_outline,
                  onTap: () => context.push('/expenses'),
                ),
                HubRow(
                  title: 'إيرادات أخرى',
                  icon: Icons.trending_up,
                  onTap: () => context.push('/revenues'),
                ),
                HubRow(
                  title: 'يومية الموردين',
                  icon: Icons.groups_outlined,
                  onTap: () => context.push('/suppliers/journal'),
                ),
                HubRow(
                  title: 'يومية مجمعة',
                  icon: Icons.layers_outlined,
                  onTap: () => context.push('/general-journal'),
                ),
                HubRow(
                  title: 'اتفاق مقاولين',
                  subtitle: 'الأعمال والمتبقي والدفعات',
                  icon: Icons.handshake_outlined,
                  onTap: () => context.push('/jobs'),
                ),
                HubRow(
                  title: 'تقرير العهد',
                  icon: Icons.assignment_outlined,
                  onTap: () => context.push('/petty-cash'),
                ),
                HubRow(
                  title: 'سحب خامات',
                  icon: Icons.unarchive_outlined,
                  onTap: () => context.push('/inventory/out'),
                ),
                HubRow(
                  title: 'تسجيل إنتاج',
                  icon: Icons.factory_outlined,
                  onTap: () => context.push('/production'),
                ),
                HubRow(
                  title: 'يومية الشركاء',
                  icon: Icons.diversity_3_outlined,
                  onTap: () => context.push('/partners/journal'),
                ),
                HubRow(
                  title: 'أعمال مقاولات',
                  icon: Icons.location_city_outlined,
                  onTap: () => context.push('/contracting'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final range = context.watch<DateRangeCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('تقارير'),
        toolbarHeight: 76,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: DateRangeChip(
              label: rangeLabel(range.from, range.to),
              onTap: () => pickReportDates(context),
            ),
          ),
          Expanded(
            child: IvorySheet(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  IvoryMenuCard(
                    children: [
                      HubRow(
                        title: 'تقرير العملاء',
                        icon: Icons.groups_outlined,
                        onTap: () => context.push('/reports/customers'),
                      ),
                      HubRow(
                        title: 'قائمة الدخل',
                        icon: Icons.bar_chart,
                        onTap: () => context.push('/pnl'),
                      ),
                      HubRow(
                        title: 'تقرير المقاولين',
                        icon: Icons.engineering_outlined,
                        onTap: () => context.push('/reports/contractors'),
                      ),
                      HubRow(
                        title: 'تقرير المصروفات',
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () => context.push('/reports/expenses'),
                      ),
                      HubRow(
                        title: 'تقرير المبيعات',
                        icon: Icons.shopping_cart_outlined,
                        onTap: () => context.push('/reports/sales'),
                      ),
                      HubRow(
                        title: 'تقرير الموردين',
                        icon: Icons.local_shipping_outlined,
                        onTap: () => context.push('/reports/suppliers'),
                      ),
                      HubRow(
                        title: 'تقرير المخزون',
                        icon: Icons.inventory_2_outlined,
                        onTap: () => context.push('/reports/inventory'),
                      ),
                      HubRow(
                        title: 'الميزانية العمومية',
                        icon: Icons.pie_chart_outline,
                        onTap: () => context.push('/balance-sheet'),
                      ),
                      HubRow(
                        title: 'تقرير الشركاء',
                        icon: Icons.handshake_outlined,
                        onTap: () => context.push('/reports/partners'),
                      ),
                      HubRow(
                        title: 'تقرير الأقساط',
                        icon: Icons.receipt_long_outlined,
                        onTap: () => context.push('/reports/installments'),
                      ),
                    ],
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

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pending = context.watch<SyncCubit>().state.pending;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('المزيد'),
        toolbarHeight: 76,
        automaticallyImplyLeading: false,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SectionLabel('التشغيل'),
            IvoryMenuCard(
              children: [
                HubRow(
                  title: 'بحث',
                  subtitle: 'البحث في القيود',
                  icon: Icons.search,
                  onTap: () => context.push('/search'),
                ),
                HubRow(
                  title: 'يومية مجمعة',
                  subtitle: 'عرض وطباعة اليومية المجمعة',
                  icon: Icons.layers_outlined,
                  onTap: () => context.push('/general-journal'),
                ),
                HubRow(
                  title: 'طباعة',
                  subtitle: 'طباعة المستندات والتقارير',
                  icon: Icons.print_outlined,
                  onTap: () => context.push('/print'),
                ),
                HubRow(
                  title: 'مزامنة الصندوق الصادر',
                  subtitle: pending == 0
                      ? 'لا توجد قيود معلّقة'
                      : '$pending قيد بانتظار الرفع',
                  icon: Icons.sync,
                  onTap: () async {
                    final n = await context.read<SyncCubit>().flush();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            n == 0 ? 'لا شيء للمزامنة' : 'تم رفع $n قيد',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SectionLabel('التعريفات'),
            IvoryMenuCard(
              children: [
                HubRow(
                  title: 'التعريفات',
                  subtitle: 'إدارة الأطراف وأنواع الأعمال والأصناف',
                  icon: Icons.menu_book_outlined,
                  onTap: () => context.push('/definitions'),
                ),
                HubRow(
                  title: 'الأصناف',
                  subtitle: 'قائمة الأصناف والمخزون',
                  icon: Icons.category_outlined,
                  onTap: () => context.push('/items'),
                ),
                HubRow(
                  title: 'أنواع الأعمال',
                  icon: Icons.handyman_outlined,
                  onTap: () => context.push('/work-types'),
                ),
                HubRow(
                  title: 'إضافة مورد',
                  icon: Icons.person_add_alt_1_outlined,
                  onTap: () => context.push('/definitions/add-supplier'),
                ),
              ],
            ),
            const SectionLabel('النظام'),
            IvoryMenuCard(
              children: [
                HubRow(
                  title: 'بيانات الشركة',
                  subtitle: 'إدارة بيانات الشركة وعناوينها',
                  icon: Icons.apartment_outlined,
                  onTap: () => context.push('/company'),
                ),
                HubRow(
                  title: 'نوع النشاط',
                  subtitle: 'إدارة أنواع الأنشطة التجارية',
                  icon: Icons.work_outline,
                  onTap: () => context.push('/packs'),
                ),
                HubRow(
                  title: 'نسخ احتياطي',
                  subtitle: 'عمل نسخة احتياطية واستعادة البيانات',
                  icon: Icons.cloud_upload_outlined,
                  onTap: () => context.push('/backup'),
                ),
                HubRow(
                  title: 'شيكات',
                  icon: Icons.credit_card,
                  onTap: () => context.push('/checks'),
                ),
                HubRow(
                  title: 'الأصول الثابتة',
                  icon: Icons.precision_manufacturing_outlined,
                  onTap: () => context.push('/fixed-assets'),
                ),
                HubRow(
                  title: 'اتفاق شركاء',
                  icon: Icons.balance,
                  onTap: () => context.push('/partners/agreement'),
                ),
                HubRow(
                  title: 'قائمة الدخل — غذائي',
                  icon: Icons.grass_outlined,
                  onTap: () => context.push('/pnl/food'),
                ),
                HubRow(
                  title: 'قائمة الدخل — ألوميتال',
                  icon: Icons.window_outlined,
                  onTap: () => context.push('/pnl/aluminum'),
                ),
                HubRow(
                  title: 'مبيعات وحدات',
                  icon: Icons.apartment_outlined,
                  onTap: () => context.push('/units'),
                ),
                HubRow(
                  title: 'عملاء التصنيع',
                  icon: Icons.precision_manufacturing_outlined,
                  onTap: () => context.push('/manufacturing/customers'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AtelierButton(
              label: 'تسجيل الخروج',
              kind: AtelierButtonKind.danger,
              icon: Icons.logout,
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthLogoutRequested()),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> pickReportDates(BuildContext context) async {
  final cubit = context.read<DateRangeCubit>();
  final from = await showDatePicker(
    context: context,
    initialDate: cubit.state.from ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    helpText: 'من تاريخ',
  );
  if (!context.mounted) return;
  final to = await showDatePicker(
    context: context,
    initialDate: cubit.state.to ?? from ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    helpText: 'إلى تاريخ',
  );
  cubit.setRange(from, to);
}
