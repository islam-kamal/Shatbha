import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_bloc.dart';
import '../../features/auth/presentation/screens/auth_screens.dart';
import '../../features/catalog/presentation/screens/catalog_screens.dart';
import '../../features/company/presentation/screens/company_screens.dart';
import '../../features/contractors_marketplace/presentation/screens/contractor_marketplace_screens.dart';
import '../../features/design/presentation/screens/design_screens.dart';
import '../../features/expenses/presentation/screens/expense_screens.dart';
import '../../features/extra/presentation/screens/estate_screens.dart';
import '../../features/extra/presentation/screens/extra_screens.dart';
import '../../features/handover/presentation/screens/handover_screens.dart';
import '../../features/jobs/presentation/screens/job_screens.dart';
import '../../features/journal/presentation/screens/journal_screens.dart';
import '../../features/materials/presentation/screens/material_screens.dart';
import '../../features/projects/presentation/screens/project_screens.dart';
import '../../features/procurement/presentation/screens/procurement_screens.dart';
import '../../features/project_manager/presentation/screens/pm_screens.dart';
import '../../features/reports/presentation/screens/pnl_screen.dart';
import '../../features/shell/presentation/screens/shell_screens.dart';
import '../../features/vendors/presentation/screens/vendor_screens.dart';
import '../../features/warehouse/presentation/screens/warehouse_screens.dart';
import '../logging/app_log.dart';
import '../observers/nav_observer.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    observers: [AppNavObserver()],
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final auth = authBloc.state;
      final loggedIn = auth is AuthAuthenticated;
      final onSplash = loc == '/splash';
      final onLogin = loc == '/login';
      String? target;
      if (auth is AuthInitial && !onSplash) target = '/splash';
      if (auth is AuthGuest && !onLogin) target = '/login';
      if (loggedIn && (onLogin || onSplash)) target = '/home';
      if (loggedIn && auth.user.isVendor) {
        if (loc == '/ledger' || loc == '/reports') {
          target = '/home';
        } else if (_isCompanyOnlyPath(loc)) {
          target = '/home';
        }
      }
      if (target != null) {
        AppLog.i('redirect $loc → $target (${auth.runtimeType})', tag: 'nav');
      }
      return target;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/ledger', builder: (_, __) => const LedgerHubScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/reports', builder: (_, __) => const ReportsHubScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/more', builder: (_, __) => const MoreScreen())],
          ),
        ],
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/definitions', builder: (_, __) => const DefinitionsScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/definitions/add-customer', builder: (_, __) => const AddPartyScreen(type: 'customer')),
      GoRoute(parentNavigatorKey: _rootKey, path: '/definitions/add-contractor', builder: (_, __) => const AddPartyScreen(type: 'contractor')),
      GoRoute(parentNavigatorKey: _rootKey, path: '/definitions/add-supplier', builder: (_, __) => const AddSupplierScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/work-types', builder: (_, __) => const WorkTypesScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/items', builder: (_, __) => const ItemsScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/items/add', builder: (_, __) => const AddItemScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/journal', builder: (_, __) => const JournalScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/journal/add', builder: (_, __) => const AddEntryScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/customers/picker', builder: (_, __) => const CustomerPickerScreen()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/customers/:id/statement',
        builder: (_, state) => StatementScreen(customerId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/customers/:id/supervision',
        builder: (_, state) => SupervisionScreen(customerId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/reports/customers', builder: (_, __) => const CustomerReportScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/reports/contractors', builder: (_, __) => const ContractorReportScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/reports/expenses', builder: (_, __) => const ExpenseReportScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/reports/sales', builder: (_, __) => const SalesReportScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/reports/suppliers', builder: (_, __) => const SupplierReportScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/reports/inventory', builder: (_, __) => const InventoryReportScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/reports/partners', builder: (_, __) => const PartnersScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/reports/installments', builder: (_, __) => const InstallmentsScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/expenses', builder: (_, __) => const ExpensesScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/expenses/add', builder: (_, __) => const AddExpenseScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/revenues', builder: (_, __) => const OtherRevenuesScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/revenues/add', builder: (_, __) => const AddRevenueScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/jobs', builder: (_, __) => const JobsScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/jobs/add', builder: (_, __) => const AddJobScreen()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/jobs/:id/pay',
        builder: (_, state) => PayJobScreen(jobId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/petty-cash', builder: (_, __) => const PettyCashScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/cubing', redirect: (_, __) => '/design'),
      GoRoute(parentNavigatorKey: _rootKey, path: '/cubing/add', redirect: (_, __) => '/design'),
      GoRoute(parentNavigatorKey: _rootKey, path: '/pnl', builder: (_, __) => const PnLScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/pnl/food', builder: (_, __) => const FoodIncomeScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/pnl/aluminum', builder: (_, __) => const AluminumIncomeScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/print', builder: (_, __) => const PrintPreviewScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/general-journal', builder: (_, __) => const GeneralJournalScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/suppliers/journal', builder: (_, __) => const SupplierJournalScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/suppliers/journal/add', builder: (_, __) => const AddSupplierEntryScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/inventory', builder: (_, __) => const InventoryReportScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/inventory/out', builder: (_, __) => const MaterialOutScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/inventory/out/add', builder: (_, __) => const AddMaterialOutScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/production', builder: (_, __) => const ProductionScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/production/add', builder: (_, __) => const AddProductionScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/manufacturing/customers', builder: (_, __) => const MfgCustomersScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/checks', builder: (_, __) => const ChecksScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/units', builder: (_, __) => const UnitSalesScreen()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/units/:code',
        builder: (_, state) => UnitDetailScreen(code: state.pathParameters['code']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/units/:code/collect',
        builder: (_, state) => CollectInstallmentScreen(code: state.pathParameters['code']!),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/installments', builder: (_, __) => const InstallmentsScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/contracting', builder: (_, __) => const ContractingScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/partners', builder: (_, __) => const PartnersScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/partners/journal', builder: (_, __) => const PartnersJournalScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/partners/journal/add', builder: (_, __) => const AddPartnerEntryScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/partners/agreement', builder: (_, __) => const PartnerAgreeScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/balance-sheet', builder: (_, __) => const BalanceSheetScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/fixed-assets', builder: (_, __) => const FixedAssetsScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/company', builder: (_, __) => const CompanyScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/packs', builder: (_, __) => const PacksScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/backup', builder: (_, __) => const BackupScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/projects', builder: (_, __) => const ProjectsScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/projects/add', builder: (_, __) => const AddProjectScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/design', builder: (_, __) => const DesignHubScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/vendors', builder: (_, __) => const VendorsScreen()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/vendors/:id',
        builder: (_, state) => VendorProfileScreen(
          vendorId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/materials', builder: (_, __) => const MaterialsCatalogScreen()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/materials/supplier/:id',
        builder: (_, state) => SupplierProductsScreen(
          supplierId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/contractors', builder: (_, __) => const ContractorsMarketplaceScreen()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/contractors/:id/request-quote',
        builder: (_, state) => RequestQuoteScreen(
          contractorId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/quotes',
        builder: (_, state) => QuotesListScreen(
          projectId: _queryInt(state.uri.queryParameters['project_id']),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id',
        builder: (_, state) => ProjectDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id/design',
        builder: (_, state) => ProjectDesignScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id/design/mood-board/add',
        builder: (_, state) => AddMoodBoardItemScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id/design/floor-plans/add',
        builder: (_, state) => AddFloorPlanScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id/design/boq/add',
        builder: (_, state) => AddBoqLineScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id/materials',
        builder: (_, state) => ProjectMaterialsScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id/materials/add',
        builder: (_, state) => AddProjectMaterialScreen(
          projectId: int.parse(state.pathParameters['id']!),
          productId: int.parse(state.uri.queryParameters['product_id'] ?? '0'),
          productName: state.uri.queryParameters['name'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id/pm',
        builder: (_, state) => ProjectManagerScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id/procurement',
        builder: (_, state) => ProcurementListScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id/warehouse',
        builder: (_, state) => WarehouseHubScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/projects/:id/handover',
        builder: (_, state) => HandoverScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/procurement',
        builder: (_, __) => const ProcurementListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/procurement/add',
        builder: (_, state) => CreatePurchaseOrderScreen(
          projectId: _queryInt(state.uri.queryParameters['projectId']),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/procurement/:id/receive',
        builder: (_, state) => ReceiveGoodsScreen(
          poId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/warehouse',
        builder: (_, __) => const WarehouseHubScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/warehouse/list',
        builder: (_, __) => const WarehouseListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/warehouse/stock',
        builder: (_, state) => StockLevelsScreen(
          warehouseId: _queryInt(state.uri.queryParameters['warehouseId']),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/warehouse/issue',
        builder: (_, state) => IssueToProjectScreen(
          projectId: _queryInt(state.uri.queryParameters['projectId']),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/warehouse/transfer',
        builder: (_, __) => const TransferStockScreen(),
      ),
    ],
  );
}

int? _queryInt(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return int.tryParse(raw);
}

const _companyOnlyPrefixes = [
  '/projects',
  '/journal',
  '/expenses',
  '/revenues',
  '/jobs',
  '/pnl',
  '/reports',
  '/definitions',
  '/work-types',
  '/items',
  '/customers',
  '/suppliers',
  '/inventory',
  '/production',
  '/manufacturing',
  '/petty-cash',
  '/general-journal',
  '/contracting',
  '/partners',
  '/balance-sheet',
  '/fixed-assets',
  '/company',
  '/packs',
  '/backup',
  '/checks',
  '/units',
  '/installments',
  '/design',
  '/procurement',
  '/warehouse',
  '/print',
  '/search',
  '/cubing',
];

bool _isCompanyOnlyPath(String loc) {
  if (loc.startsWith('/contractors/')) return true;
  for (final prefix in _companyOnlyPrefixes) {
    if (loc == prefix || loc.startsWith('$prefix/')) return true;
  }
  return false;
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
