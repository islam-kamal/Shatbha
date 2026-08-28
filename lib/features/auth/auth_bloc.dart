import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_log.dart';
import '../../core/failures.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested(this.email, this.password);
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];

  @override
  String toString() => 'AuthLoginRequested($email)';
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCompanyUpdated extends AuthEvent {
  const AuthCompanyUpdated(this.company);
  final CompanyInfo company;
  @override
  List<Object?> get props => [company.id, company.name, company.pack];
}

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUser user;
  @override
  List<Object?> get props => [user.id, user.role, user.email, user.company?.pack, user.company?.name];

  @override
  String toString() => 'AuthAuthenticated(${user.email}, ${user.role})';
}

class AuthGuest extends AuthState {
  const AuthGuest({this.message});
  final String? message;
  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthGuest($message)';
}

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
