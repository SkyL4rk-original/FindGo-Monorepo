import 'package:findgo/external_services/local_data_src.dart';
import 'package:findgo/external_services/location_svs.dart';
import 'package:findgo/external_services/network_info.dart';
import 'package:findgo/external_services/remote_auth_src.dart';
import 'package:findgo/external_services/remote_specials_data_src.dart';
import 'package:findgo/repositories/auth_repo.dart';
import 'package:findgo/repositories/specials_repo.dart';
import 'package:findgo/view_models/auth_vm.dart';
import 'package:findgo/view_models/filter_vm.dart';
import 'package:findgo/view_models/location_vm.dart';
import 'package:findgo/view_models/network_vm.dart';
import 'package:findgo/view_models/specials_vm.dart';
import 'package:findgo/view_models/stores_vm.dart';
import 'package:findgo/view_models/theme_vm.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  await dotenv.load();
  await Hive.initFlutter();
  final _hiveBox = await Hive.openBox("hive");

  final findgoUuid = dotenv.env["FINDGO_STORE_ID"];
  if (findgoUuid == null) throw Exception("FindGo Uuid not set in .envs");

  // View Models
  sl.registerLazySingleton(() => AuthViewModel(authRepository: sl()));
  sl.registerLazySingleton(
    () => FilterViewModel(
      specialsViewModel: sl(),
      storesViewModel: sl(),
      locationViewModel: sl(),
    ),
  );
  sl.registerLazySingleton(() => NetworkViewModel(networkInfo: sl()));
  sl.registerLazySingleton(
    () => LocationViewModel(locationService: sl(), specialsRepository: sl()),
  );
  sl.registerLazySingleton(
    () => SpecialsViewModel(networkViewModel: sl(), specialsRepository: sl()),
  );
  sl.registerLazySingleton(
    () => StoresViewModel(
      networkViewModel: sl(),
      specialsRepository: sl(),
      findgoUuid: findgoUuid,
    ),
  );
  sl.registerLazySingleton(() => ThemeViewModel(localDataSource: sl()));

  // sl.registerLazySingleton(() => HomeViewModel(authRepository: sl(),));

  // Repositories
  sl.registerLazySingleton(
    () => SpecialsRepository(
      localDataSource: sl(),
      networkInfo: sl(),
      remoteSpecialsDataSource: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => AuthRepository(
      localDataSource: sl(),
      networkInfo: sl(),
      remoteAuthSource: sl(),
    ),
  );

  // Services mobile
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSource(_hiveBox));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo(sl()));
  final apiUrl = dotenv.env["SERVER_API_URL"];
  if (apiUrl == null) throw Exception("Could not find SERVER_API_URL in .env");
  sl.registerLazySingleton<RemoteAuthSource>(
    () => RemoteAuthSource(sl(), apiUrl),
  );
  sl.registerLazySingleton<RemoteSpecialsDataSource>(
    () => RemoteSpecialsDataSource(sl(), apiUrl),
  );
  sl.registerLazySingleton<LocationService>(
    () => LocationService(),
  );

  // External
  sl.registerLazySingleton<Client>(() => Client());
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker(),
  );
}
