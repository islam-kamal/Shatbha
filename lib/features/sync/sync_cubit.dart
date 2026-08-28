import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/sync_repository.dart';

class SyncCubit extends Cubit<int> {
  SyncCubit(this._repo) : super(0);

  final SyncRepository _repo;

  Future<void> refresh() async {
    emit(await _repo.pendingCount());
  }

  Future<int> flush() async {
    final synced = await _repo.flush();
    await refresh();
    return synced;
  }
}
