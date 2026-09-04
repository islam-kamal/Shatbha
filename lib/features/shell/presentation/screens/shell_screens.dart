import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/auth/data/repositories/auth_repository.dart';
import 'package:shatbha/features/auth/presentation/cubit/auth_bloc.dart';
import 'package:shatbha/features/auth/data/models/auth_models.dart';
import 'package:shatbha/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:shatbha/features/project_os/data/project_os_api.dart';
import 'package:shatbha/features/project_os/data/project_os_models.dart';
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
    final clientMode =
        auth is AuthAuthenticated && auth.user.isClient;
    final limitedNav = vendorMode || clientMode;
    final shellIndex = navigationShell.currentIndex;
    final navIndex = limitedNav ? (shellIndex >= 3 ? 1 : 0) : shellIndex;
    final unread = context.watch<NotificationCubit>().state.unread;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        vendorMode: vendorMode,
        clientMode: clientMode,
        index: navIndex,
        moreBadge: unread > 0 ? unread : null,
        onTap: (i) {
          if (limitedNav) {
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
    if (auth is AuthAuthenticated && auth.user.isClient) {
      return const ClientHomeScreen();
    }
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
            child: isVendor
                ? IvorySheet(
                    child: GridView.count(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.22,
                      children: _vendorTiles(context, user!),
                    ),
                  )
                : const _CompanyHomeBody(),
          ),
        ],
      ),
    );
  }

  List<Widget> _vendorTiles(BuildContext context, AuthUser user) {
    if (user.role == 'supplier') {
      return [
        HomeNavTile(
          title: 'منتجاتي',
          icon: Icons.inventory_2_outlined,
          onTap: () => context.push('/vendor/products'),
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
        title: 'مشاريعي',
        icon: Icons.apartment_outlined,
        onTap: () => context.push('/vendor/projects'),
      ),
      HomeNavTile(
        title: 'معرض الأعمال',
        icon: Icons.photo_library_outlined,
        onTap: () => context.push('/vendor/portfolio'),
      ),
      HomeNavTile(
        title: 'التنبيهات',
        icon: Icons.notifications_outlined,
        onTap: () => context.push('/notifications'),
      ),
      HomeNavTile(
        title: 'ملفي',
        icon: Icons.engineering_outlined,
        onTap: () => context.push('/vendors/${user.id}'),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Company home body — "المطلوب الآن" + expandable "كل الوحدات"
// ─────────────────────────────────────────────────────────────────────────────

class _CompanyHomeBody extends StatefulWidget {
  const _CompanyHomeBody();

  @override
  State<_CompanyHomeBody> createState() => _CompanyHomeBodyState();
}

class _CompanyHomeBodyState extends State<_CompanyHomeBody> {
  List<ActionRequiredItem> _actionItems = [];
  bool _loadingActions = true;
  bool _modulesExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    try {
      final items = await sl<ProjectOsApi>().commandCenter();
      if (!mounted) return;
      setState(() {
        _actionItems = items;
        _loadingActions = false;
      });
    } on Failure {
      if (!mounted) return;
      setState(() => _loadingActions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return IvorySheet(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // ── المطلوب الآن ──────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.bolt, color: c.brass, size: 18),
              const SizedBox(width: 6),
              Text(
                'المطلوب الآن',
                style: TextStyle(
                  color: c.stone,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loadingActions)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_actionItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SheetCard(
                child: ListTile(
                  leading: Icon(Icons.check_circle_outline, color: c.teal),
                  title: Text(
                    'لا توجد إجراءات معلّقة',
                    style: TextStyle(color: c.stone.withValues(alpha: 0.7)),
                  ),
                ),
              ),
            )
          else
            IvoryMenuCard(
              children: [
                for (final item in _actionItems)
                  HubRow(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: _actionIcon(item.type),
                    onTap: () {
                      if (item.route != null) context.push(item.route!);
                    },
                  ),
              ],
            ),
          const SizedBox(height: 20),

          // ── كل الوحدات (expandable) ───────────────────────────────────────
          GestureDetector(
            onTap: () =>
                setState(() => _modulesExpanded = !_modulesExpanded),
            child: Row(
              children: [
                Icon(Icons.grid_view_outlined, color: c.brass, size: 18),
                const SizedBox(width: 6),
                Text(
                  'كل الوحدات',
                  style: TextStyle(
                    color: c.stone,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Icon(
                  _modulesExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: c.stone.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          if (_modulesExpanded) ...[
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.22,
              children: _companyModuleTiles(context),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _companyModuleTiles(BuildContext context) => [
        HomeNavTile(
          title: 'العملاء المحتملون',
          icon: Icons.person_search_outlined,
          onTap: () => context.push('/leads'),
        ),
        HomeNavTile(
          title: 'المشاريع',
          icon: Icons.apartment_outlined,
          onTap: () => context.push('/projects'),
        ),
        HomeNavTile(
          title: 'العملاء',
          icon: Icons.people_outline,
          onTap: () => context.push('/clients'),
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
        HomeNavTile(
          title: 'التنبيهات',
          icon: Icons.notifications_outlined,
          onTap: () => context.push('/notifications'),
        ),
      ];

  IconData _actionIcon(String type) => switch (type) {
        'lead' => Icons.person_search_outlined,
        'design_approval' => Icons.palette_outlined,
        'payment' => Icons.payments_outlined,
        'change_order' => Icons.edit_note_outlined,
        'warranty' => Icons.verified_outlined,
        'selection' => Icons.checklist_outlined,
        _ => Icons.notification_important_outlined,
      };
}

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  List<Map<String, dynamic>> _projects = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await sl<AuthRepository>().clientProjects();
      if (!mounted) return;
      setState(() {
        _projects = rows;
        _loading = false;
        _error = null;
      });
      context.read<NotificationCubit>().refreshUnread();
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
    final unread = context.watch<NotificationCubit>().state.unread;
    final pendingDesign = _projects
        .where((p) => (p['design_status'] as String?) == 'pending')
        .toList();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: BrandLockup(slogan: 'حساب عميل — متابعة مشاريعك'),
                    ),
                    IconButton(
                      tooltip: 'التنبيهات',
                      onPressed: () => context.push('/notifications'),
                      icon: Badge(
                        isLabelVisible: unread > 0,
                        label: Text('$unread'),
                        child: const Icon(Icons.notifications_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (pendingDesign.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Material(
                  color: context.atelier.teal.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    leading: Icon(Icons.palette_outlined,
                        color: context.atelier.teal),
                    title: Text(
                      'تصميم بانتظار اعتمادك',
                      style: TextStyle(
                        color: context.atelier.stone,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      pendingDesign
                          .map((p) => (p['title'] ?? p['name']).toString())
                          .join(' · '),
                      style: TextStyle(
                        color: context.atelier.stone.withValues(alpha: 0.65),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_left,
                      color: context.atelier.stone,
                    ),
                    onTap: () {
                      final id = pendingDesign.first['id'] as int;
                      context.push('/client/projects/$id/design-approval');
                    },
                  ),
                ),
              ),
            const TabBar(
              tabs: [
                Tab(text: 'التقدم'),
                Tab(text: 'الموافقات'),
                Tab(text: 'المدفوعات'),
                Tab(text: 'المستندات'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ClientProjectsTab(
                    projects: _projects,
                    loading: _loading,
                    error: _error,
                    onReload: _load,
                  ),
                  _ClientApprovalsTab(
                    projects: _projects,
                    loading: _loading,
                    error: _error,
                    onReload: _load,
                  ),
                  _ClientPaymentsTab(
                    projects: _projects,
                    loading: _loading,
                    error: _error,
                    onReload: _load,
                  ),
                  _ClientDocumentsTab(
                    projects: _projects,
                    loading: _loading,
                    error: _error,
                    onReload: _load,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _clientProgressPercent(Map<String, dynamic> p, String status) {
  final explicit = p['progress_percent'];
  if (explicit is num) return explicit.round().clamp(0, 100);
  return switch (status) {
    'handed_over' || 'completed' => 100,
    'delivered' => 90,
    'in_progress' || 'active' => 50,
    'planning' => 20,
    _ => 10,
  };
}

String _clientStatusLabel(String status) {
  switch (status) {
    case 'in_progress':
    case 'active':
      return 'قيد التنفيذ';
    case 'planning':
      return 'تخطيط';
    case 'delivered':
      return 'تسليم';
    case 'handed_over':
    case 'completed':
      return 'مكتمل';
    default:
      return status;
  }
}

class _ClientProjectsTab extends StatelessWidget {
  const _ClientProjectsTab({
    required this.projects,
    required this.loading,
    required this.error,
    required this.onReload,
  });

  final List<Map<String, dynamic>> projects;
  final bool loading;
  final String? error;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return StatusView.error(body: error!, onAction: onReload);
    }
    if (projects.isEmpty) {
      return const StatusView.empty(
        title: 'لا مشاريع',
        body: 'ستظهر مشاريع التشطيب المرتبطة بحسابك هنا.',
      );
    }
    return IvorySheet(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        itemCount: projects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final p = projects[i];
          final name = (p['title'] ?? p['name']) as String? ?? 'مشروع';
          final status = p['status'] as String? ?? 'draft';
          final progress = _clientProgressPercent(p, status);
          final designStatus = p['design_status'] as String? ?? 'draft';
          return LedgerCard(
            row: LedgerRow(
              id: p['id'] as int,
              title: name,
              subtitle: '${_clientStatusLabel(status)} · ${p['address'] ?? ''}',
              amount: p['budget']?.toString() ?? '—',
              accent: c.teal,
              badge: designStatus == 'pending' ? 'تصميم' : '$progress%',
            ),
            onTap: () {
              final id = p['id'] as int;
              if (designStatus == 'pending') {
                context.push('/client/projects/$id/design-approval');
              } else {
                context.push('/client/projects/$id');
              }
            },
          );
        },
      ),
    );
  }
}

class _ClientApprovalsTab extends StatelessWidget {
  const _ClientApprovalsTab({
    required this.projects,
    required this.loading,
    required this.error,
    required this.onReload,
  });

  final List<Map<String, dynamic>> projects;
  final bool loading;
  final String? error;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return StatusView.error(body: error!, onAction: onReload);
    }
    if (projects.isEmpty) {
      return const StatusView.empty(
        title: 'لا موافقات',
        body: 'ستظهر طلبات الاعتماد هنا.',
      );
    }
    return IvorySheet(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          for (final p in projects) ...[
            SectionLabel((p['title'] ?? p['name'] ?? 'مشروع').toString()),
            IvoryMenuCard(
              children: [
                HubRow(
                  title: 'اعتماد التصميم',
                  subtitle: 'مراجعة ورفع أو رفض التصميم',
                  icon: Icons.palette_outlined,
                  onTap: () => context.push(
                    '/client/projects/${p['id']}/design-approval',
                  ),
                ),
                HubRow(
                  title: 'اختيارات المواد',
                  subtitle: 'اعتماد اختيارات التشطيبات',
                  icon: Icons.checklist_outlined,
                  onTap: () => context
                      .push('/client/projects/${p['id']}/selections'),
                ),
                HubRow(
                  title: 'أوامر التغيير',
                  subtitle: 'مراجعة التعديلات الإضافية',
                  icon: Icons.edit_note_outlined,
                  onTap: () => context
                      .push('/client/projects/${p['id']}/change-orders'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _ClientPaymentsTab extends StatelessWidget {
  const _ClientPaymentsTab({
    required this.projects,
    required this.loading,
    required this.error,
    required this.onReload,
  });

  final List<Map<String, dynamic>> projects;
  final bool loading;
  final String? error;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return StatusView.error(body: error!, onAction: onReload);
    }
    if (projects.isEmpty) {
      return const StatusView.empty(
        title: 'لا مدفوعات',
        body: 'ستظهر خطة الدفع والأقساط هنا.',
      );
    }
    return IvorySheet(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          for (final p in projects) ...[
            SectionLabel((p['title'] ?? p['name'] ?? 'مشروع').toString()),
            IvoryMenuCard(
              children: [
                HubRow(
                  title: 'خطة الدفع',
                  subtitle: 'الأقساط والمدفوعات',
                  icon: Icons.payments_outlined,
                  onTap: () => context
                      .push('/client/projects/${p['id']}/payments'),
                ),
                HubRow(
                  title: 'الضمان',
                  subtitle: 'بلاغات ما بعد التسليم',
                  icon: Icons.verified_outlined,
                  onTap: () => context
                      .push('/client/projects/${p['id']}/warranty'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _ClientDocumentsTab extends StatelessWidget {
  const _ClientDocumentsTab({
    required this.projects,
    required this.loading,
    required this.error,
    required this.onReload,
  });

  final List<Map<String, dynamic>> projects;
  final bool loading;
  final String? error;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return StatusView.error(body: error!, onAction: onReload);
    }
    if (projects.isEmpty) {
      return const StatusView.empty(
        title: 'لا مستندات',
        body: 'ستظهر مستندات التصميم والتسليم هنا.',
      );
    }
    return IvorySheet(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          for (final p in projects) ...[
            SectionLabel((p['title'] ?? p['name'] ?? 'مشروع').toString()),
            IvoryMenuCard(
              children: [
                HubRow(
                  title: 'اعتماد التصميم',
                  subtitle: 'مراجعة واعتماد التصميم',
                  icon: Icons.palette_outlined,
                  onTap: () => context.push(
                    '/client/projects/${p['id']}/design-approval',
                  ),
                ),
                HubRow(
                  title: 'مستندات التسليم',
                  subtitle: 'قائمة فحص · عيوب · توقيع',
                  icon: Icons.description_outlined,
                  onTap: () => context.push('/projects/${p['id']}/handover'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
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
                  title: 'التنبيهات',
                  subtitle: context.watch<NotificationCubit>().state.unread > 0
                      ? '${context.watch<NotificationCubit>().state.unread} غير مقروء'
                      : 'صندوق الوارد',
                  icon: Icons.notifications_outlined,
                  onTap: () => context.push('/notifications'),
                ),
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
