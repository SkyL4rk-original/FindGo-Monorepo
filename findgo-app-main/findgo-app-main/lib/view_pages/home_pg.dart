import 'dart:async';

import 'package:findgo/core/constants.dart';
import 'package:findgo/data_models/special.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../view_models/filter_vm.dart';
import '../view_models/specials_vm.dart';
import '../view_models/stores_vm.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/filter_section.dart';
import '../widgets/loading.dart';
import '../widgets/special_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late SpecialsViewModel _specialsViewModel;
  late StoresViewModel _storesViewModel;
  late FilterViewModel _filterViewModel;

  final ScrollController _scrollController = ScrollController();
  List<Special> _specialsList = [];

  // Filters
  SpecialType? _selectedSpecialType;
  DateTimeRange? _dateTimeRange;
  String _filterQuery = "";

  @override
  void initState() {
    _specialsViewModel = context.read(specialsVMProvider);
    _storesViewModel = context.read(storesVMProvider);
    _filterViewModel = context.read(filterVMProvider);

    // Do after build
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final locationVM = context.read(locationVMProvider);
      locationVM.context = context;

      // Wait for specials to populate
      int count = 60;
      while (count > 0) {
        if (_specialsViewModel.specialsList.isNotEmpty &&
            _storesViewModel.storesList.isNotEmpty &&
            _storesViewModel.followedStoresUuidList.isNotEmpty) break;
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        count--;
      }

      if (locationVM.latLng.isNil) await locationVM.fetchCurrentPosition();

      _filterSpecials();
      setState(() {});
    });

    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  Future<void> _filterSpecials() async {
    _specialsList = await _filterViewModel.filterSpecialList(
      filterFollowing: true,
      filterString: _filterQuery,
      selectedSpecialType: _selectedSpecialType,
      dateRange: _dateTimeRange,
    );
    //print("recieved: $_specialsList");
    //_filterViewModel.setSpecialListState();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      body: Consumer(
        builder: (context, watch, child) {
          final networkVM = watch(networkVMProvider);
          final specialsVM = watch(specialsVMProvider);
          final storesVM = watch(storesVMProvider);
          final themeVM = watch(themeVMProvider);
          final filterVM = watch(filterVMProvider);
          final locationVM = watch(locationVMProvider);

          // print("rebuild");

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                specialsVM.getAllSpecials(),
                storesVM.getAllStores(),
              ]);
              _filterSpecials();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: themeVM.mode == ThemeMode.dark
                      ? kColorCardDark
                      : kColorCardLight,
                  // elevation: 12.0,
                  snap: true,
                  // forceElevated: true,
                  floating: true,
                  // pinned: true,
                  title: Row(
                    children: [
                      SizedBox(
                        height: 24.0,
                        width: 24.0,
                        child: Image.asset("assets/icons/logo.png"),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        "Following",
                        style: TextStyle(
                          color: themeVM.mode == ThemeMode.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.menu_outlined,
                        color: themeVM.mode == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    )
                  ],
                  expandedHeight: 2 * kToolbarHeight + 86,
                  // flexibleSpace: _inputSection(),
                  flexibleSpace: FilterSection(
                    onCalendarFilter: (dateRange) {
                      _dateTimeRange = dateRange;
                      _filterSpecials();
                    },
                    onSearchSubmitted: (filterQuery) {
                      _filterQuery = filterQuery;
                      _filterSpecials();
                    },
                    onTypeFilter: (specialType) async {
                      _selectedSpecialType = specialType;
                      _filterSpecials();
                    },
                  ),
                ),
                if (storesVM.state == StoresViewState.busy ||
                    specialsVM.state == SpecialViewState.busy ||
                    filterVM.isBusy ||
                    locationVM.busy)
                  const SliverCircularLoading()
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: kToolbarHeight),
                    sliver: _specialsSliverListView(),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 3 * kToolbarHeight + 64,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 60.0,
                        ),
                        const Text("No more specials to display!"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _specialsSliverListView() {
    if (_storesViewModel.storesList.isEmpty || _specialsList.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("No active specials or events found")),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => SpecialCard(
          special: _specialsList.elementAt(index),
        ),
        childCount: _specialsList.length,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
