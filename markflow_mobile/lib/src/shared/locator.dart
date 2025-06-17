import 'package:get_it/get_it.dart';
import 'package:markflow/src/core/services/file_service.dart';
import 'package:markflow/src/core/services/git_service.dart';
import 'package:markflow/src/core/services/path_config_service.dart';
import 'package:markflow/src/core/services/settings_service.dart';
import 'package:markflow/src/core/services/ssh_key_service.dart';
import 'package:markflow/src/core/routing/app_router.dart';
import 'package:markflow/src/datasource/http/dio_config.dart';
import 'package:markflow/src/datasource/http/example_api.dart';
import 'package:markflow/src/datasource/repositories/file_repository.dart';
import 'package:markflow/src/datasource/repositories/git_repository.dart';
import 'package:markflow/src/datasource/repositories/project_repository.dart';
import 'package:markflow/src/shared/services/app_logger.dart';
import 'package:markflow/src/shared/services/storage/local_storage.dart';
import 'package:markflow/src/shared/services/storage/storage.dart';

final GetIt locator = GetIt.instance
  ..registerLazySingleton(() => DioConfig())
  ..registerLazySingleton(() => AppRouter())
  ..registerLazySingleton<AppLogger>(() => AppLogger())
  ..registerLazySingleton<Storage>(() => LocalStorage())
  ..registerLazySingleton(() => ExampleApi(dio: locator<DioConfig>().dio))
  ..registerLazySingleton(() => PathConfigService())
  ..registerLazySingleton<ProjectRepository>(() => ProjectRepository())
  ..registerLazySingleton<FileRepository>(() => FileRepository())
  ..registerLazySingleton<GitRepository>(() => GitRepository())
  ..registerLazySingleton(() => FileService())
  ..registerLazySingleton(() => GitService())
  ..registerLazySingleton(() => SshKeyService())
  ..registerLazySingleton(() => SettingsService());
