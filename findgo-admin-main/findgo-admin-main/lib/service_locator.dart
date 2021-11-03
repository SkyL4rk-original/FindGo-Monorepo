import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

// import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'external_services/local_data_src.dart';
import 'external_services/network_info.dart';
import 'external_services/remote_auth_src.dart';
import 'external_services/remote_specials_data_src.dart';
import 'repositories/auth_repo.dart';
import 'repositories/specials_repo.dart';
import 'view_models/auth_vm.dart';
import 'view_models/specials_vm.dart';
import 'view_models/stores_vm.dart';
import 'view_models/users_vm.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  // await dotenv.load();

  // View Models
  sl.registerLazySingleton(() => AuthViewModel(
        authRepository: sl(),
      ));
  sl.registerLazySingleton(() => SpecialsViewModel(
        specialsRepository: sl(),
      ));
  sl.registerLazySingleton(() => StoresViewModel(
        specialsRepository: sl(),
      ));
  sl.registerLazySingleton(() => UsersViewModel(
        specialsRepository: sl(),
      ));
  // sl.registerLazySingleton(() => HomeViewModel(authRepository: sl(),));

  // Repositories
  sl.registerLazySingleton<SpecialsRepository>(() => SpecialsRepository(
        localDataSource: sl(),
        networkInfo: sl(),
        remoteSpecialsDataSource: sl(),
        authRepository: sl(),
      ));

  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(
        localDataSource: sl(),
        networkInfo: sl(),
        remoteAuthSource: sl(),
      ));

  // Services mobile
  // sl.registerLazySingleton<NavigationServiceContract>(() => NavigationService());

  // Services web
  // final apiUrl = dotenv.env["SERVER_API_URL"];
  //const apiUrl = "https://skylarktraining.co.za/findgo/php";
	const apiUrl = "https://findgo.co.za/php";
  // if (apiUrl == null) throw Exception("Could not find SERVER_API_URL in .env");
  sl.registerSingleton<LocalDataSource>(LocalDataSource());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo());
  sl.registerLazySingleton<RemoteAuthSource>(
      () => RemoteAuthSource(sl(), apiUrl));
  sl.registerLazySingleton<RemoteSpecialsDataSource>(
      () => RemoteSpecialsDataSource(sl(), apiUrl));

  // External
  sl.registerLazySingleton<Client>(() => Client());
  // sl.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker());
}
