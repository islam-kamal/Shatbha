import 'bootstrap.dart';
import 'core/config/app_flavor.dart';

/// Local dev entry — API at `http://127.0.0.1:8000`.
///
/// Android (USB): run `scripts/run_local_android.sh` or ensure
/// `adb reverse tcp:8000 tcp:8000` before launch.
void main() => bootstrap(AppFlavor.local);
