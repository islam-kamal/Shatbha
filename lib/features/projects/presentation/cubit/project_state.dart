import 'package:equatable/equatable.dart';

import '../../data/models/project_models.dart';

class ProjectState extends Equatable {
  const ProjectState({
    this.loading = false,
    this.projects = const [],
    this.selected,
    this.error,
  });

  final bool loading;
  final List<Project> projects;
  final Project? selected;
  final String? error;

  bool get isEmpty => !loading && error == null && projects.isEmpty;

  ProjectState copyWith({
    bool? loading,
    List<Project>? projects,
    Project? selected,
    String? error,
  }) {
    return ProjectState(
      loading: loading ?? this.loading,
      projects: projects ?? this.projects,
      selected: selected ?? this.selected,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, projects, selected, error];
}
