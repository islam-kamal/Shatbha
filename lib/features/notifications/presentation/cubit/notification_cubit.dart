import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/models/notification_models.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationState extends Equatable {
  const NotificationState({
    this.loading = false,
    this.items = const [],
    this.unread = 0,
    this.error,
  });

  final bool loading;
  final List<AppNotificationItem> items;
  final int unread;
  final String? error;

  NotificationState copyWith({
    bool? loading,
    List<AppNotificationItem>? items,
    int? unread,
    String? error,
  }) {
    return NotificationState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      unread: unread ?? this.unread,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, items, unread, error];
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repo) : super(const NotificationState());

  final NotificationRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final items = await _repo.list();
      final unread = await _repo.unreadCount();
      emit(state.copyWith(loading: false, items: items, unread: unread));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> refreshUnread() async {
    try {
      final unread = await _repo.unreadCount();
      emit(state.copyWith(unread: unread));
    } catch (_) {}
  }

  Future<void> markRead(int id) async {
    try {
      await _repo.markRead(id);
      await load();
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
    }
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllRead();
      await load();
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
    }
  }
}
