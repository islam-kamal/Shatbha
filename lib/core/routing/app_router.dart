import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_bloc.dart';
import '../../features/auth/presentation/screens/auth_screens.dart';
import '../../features/catalog/presentation/screens/catalog_screens.dart';
import '../../features/company/presentation/screens/company_screens.dart';
import '../../features/expenses/presentation/screens/expense_screens.dart';
import '../../features/extra/presentation/screens/estate_screens.dart';
import '../../features/extra/presentation/screens/extra_screens.dart';
import '../../features/jobs/presentation/screens/job_screens.dart';
import '../../features/journal/presentation/screens/journal_screens.dart';
import '../../features/reports/presentation/screens/pnl_screen.dart';
import '../../features/shell/presentation/screens/shell_screens.dart';
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
      GoRoute(parentNavigatorKey: _rootKey, path: '/cubing', builder: (_, __) => const CubingScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/cubing/add', builder: (_, __) => const AddCubingLineScreen()),
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
    ],
  );
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
