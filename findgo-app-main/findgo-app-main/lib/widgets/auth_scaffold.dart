import 'package:findgo/core/constants.dart';
import 'package:findgo/main.dart';
import 'package:findgo/view_models/auth_vm.dart';
import 'package:findgo/view_models/network_vm.dart';
import 'package:findgo/widgets/drawer_navbar.dart';
import 'package:findgo/widgets/util_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

class AuthScaffold extends ConsumerStatefulWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  const AuthScaffold({Key? key, required this.body, this.bottomNavigationBar})
      : super(key: key);

  @override
  _AuthScaffoldState createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends ConsumerState<AuthScaffold> {
  @override
  void initState() {
    final _specialsViewModel = ref.read(specialsVMProvider);
    final _storesViewModel = ref.read(storesVMProvider);
    final _authViewModel = ref.read(authVMProvider);

    // Do after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
                _storesViewModel.followedStoresUuidList,
              ))) {
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
    return Consumer(
      builder: (context, ref, child) {
        final networkVM = ref.watch(networkVMProvider);
        final themeVM = ref.watch(themeVMProvider);
        final specialVM = ref.watch(specialsVMProvider);
        specialVM.context = context;
        final authVM = ref.watch(authVMProvider);
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
      },
    );
  }
}
