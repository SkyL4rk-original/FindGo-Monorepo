import 'package:findgo/view_models/network_vm.dart';
import 'package:findgo/widgets/util_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import '../core/constants.dart';
import '../main.dart';
import '../view_models/auth_vm.dart';
import '../widgets/drawer_navbar.dart';

class AuthScaffold extends StatefulWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  const AuthScaffold({Key? key, required this.body, this.bottomNavigationBar})
      : super(key: key);

  @override
  _AuthScaffoldState createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold> {
  @override
  void initState() {
    final _specialsViewModel = context.read(specialsVMProvider);
    final _storesViewModel = context.read(storesVMProvider);
    final _authViewModel = context.read(authVMProvider);

    // Do after build
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _specialsViewModel.context = context;
      _storesViewModel.context = context;
      _authViewModel.context = context;

      if (_authViewModel.currentUser.uuid == "-1") {
        await _authViewModel.getCurrentUser();
      }
      if (_authViewModel.currentUser.uuid == "-1") return;

      // Check for current location
//       _locationViewModel.context = context;
//       _locationViewModel.fetchCurrentPosition();

      if (_authViewModel.currentUser.uuid != "-1" &&
          (_specialsViewModel.specialsList.isEmpty ||
              _storesViewModel.storesList.isEmpty)) {
        await Future.wait([
          _specialsViewModel.getAllSavedSpecials(),
          _specialsViewModel.getAllSpecials(),
          _storesViewModel.getAllStores(),
          _storesViewModel.getAllFollowedStores(),
          //_storesViewModel.getAllNotifyStores(), TODO Put back when notification added
        ]);
      }

      if (_authViewModel.currentUser.uuid != "-1" &&
          _authViewModel.isInitialLogin &&
          (_storesViewModel.followedStoresUuidList.isEmpty ||
              !_specialsViewModel.hasActiveSpecialsFromFollowed(
                  _storesViewModel.followedStoresUuidList))) {
        context.vRouter.to("/all", isReplacement: true);
      }

      _specialsViewModel.initUniLinks();

      _authViewModel.isInitialLogin = false;
      //print("finish init auth scaffold: ");
      if (mounted) setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final networkVM = watch(networkVMProvider);
      final themeVM = watch(themeVMProvider);
      final specialVM = watch(specialsVMProvider);
      specialVM.context = context;
      final authVM = watch(authVMProvider);
      authVM.context = context;
      return GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: Colors.red,
        child: GestureDetector(
          onTap: () async => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: themeVM.mode == ThemeMode.dark
                ? kColorBackgroundDark
                : kColorBackgroundLight,
            endDrawer: NavDrawer(),
            body: Stack(
              children: [
                if (authVM.state == AuthViewState.fetchingUser ||
                    authVM.isInitialLogin)
                  const Center(
                    child: CircularProgressIndicator(color: kColorAccent),
                  )
                else
                  widget.body,
                if (networkVM.state == NetworkViewState.offline)
                  const OfflineWidget(),
              ],
            ),
            bottomNavigationBar: widget.bottomNavigationBar,
          ),
        ),
      );
    });
  }
}
