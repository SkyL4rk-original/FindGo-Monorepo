import 'package:findgo/core/constants.dart';
import 'package:findgo/data_models/special.dart';
import 'package:findgo/main.dart';
import 'package:findgo/view_models/filter_vm.dart';
import 'package:findgo/view_models/location_vm.dart';
import 'package:findgo/view_models/specials_vm.dart';
import 'package:findgo/view_models/stores_vm.dart';
import 'package:findgo/widgets/auth_scaffold.dart';
import 'package:findgo/widgets/bottom_nav.dart';
import 'package:findgo/widgets/filter_section.dart';
import 'package:findgo/widgets/loading.dart';
import 'package:findgo/widgets/special_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllPage extends ConsumerStatefulWidget {
  const AllPage({
    Key? key,
  }) : super(key: key);

  @override
  _AllPageState createState() => _AllPageState();
}

class _AllPageState extends ConsumerState<AllPage> with WidgetsBindingObserver {
  late final SpecialsViewModel _specialsViewModel;
  late final StoresViewModel _storesViewModel;
  late final FilterViewModel _filterViewModel;
  late final LocationViewModel _locationViewModel;

  final _scrollController = ScrollController();
  List<Special> _specialsList = [];

  // Filters
  SpecialType? _selectedSpecialType;
  DateTimeRange? _dateTimeRange;
  String _filterQuery = "";
  bool _showDistance = false;

  @override
  void initState() {
    _filterViewModel = ref.read(filterVMProvider);
    _specialsViewModel = ref.read(specialsVMProvider);
    _storesViewModel = ref.read(storesVMProvider);
    _locationViewModel = ref.read(locationVMProvider);

    // Do after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _specialsViewModel.context = context;
      _storesViewModel.context = context;

      // if (_locationViewModel.isInitCheck && await _locationViewModel.isLocationEnabled) {
      //   _locationViewModel.fetchCurrentPosition();
      // }
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

      _filterSpecials();
      setState(() {});
    });

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  Future<void> _filterSpecials() async {
    _specialsList = await _filterViewModel.filterSpecialList(
      filterLocation: _filterViewModel.hasLocation,
      filterString: _filterQuery,
      selectedSpecialType: _selectedSpecialType,
      dateRange: _dateTimeRange,
    );
    // print("recieved: $_specialsList");
    //_filterViewModel.setSpecialListState();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final specialsVM = ref.watch(specialsVMProvider);
          final storesVM = ref.watch(storesVMProvider);
          final themeVM = ref.watch(themeVMProvider);
          final filterVM = ref.watch(filterVMProvider);

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                specialsVM.getAllSpecials(),
                storesVM.getAllStores(),
                _locationViewModel.fetchCurrentPosition(),
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
                        "All",
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
                  expandedHeight:
                      2 * kToolbarHeight + 86 + (_showDistance ? 50 : 0),
                  // flexibleSpace: _inputSection(),
                  flexibleSpace: FilterSection(
                    onCalendarFilter: (dateRange) async {
                      _dateTimeRange = dateRange;
                      _filterSpecials();
                    },
                    onSearchSubmitted: (filterQuery) async {
                      _filterQuery = filterQuery;
                      _filterSpecials();
                    },
                    onTypeFilter: (specialType) async {
                      _selectedSpecialType = specialType;
                      _filterSpecials();
                    },
                    onLocationFilter: (showDistance) => setState(() {
                      _showDistance = showDistance;
                      _filterSpecials();
                    }),
                  ),
                ),
                if (specialsVM.state == SpecialViewState.busy ||
                    storesVM.state == StoresViewState.busy ||
                    filterVM.isBusy ||
                    _locationViewModel.busy)
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
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  List<Special> _shuffledList = [];
  Widget _specialsSliverListView() {
    // Randomize Filtered List
    _specialsList.shuffle();
    _shuffledList = _specialsList;

//     print(
//         "storesList empty ${_storesViewModel.storesList.isEmpty} : filteredSpecialList empty ${filteredList.isEmpty}");
    if (_storesViewModel.storesList.isEmpty || _specialsList.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("No active specials or events found")),
      );
    }

    // print("view: $_shuffledList");
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => SpecialCard(
          special: _shuffledList.elementAt(index),
        ),
        childCount: _shuffledList.length,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
