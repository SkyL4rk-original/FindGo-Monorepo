import 'package:cached_network_image/cached_network_image.dart';
import 'package:findgo/core/constants.dart';
import 'package:findgo/data_models/store.dart';
import 'package:findgo/internal_services/routes.dart';
import 'package:findgo/main.dart';
import 'package:findgo/view_models/stores_vm.dart';
import 'package:findgo/view_models/theme_vm.dart';
import 'package:findgo/view_pages/store_pg.dart';
import 'package:findgo/widgets/auth_scaffold.dart';
import 'package:findgo/widgets/bottom_nav.dart';
import 'package:findgo/widgets/buttons.dart';
import 'package:findgo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: prefer_function_declarations_over_variables
final Comparator<Store> _nameComparator =
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());

class BrandsPage extends ConsumerStatefulWidget {
  @override
  _BrandsPageState createState() => _BrandsPageState();
}

class _BrandsPageState extends ConsumerState<BrandsPage>
    with WidgetsBindingObserver {
  late StoresViewModel _storesViewModel;
  late ThemeViewModel _themeViewModel;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    final _specialsViewModel = ref.read(specialsVMProvider);
    _storesViewModel = ref.read(storesVMProvider);
    _themeViewModel = ref.read(themeVMProvider);

    // Do after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _specialsViewModel.context = context;
      _storesViewModel.context = context;
    });

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   switch (state) {
  //     case AppLifecycleState.inactive:
  //       //print('appLifeCycleState inactive');
  //       break;
  //     case AppLifecycleState.resumed:
  //       //print('appLifeCycleState resumed');
  //       _storesViewModel.getAllStores();
  //       break;
  //     case AppLifecycleState.paused:
  //       //print('appLifeCycleState paused');
  //       break;
  //     case AppLifecycleState.detached:
  //       //print('appLifeCycleState suspending');
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      body: Consumer(
        builder: (context, ref, child) {
          ref.watch(networkVMProvider);
          ref.watch(specialsVMProvider);
          final storesVM = ref.watch(storesVMProvider);
          final themeVM = ref.watch(themeVMProvider);

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                storesVM.getAllFollowedStores(),
                storesVM.getAllStores(),
              ]);
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: themeVM.mode == ThemeMode.dark
                      ? kColorCardDark
                      : kColorCardLight,
                  elevation: 0.0,
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
                        "Brands",
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
                  expandedHeight: 2 * kToolbarHeight + 14,
                  // flexibleSpace: _inputSection(),
                  flexibleSpace: _inputSection(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 4.0)),
                if (storesVM.state == StoresViewState.busy)
                  const SliverCircularLoading()
                else
                  _storeListView(),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: kToolbarHeight + 8,
                    child: Center(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  // FILTER INPUT
  String _filterString = "";
  bool _showOnlyFollowed = false;
  final kButtonFollowed = ElevatedButton.styleFrom(primary: kColorAccent);
  final kButtonAll = ElevatedButton.styleFrom(primary: kColorSecondaryText);
  Widget _inputSection() {
    return FlexibleSpaceBar(
      background: Column(
        children: [
          const SizedBox(height: kToolbarHeight + 26),

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    elevation: 0,
                    color: Colors.grey.withAlpha(40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          icon: Icon(
                            Icons.search,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (query) {
                          _filterString = query.toLowerCase();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _showOnlyFollowed = !_showOnlyFollowed;
                    setState(() {});
                  },
                  style: _showOnlyFollowed ? kButtonFollowed : kButtonAll,
                  // icon: const Icon(Icons.account_circle_outlined),
                  child: const Text("Followed"),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
        ],
      ),
    );
  }

  // LIST VIEW
  Widget _storeListView() {
    List<Store> filteredStoreList = _storesViewModel.storesList.toList();
    if (_showOnlyFollowed) {
      filteredStoreList = _storesViewModel.storesList
          .where(
            (store) => _storesViewModel.followedStoresUuidList
                .any((storeUuid) => storeUuid == store.uuid),
          )
          .toList();
    }

    filteredStoreList = filteredStoreList
        .where((store) => store.name.toLowerCase().contains(_filterString))
        .toList();

    filteredStoreList
        .removeWhere((store) => store.uuid == _storesViewModel.findgoUuid);
    filteredStoreList.sort(_nameComparator);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) =>
            _storeCard(filteredStoreList.elementAt(index)),
        childCount: filteredStoreList.length,
      ),
    );
  }

  Widget _storeCard(Store store) {
    return Card(
      color: _themeViewModel.mode == ThemeMode.dark
          ? kColorCardDark
          : kColorCardLight,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
        child: Column(
          children: [
            const SizedBox(height: 12.0),
            GestureDetector(
              onTap: () => Routes.push(context, StorePage(store: store)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // CachedNetworkImage(
                    //   imageUrl: store.imageUrl,
                    //   // placeholder: (context, url) => const CircularProgressIndicator(),
                    //   errorWidget: (context, url, error) => const Icon(Icons.error),
                    //   fit: BoxFit.fitWidth,
                    // ),
                    CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(store.imageUrl),
                      radius: 80,
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      store.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      store.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // if (store.category != "") const SizedBox(height: 4.0),
                    // if (store.category != "") Text(store.category, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis,),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 12.0,
            ),
            Text(store.description, style: const TextStyle(fontSize: 12)),
            const SizedBox(
              height: 4.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ToggleStoreFollowButton(
                  storesVM: _storesViewModel,
                  store: store,
                ),
                // const SizedBox(width: 16.0), TODO ADD BACK FOR NOTIFY
                // ToggleStoreNotifyButton(
                //     storesVM: _storesViewModel,
                //     store: store
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
