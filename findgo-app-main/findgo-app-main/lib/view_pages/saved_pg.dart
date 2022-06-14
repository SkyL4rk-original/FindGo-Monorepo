import 'package:findgo/core/constants.dart';
import 'package:findgo/data_models/special.dart';
import 'package:findgo/main.dart';
import 'package:findgo/view_models/filter_vm.dart';
import 'package:findgo/view_models/specials_vm.dart';
import 'package:findgo/view_models/stores_vm.dart';
import 'package:findgo/widgets/auth_scaffold.dart';
import 'package:findgo/widgets/bottom_nav.dart';
import 'package:findgo/widgets/filter_section.dart';
import 'package:findgo/widgets/loading.dart';
import 'package:findgo/widgets/special_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedPage extends ConsumerStatefulWidget {
  const SavedPage({Key? key}) : super(key: key);

  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends ConsumerState<SavedPage>
    with WidgetsBindingObserver {
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
    _filterViewModel = ref.read(filterVMProvider);
    _specialsViewModel = ref.read(specialsVMProvider);
    _storesViewModel = ref.read(storesVMProvider);

    // Do after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _specialsViewModel.context = context;
      _storesViewModel.context = context;

      _filterSpecials();
    });

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  Future<void> _filterSpecials() async {
    _specialsList = await _filterViewModel.filterSpecialList(
      filterSaved: true,
      filterString: _filterQuery,
      selectedSpecialType: _selectedSpecialType,
      dateRange: _dateTimeRange,
    );

    // print("recieved: $_specialsList");
  }

  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   switch (state) {
  //     case AppLifecycleState.inactive:
  //     //print('appLifeCycleState inactive');
  //       break;
  //     case AppLifecycleState.resumed:
  //     //print('appLifeCycleState resumed');
  //       _specialsViewModel.getAllSpecials();
  //       _storesViewModel.getAllStores();
  //       break;
  //     case AppLifecycleState.paused:
  //     //print('appLifeCycleState paused');
  //       break;
  //     case AppLifecycleState.detached:
  //     //print('appLifeCycleState suspending');
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      body: Consumer(
        builder: (context, ref, child) {
          // final networkVM = ref.watch(networkVMProvider);
          ref.watch(networkVMProvider);
          final specialsVM = ref.watch(specialsVMProvider);
          final storesVM = ref.watch(storesVMProvider);
          final themeVM = ref.watch(themeVMProvider);
          final filterVM = ref.watch(filterVMProvider);

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
                        "Saved",
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
                    filterVM.isBusy)
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
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
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
