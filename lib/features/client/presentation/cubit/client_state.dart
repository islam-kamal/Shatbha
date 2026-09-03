import 'package:equatable/equatable.dart';

import '../../data/models/client_models.dart';

class ClientState extends Equatable {
  const ClientState({
    this.loading = false,
    this.error,
    this.projects = const [],
    this.selected,
    this.designPackage,
    this.approving = false,
  });

  final bool loading;
  final String? error;
  final List<ClientProject> projects;
  final ClientProject? selected;
  final ClientDesignPackage? designPackage;
  final bool approving;

  ClientState copyWith({
    bool? loading,
    String? error,
    List<ClientProject>? projects,
    ClientProject? selected,
    ClientDesignPackage? designPackage,
    bool? approving,
  }) =>
      ClientState(
        loading: loading ?? this.loading,
        error: error,
        projects: projects ?? this.projects,
        selected: selected ?? this.selected,
        designPackage: designPackage ?? this.designPackage,
        approving: approving ?? this.approving,
      );

  @override
  List<Object?> get props =>
      [loading, error, projects, selected, designPackage, approving];
}
