import 'package:equatable/equatable.dart';

import '../../data/models/auth_models.dart';

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
  List<Object?> get props =>
      [user.id, user.role, user.email, user.company?.pack, user.company?.name];

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
