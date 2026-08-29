import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/sync/data/repositories/sync_repository.dart';

import 'sync_state.dart';

export 'sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  SyncCubit(this._repo) : super(const SyncState());

  final SyncRepository _repo;

  Future<void> refresh() async {
    final n = await _repo.pendingCount();
    AppLog.d('pending outbox=$n', tag: 'sync');
    emit(SyncState(pending: n));
  }

  Future<int> flush() async {
    AppLog.i('user requested flush', tag: 'sync');
    final synced = await _repo.flush();
    await refresh();
    return synced;
  }
}
