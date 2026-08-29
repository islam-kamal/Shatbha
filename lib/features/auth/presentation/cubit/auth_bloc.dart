import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/auth/data/repositories/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthCompanyUpdated>(_onCompanyUpdated);
  }

  final AuthRepository _repo;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    AppLog.d('restore session', tag: 'auth');
    emit(const AuthLoading());
    final user = await _repo.restore();
    AppLog.d(
      user == null ? 'no session' : 'restored ${user.email} (${user.role})',
      tag: 'auth',
    );
    emit(user == null ? const AuthGuest() : AuthAuthenticated(user));
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    AppLog.d('login ${event.email}', tag: 'auth');
    emit(const AuthLoading());
    try {
      final user = await _repo.login(event.email, event.password);
      AppLog.d('logged in ${user.email} (${user.role})', tag: 'auth');
      emit(AuthAuthenticated(user));
    } on Failure catch (e) {
      AppLog.e('login failed', tag: 'auth', error: e);
      emit(AuthGuest(message: e.message));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    AppLog.d('logout', tag: 'auth');
    await _repo.logout();
    emit(const AuthGuest());
  }

  void _onCompanyUpdated(AuthCompanyUpdated event, Emitter<AuthState> emit) {
    final current = state;
    if (current is AuthAuthenticated) {
      emit(AuthAuthenticated(current.user.copyWith(company: event.company)));
    }
  }
}
