import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import '../../core/constants.dart';
import '../../main.dart';
import '../../view_models/auth_vm.dart';
import '../internal_services/routes.dart';
import '../view_models/theme_vm.dart';
import '../view_pages/user_pg.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  late AuthViewModel _authViewModel;
  late ThemeViewModel _themeViewModel;
  int _sklarkDevCounter = 0;

  @override
  void initState() {
    _authViewModel = context.read(authVMProvider);
    _themeViewModel = context.read(themeVMProvider);
    // Do after build
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (_authViewModel.currentUser.uuid == "-1")
        await _authViewModel.getCurrentUser();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      // Watch Providers
      final themeVM = watch(themeVMProvider);
      final authVM = watch(authVMProvider);
      authVM.context = context;

      return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: kDrawerWidth,
        child: Container(
          color:
              themeVM.mode == ThemeMode.dark ? kColorCardDark : kColorCardLight,
          child: Column(
            children: [
              // Container(
              //   height: kNavHeight,
              //   width: double.infinity,
              //   color: ACCENT_COLOR,
              //   padding: const EdgeInsets.all(8.0),
              //   child: Row(
              //     children: [
              //       const Icon(Icons.face, color: Colors.white),
              //       const SizedBox(width: 8.0),
              //
              //     ],
              //   ),
              // ),
              const SizedBox(height: 40.0),
              _menuColumn(),
            ],
          ),
        ),
      );
    });
  }

  Widget _menuColumn() {
    return Container(
      height: MediaQuery.of(context).size.height - 40,
      width: kDrawerWidth + 50,
      color: _themeViewModel.mode == ThemeMode.dark
          ? kColorCardDark
          : kColorCardLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_authViewModel.currentUser.uuid == "-1")
            InkWell(
              onTap: () async {
                context
                    .findRootAncestorStateOfType<DrawerControllerState>()
                    ?.close();
                // widget.scaffoldKey.currentState.close(direction: InnerDrawerDirection.end);
                context.vRouter.to("/sign-up");
              },
              child: Container(
                width: double.infinity,
                height: kDrawerMenuTileHeight,
                color: context.vRouter.url == "/sign-up"
                    ? kColorBackgroundDark
                    : null,
                padding: kDrawerMenuTilePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Sign Up"),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          if (_authViewModel.currentUser.uuid == "-1")
            InkWell(
              onTap: () async {
                context
                    .findRootAncestorStateOfType<DrawerControllerState>()
                    ?.close();
                // widget.scaffoldKey.currentState.close(direction: InnerDrawerDirection.end);
                context.vRouter.to("/login");
              },
              child: Container(
                width: double.infinity,
                height: kDrawerMenuTileHeight,
                color: context.vRouter.url == "/login"
                    ? kColorBackgroundDark
                    : null,
                padding: kDrawerMenuTilePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Login"),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          if (_authViewModel.currentUser.uuid != "-1")
            InkWell(
              onTap: () async {
                context
                    .findRootAncestorStateOfType<DrawerControllerState>()
                    ?.close();
                // widget.scaffoldKey.currentState.close(direction: InnerDrawerDirection.end);
                // context.vRouter.push("/user");
                Routes.push(context, const UserPage());
              },
              child: Container(
                width: double.infinity,
                height: kDrawerMenuTileHeight,
                color: context.vRouter.url == "/user"
                    ? kColorBackgroundDark
                    : null,
                padding: kDrawerMenuTilePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: 160.0,
                        child: Text(
                          _authViewModel.currentUser.firstName,
                          overflow: TextOverflow.ellipsis,
                        )),
                    const Icon(Icons.account_circle, color: kColorAccent),
                  ],
                ),
              ),
            ),
          if (_authViewModel.currentUser.uuid != "-1")
            InkWell(
              onTap: () async {
                context
                    .findRootAncestorStateOfType<DrawerControllerState>()
                    ?.close();
                _authViewModel.logout();
              },
              child: Padding(
                padding: kDrawerMenuTilePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Logout"),
                    const Icon(Icons.logout),
                  ],
                ),
              ),
            ),
          kDrawerDivider,
          InkWell(
            onTap: () async {
              _themeViewModel.toggleMode();
            },
            child: Padding(
              padding: kDrawerMenuTilePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_themeViewModel.mode == ThemeMode.dark
                      ? "Light Mode"
                      : "Dark Mode"),
                  Icon(_themeViewModel.mode == ThemeMode.dark
                      ? Icons.wb_sunny_outlined
                      : Icons.nightlight_round),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () async {
                    context
                        .findRootAncestorStateOfType<DrawerControllerState>()
                        ?.close();
                    context.vRouter.to("/contact");
                  },
                  child: Padding(
                    padding: kDrawerMenuTilePadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Contact Us"),
                        const Icon(Icons.phone),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    context
                        .findRootAncestorStateOfType<DrawerControllerState>()
                        ?.close();
                    context.vRouter.to("/terms-conditions");
                  },
                  child: Padding(
                    padding: kDrawerMenuTilePadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Terms & Conditions"),
                        const Icon(Icons.file_copy),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () async {
                        _sklarkDevCounter++;
                        if (_sklarkDevCounter >= 7) {
                          _sklarkDevCounter = 0;
                          await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    // title: const Text("Alert"),
                                    content: const SizedBox(
                                        width: 200,
                                        child: Text(
                                            "A SkylarkDigital Development!")),
                                    actions: [
                                      TextButton(
                                          onPressed: () async =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Ok")),
                                    ],
                                  ));
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 8.0),
                        child: Text(
                          kVersion,
                          style: TextStyle(color: Colors.grey, fontSize: 8.0),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
