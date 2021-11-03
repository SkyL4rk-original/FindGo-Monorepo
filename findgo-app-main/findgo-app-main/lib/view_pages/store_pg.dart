import 'package:findgo/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import '../data_models/store.dart';
import '../main.dart';
import '../view_models/specials_vm.dart';
import '../view_models/stores_vm.dart';
import '../view_models/theme_vm.dart';
import '../widgets/buttons.dart';
import '../widgets/special_card.dart';

class StorePage extends StatefulWidget {
  final Store store;

  const StorePage({Key? key, required this.store}) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late SpecialsViewModel _specialsViewModel;
  late StoresViewModel _storesViewModel;
  late ThemeViewModel _themeViewModel;

  late Store _store;

  @override
  void initState() {
    _specialsViewModel = context.read(specialsVMProvider);
    _storesViewModel = context.read(storesVMProvider);
    _themeViewModel = context.read(themeVMProvider);

    _store = widget.store;

    // Do after build
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (_specialsViewModel.specialsList.isEmpty) {
        _specialsViewModel.getAllSpecials();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: kColorBackground,
        appBar: AppBar(
          backgroundColor: _themeViewModel.mode == ThemeMode.dark
              ? kColorCardDark
              : kColorCardLight,
          leading: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              } else {
                context.vRouter.to("/", isReplacement: true);
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: _themeViewModel.mode == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          title: Text(
            _store.name,
            style: TextStyle(
              color: _themeViewModel.mode == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ToggleStoreFollowButton(
                storesVM: _storesViewModel,
                store: _store,
              ),
            ),
          ],
        ),
        body: Consumer(
          builder: (context, watch, child) {
            final specialsVM = watch(specialsVMProvider);
            specialsVM.context = context;

            return _specialsListView();
          },
        ),
      ),
    );
  }

  Widget _specialsListView() {
    final filteredSpecialsList = _specialsViewModel.specialsList
        .where((special) => _store.uuid == special.storeUuid);
    if (filteredSpecialsList.isEmpty) {
      return const Center(child: Text("No specials or events found."));
    }

    return ListView.builder(
      itemCount: filteredSpecialsList.length,
      itemBuilder: (context, index) => SpecialCard(
        special: filteredSpecialsList.elementAt(index),
      ),
    );
  }
}

