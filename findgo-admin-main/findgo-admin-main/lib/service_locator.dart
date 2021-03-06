// import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:findgo_admin/external_services/local_data_src.dart';
import 'package:findgo_admin/external_services/network_info.dart';
import 'package:findgo_admin/external_services/remote_auth_src.dart';
import 'package:findgo_admin/external_services/remote_specials_data_src.dart';
import 'package:findgo_admin/repositories/auth_repo.dart';
import 'package:findgo_admin/repositories/specials_repo.dart';
import 'package:findgo_admin/view_models/auth_vm.dart';
import 'package:findgo_admin/view_models/locations_vm.dart';
import 'package:findgo_admin/view_models/specials_vm.dart';
import 'package:findgo_admin/view_models/stores_vm.dart';
import 'package:findgo_admin/view_models/users_vm.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  // await dotenv.load();

  // View Models
  sl.registerLazySingleton(
    () => AuthViewModel(
      authRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => SpecialsViewModel(
      specialsRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => StoresViewModel(
      specialsRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => LocationsViewModel(
      specialsRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => UsersViewModel(
      authRepo: sl(),
    ),
  );
  // sl.registerLazySingleton(() => HomeViewModel(authRepository: sl(),));

  // Repositories
  sl.registerLazySingleton<SpecialsRepository>(
    () => SpecialsRepository(
      localDataSource: sl(),
      networkInfo: sl(),
      remoteSpecialsDataSource: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      localDataSource: sl(),
      networkInfo: sl(),
      remoteAuthSource: sl(),
    ),
  );

  // Services mobile
  // sl.registerLazySingleton<NavigationServiceContract>(() => NavigationService());

  // Services web
  // final apiUrl = dotenv.env["SERVER_API_URL"];
  //const apiUrl = "https://skylarktraining.co.za/findgo/php";

  const apiUrl = "https://findgo.co.za/php";
  // const apiUrl = "http://findgo.local.com/";

  // if (apiUrl == null) throw Exception("Could not find SERVER_API_URL in .env");
  sl.registerSingleton<LocalDataSource>(LocalDataSource());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo());
  sl.registerLazySingleton<RemoteAuthSource>(
    () => RemoteAuthSource(sl(), apiUrl),
  );
  sl.registerLazySingleton<RemoteSpecialsDataSource>(
    () => RemoteSpecialsDataSource(sl(), apiUrl),
  );

  // External
  sl.registerLazySingleton<Client>(() => Client());
  // sl.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker());
}
