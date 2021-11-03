import 'package:findgo/view_models/location_vm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import '../view_models/filter_vm.dart';
import '../view_models/network_vm.dart';
import '../view_models/theme_vm.dart';
import '../view_pages/contact_pg.dart';
import '../view_pages/saved_pg.dart';
import '../view_pages/terms_pg.dart';
import 'service_locator.dart';
import 'view_models/auth_vm.dart';
import 'view_models/specials_vm.dart';
import 'view_models/stores_vm.dart';
import 'view_pages/all_pg.dart';
import 'view_pages/brands_pg.dart';
import 'view_pages/home_pg.dart';
import 'view_pages/login_pg.dart';
import 'view_pages/map_pg.dart';
import 'view_pages/password_reset_pg.dart';
import 'view_pages/register_pg.dart';
import 'view_pages/user_pg.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // GetIt
  await initInjector();

  // Get Theme
  await sl<ThemeViewModel>().getThemeModeFromStorage();

  // WorkManager
  // _setupWorkManager();

  await Firebase.initializeApp();
  FirebaseMessaging.onMessage.listen((event) {
    print(event.notification!.title);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    print(event.notification!.title);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Adding ProviderScope enables Riverpod for the entire project
  runApp(ProviderScope(child: App()));
}

final authVMProvider =
    ChangeNotifierProvider<AuthViewModel>((ref) => sl<AuthViewModel>());
final filterVMProvider =
    ChangeNotifierProvider<FilterViewModel>((ref) => sl<FilterViewModel>());
final locationVMProvider =
    ChangeNotifierProvider<LocationViewModel>((ref) => sl<LocationViewModel>());
final networkVMProvider =
    ChangeNotifierProvider<NetworkViewModel>((ref) => sl<NetworkViewModel>());
final specialsVMProvider =
    ChangeNotifierProvider<SpecialsViewModel>((ref) => sl<SpecialsViewModel>());
final storesVMProvider =
    ChangeNotifierProvider<StoresViewModel>((ref) => sl<StoresViewModel>());

final themeVMProvider =
    ChangeNotifierProvider<ThemeViewModel>((ref) => sl<ThemeViewModel>());

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final themeVM = watch(themeVMProvider);
      return VRouter(
        title: "FindGo",
        logs: VLogs.none,
        debugShowCheckedModeBanner: false,
        theme: themeVM.mode == ThemeMode.dark ? themeVM.dark : themeVM.light,
        initialUrl: "/all",
        routes: [
          // VWidget(path: '/', widget: TestPage(),
          VWidget(
            path: '/',
            widget: const HomePage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),

          VWidget(
            path: '/login',
            widget: const LoginPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),

          VWidget(
            path: '/sign-up',
            widget: const RegisterPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),

          VWidget(
            path: '/all',
            widget: const AllPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),

          VWidget(
            path: '/saved',
            widget: const SavedPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),

          VWidget(
            path: '/brands',
            widget: BrandsPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),

          VWidget(
            path: '/map',
            widget: MapPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),
          VWidget(
            path: '/map/:storeUuid',
            widget: MapPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),

          VWidget(
            path: '/user',
            widget: const UserPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),

          VWidget(
            path: '/password-reset',
            widget: PasswordResetPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),

          VWidget(
            path: '/terms-conditions',
            widget: TermsConditionsPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),
          VWidget(
            path: '/contact',
            widget: ContactPage(),
            buildTransition: (animation1, _, child) {
              return FadeTransition(opacity: animation1, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1),
          ),
          //
          // VWidget(path: '/error', widget: ErrorPage(),
          //   buildTransition: (animation1, _, child) {
          //     return FadeTransition(opacity: animation1, child: child);
          //   },
          // ),
          //
          // VRouteRedirector(
          //   path: ':_(.*)',
          //   redirectTo: '/error',
          // ),
        ],
      );
    });
  }
}
