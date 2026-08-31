import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/injection.dart';
import '../../features/catalog/injection.dart';
import '../../features/company/injection.dart';
import '../../features/contractors_marketplace/injection.dart';
import '../../features/design/injection.dart';
import '../../features/expenses/injection.dart';
import '../../features/handover/injection.dart';
import '../../features/jobs/injection.dart';
import '../../features/journal/injection.dart';
import '../../features/materials/injection.dart';
import '../../features/media/injection.dart';
import '../../features/procurement/injection.dart';
import '../../features/project_manager/injection.dart';
import '../../features/projects/injection.dart';
import '../../features/reports/injection.dart';
import '../../features/sync/injection.dart';
import '../../features/vendors/injection.dart';
import '../../features/warehouse/injection.dart';
import '../database/app_database.dart';
import '../logging/app_log.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  if (sl.isRegistered<AppDatabase>()) return;

  sl.registerSingleton(const FlutterSecureStorage());
  sl.registerSingleton(AppDatabase());
  sl.registerSingleton(createDio(sl<FlutterSecureStorage>()));

  registerAuth(sl);
  registerCompany(sl);
  registerCatalog(sl);
  registerJournal(sl);
  registerExpenses(sl);
  registerJobs(sl);
  registerReports(sl);
  registerSync(sl);
  registerProjects(sl);
  registerVendors(sl);
  registerMaterials(sl);
  registerContractorsMarketplace(sl);
  registerDesign(sl);
  registerMedia(sl);
  registerProjectManager(sl);
  registerProcurement(sl);
  registerWarehouse(sl);
  registerHandover(sl);
  AppLog.i('DI registered core + features');
}
