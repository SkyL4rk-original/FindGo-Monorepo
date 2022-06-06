import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import '../view_pages/download_pg.dart';
import '../view_pages/user_pg.dart';
import 'core/constants.dart';
import 'service_locator.dart';
import 'view_models/auth_vm.dart';
import 'view_models/specials_vm.dart';
import 'view_models/stores_vm.dart';
import 'view_models/locations_vm.dart';
import 'view_models/users_vm.dart';
import 'view_pages/error_pg.dart';
import 'view_pages/home_pg.dart';
import 'view_pages/login_pg.dart';
import 'view_pages/password_reset_pg.dart';

final authVMProvider =
    ChangeNotifierProvider<AuthViewModel>((ref) => sl<AuthViewModel>());
final specialsVMProvider =
    ChangeNotifierProvider<SpecialsViewModel>((ref) => sl<SpecialsViewModel>());
final storesVMProvider =
    ChangeNotifierProvider<StoresViewModel>((ref) => sl<StoresViewModel>());
final locationsVMProvider =
    ChangeNotifierProvider<LocationsViewModel>((ref) => sl<LocationsViewModel>());
final usersVMProvider =
    ChangeNotifierProvider<UsersViewModel>((ref) => sl<UsersViewModel>());

Future<void> main() async {
  // GetIt
  await initInjector();
  // Adding ProviderScope enables Riverpod for the entire project
  runApp(ProviderScope(child: App()));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authVM = context.read(authVMProvider);
    authVM.context = context;
    authVM.getCurrentUser();

    return VRouter(
      title: "FindGo",
      logs: VLogs.none,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          // primaryColor: Colors.green,
          backgroundColor: kColorBackground,
          accentColor: kColorAccent,
          // primaryIconTheme: IconThemeData(color: Colors.white),
          // accentIconTheme: IconThemeData(color: Colors.white),
          colorScheme: const ColorScheme.dark(
            primary: kColorAccent,
          ),
          // cardColor: CARD_COLOR,
          // buttonColor: ACCENT_COLOR,
          // elevatedButtonTheme: ElevatedButtonThemeData(
          //   style: ElevatedButton.styleFrom(
          //     primary: kColorBackground,
          //     onPrimary: Colors.white,
          //     side: const BorderSide(
          //       color: kColorAccent,
          //     ),
          //   ),
          // ),
          focusColor: kColorAccent,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      routes: [
        // VWidget(path: '/', widget: const Test(),
        VWidget(
          path: '/',
          widget: const HomePage(),
          buildTransition: (animation1, _, child) {
            return FadeTransition(opacity: animation1, child: child);
          },
        ),

        VWidget(
          path: '/login',
          widget: const LoginPage(),
          buildTransition: (animation1, _, child) {
            return FadeTransition(opacity: animation1, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),

        VWidget(
          path: '/password-reset',
          widget: PasswordResetPage(),
          buildTransition: (animation1, _, child) {
            return FadeTransition(opacity: animation1, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
        // VWidget(path: '/password-reset/:uuid', widget: PasswordResetPage(),
        //   buildTransition: (animation1, _, child) {
        //     return FadeTransition(opacity: animation1, child: child);
        //   }, transitionDuration: const Duration(milliseconds: 500),
        // ),

        VWidget(
          path: '/user',
          widget: const UserPage(),
          buildTransition: (animation1, _, child) {
            return FadeTransition(opacity: animation1, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),

        VWidget(
          path: '/special',
          widget: DownloadPage(),
          buildTransition: (animation1, _, child) {
            return FadeTransition(opacity: animation1, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),

        VWidget(
          path: '/error',
          widget: ErrorPage(),
          buildTransition: (animation1, _, child) {
            return FadeTransition(opacity: animation1, child: child);
          },
        ),

        VRouteRedirector(
          path: ':_(.*)',
          redirectTo: '/error',
        ),
      ],
    );

    //
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData.dark().copyWith(
    //     // primaryColor: Colors.green,
    //       backgroundColor: Colors.black,
    //       accentColor: kColorAccent,
    //       // primaryIconTheme: IconThemeData(color: Colors.white),
    //       // accentIconTheme: IconThemeData(color: Colors.white),
    //       colorScheme: const ColorScheme.dark(
    //         primary: kColorAccent,
    //       ),
    //       // cardColor: CARD_COLOR,
    //       // buttonColor: ACCENT_COLOR,
    //       // elevatedButtonTheme: ElevatedButtonThemeData(
    //       //   style: ElevatedButton.styleFrom(
    //       //     primary: kColorAccent,
    //       //     onPrimary: Colors.white,
    //       //   ),
    //       // ),
    //       focusColor: kColorAccent,
    //       visualDensity: VisualDensity.adaptivePlatformDensity
    //   ),
    //   // home: const HomePage(),
    //   home: const HomePage(),
    // );
  }
}
