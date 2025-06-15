// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ProjectEditorScreen]
class ProjectEditorRoute extends PageRouteInfo<ProjectEditorRouteArgs> {
  ProjectEditorRoute({
    Key? key,
    required Project project,
    List<PageRouteInfo>? children,
  }) : super(
          ProjectEditorRoute.name,
          args: ProjectEditorRouteArgs(key: key, project: project),
          initialChildren: children,
        );

  static const String name = 'ProjectEditorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProjectEditorRouteArgs>();
      return ProjectEditorScreen(key: args.key, project: args.project);
    },
  );
}

class ProjectEditorRouteArgs {
  const ProjectEditorRouteArgs({this.key, required this.project});

  final Key? key;

  final Project project;

  @override
  String toString() {
    return 'ProjectEditorRouteArgs{key: $key, project: $project}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProjectEditorRouteArgs) return false;
    return key == other.key && project == other.project;
  }

  @override
  int get hashCode => key.hashCode ^ project.hashCode;
}

/// generated route for
/// [ProjectsScreen]
class ProjectsRoute extends PageRouteInfo<void> {
  const ProjectsRoute({List<PageRouteInfo>? children})
      : super(ProjectsRoute.name, initialChildren: children);

  static const String name = 'ProjectsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const ProjectsScreen());
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [ShortcutsScreen]
class ShortcutsRoute extends PageRouteInfo<void> {
  const ShortcutsRoute({List<PageRouteInfo>? children})
      : super(ShortcutsRoute.name, initialChildren: children);

  static const String name = 'ShortcutsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ShortcutsScreen();
    },
  );
}
