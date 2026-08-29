import 'package:equatable/equatable.dart';

import '../../data/models/auth_models.dart';

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
