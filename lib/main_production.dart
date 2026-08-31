import 'bootstrap.dart';
import 'core/config/app_flavor.dart';

/// Production entry — Northflank hosted API.
///
/// Run:
/// `fvm flutter run --flavor production -t lib/main_production.dart`
void main() => bootstrap(AppFlavor.production);
