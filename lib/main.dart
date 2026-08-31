import 'bootstrap.dart';
import 'core/config/app_flavor.dart';

/// Default entry point (production). Prefer explicit targets:
/// - [main_local.dart] for local Laravel
/// - [main_production.dart] for Northflank
void main() => bootstrap(AppFlavor.production);
