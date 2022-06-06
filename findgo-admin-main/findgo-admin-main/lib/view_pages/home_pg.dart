import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:image_compression/image_compression.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:vrouter/vrouter.dart';

import '../core/constants.dart';
import '../data_models/special.dart';
import '../data_models/store.dart';
import '../data_models/location.dart';
import '../main.dart';
import '../view_models/auth_vm.dart';
import '../view_models/specials_vm.dart';
import '../view_models/stores_vm.dart';
import '../view_models/locations_vm.dart';
import '../view_pages/store_pg.dart';
import '../view_pages/location_pg.dart';
import '../view_pages/store_stats_pg.dart';
import '../widgets/image_cropper.dart';
import '../widgets/loading.dart';
import '../widgets/notificaion_timer.dart';
import '../widgets/snackbar.dart';
import '../widgets/special_card.dart';
import '../widgets/stats_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AuthViewModel _authViewModel;
  late StoresViewModel _storesViewModel;
  late LocationsViewModel _locationsViewModel;
  late SpecialsViewModel _specialsViewModel;

  String _storeFilter = "";
  String _locationFilter = "";
  Store? _selectedStore;
  Location? _selectedLocation;

  Special? _tempSpecial;
  Special? _selectedSpecial;

  SpecialStatus? _specialFilterStatus;

  final _picker = ImagePicker();

  double _height = 0.0;
  // double _width = 0.0;

  // States
  bool _isBroadcastingMessage = false;

  @override
  void initState() {
    _authViewModel = context.read(authVMProvider);
    _storesViewModel = context.read(storesVMProvider);
    _locationsViewModel = context.read(locationsVMProvider);
    _specialsViewModel = context.read(specialsVMProvider);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      // print("CHECKING CURRENT USER HOME PG");
      if (await _authViewModel.getCurrentUser()) {
        _specialsViewModel.getAllSpecials();
        _storesViewModel.getAllStoreCategories();
        // _storesViewModel.getAllStoreLocations();
        await _storesViewModel.getAllStores();
        await _locationsViewModel.getAllLocations();
        // _storesViewModel.locationList = _locationsViewModel.locationsList;

        if (_authViewModel.currentUser.storeUuid != "") {
          _selectedStore = _storesViewModel.storesList.firstWhere(
              (store) => store.uuid == _authViewModel.currentUser.storeUuid);
          _showActivity = true;
        }
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    // _width = MediaQuery.of(context).size.width;

    if (_selectedSpecial != null &&
        _tempSpecial != null &&
        (_tempSpecial!.typeSet.contains(SpecialType.featured))) {
      final endOfDayValidFrom = DateTime(_tempSpecial!.validFrom.year,
          _tempSpecial!.validFrom.month, _tempSpecial!.validFrom.day, 23, 59);

      if (_tempSpecial!.validUntil.isAfter(endOfDayValidFrom) ||
          _tempSpecial!.validUntil.isBefore(_tempSpecial!.validFrom)) {
        _tempSpecial!.validUntil = endOfDayValidFrom;
      }
    }

    return GestureDetector(
      onTap: () async => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: ExcludeFocus(
            child: IconButton(
                onPressed: () async {
                  if (!await _removeSpecialChanges()) return;
                  context.vRouter.to("/user", isReplacement: true);
                },
                icon: const Icon(Icons.account_circle_outlined)),
          ),
          title: _authViewModel.currentUser.storeUuid != "" &&
                  _selectedStore != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_selectedStore!.name),
                    // const SizedBox(width: 12.0),
                    // InkWell(
                    //   canRequestFocus: false,
                    //   onTap: () async {
                    //     if (!await _removeSpecialChanges()) return;
                    //
                    //     await Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (ctx) => UsersPage(store: _selectedStore!),
                    //       ),
                    //     );
                    //   },
                    //   hoverColor: kColorAccent.withAlpha(60),
                    //   child: const Padding(
                    //     padding: EdgeInsets.all(8.0),
                    //     child: Text(
                    //       "Users", // Navbar
                    //       style: kTextStyleSmallSecondary,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(width: 12.0),
                    InkWell(
                      canRequestFocus: false,
                      onTap: () async {
                        if (!await _removeSpecialChanges()) return;

                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) =>
                                StoreStatsPage(store: _selectedStore!),
                          ),
                        );
                      },
                      hoverColor: kColorAccent.withAlpha(60),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Stats", // Navbar
                          style: kTextStyleSmallSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    InkWell(
                      canRequestFocus: false,
                      onTap: () async {
                        if (!await _removeSpecialChanges()) return;

                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => StorePage(store: _selectedStore),
                          ),
                        );
                      },
                      hoverColor: kColorAccent.withAlpha(60),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Edit", // Navbar
                          style: kTextStyleSmallSecondary,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          actions: [
            if (_authViewModel.currentUser.isSuperUser)
              ExcludeFocus(
                child: StatefulBuilder(builder: (context, setBroadCastState) {
                  if (_isBroadcastingMessage) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Center(
                        child: SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: LoadWidget(),
                        ),
                      ),
                    );
                  }
                  return TextButton(
                      onPressed: () async {
                        final message = await showDialog(
                          context: context,
                          builder: (ctx) => const BroadcastMessageDialog(),
                        ) as String?;

                        if (message != null && message.isNotEmpty) {
                          final confirmSend = await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Row(
                                children: [
                                  const Icon(Icons.error_outline),
                                  const SizedBox(width: 16.0),
                                  const Text("Confirm Broadcast"),
                                ],
                              ),
                              content: SizedBox(
                                width: 260.0,
                                child: Text(message),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text(
                                    "Cancel",
                                    style:
                                        TextStyle(color: kColorSecondaryText),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text(
                                    "Send",
                                  ),
                                ),
                              ],
                            ),
                          ) as bool?;

                          setBroadCastState(
                            () => _isBroadcastingMessage = true,
                          );
                          if (confirmSend != null && confirmSend)
                            await _authViewModel.broadcastMessage(message);
                          setBroadCastState(
                            () => _isBroadcastingMessage = false,
                          );
                        }
                      },
                      child: const Text(
                        "Broadcast",
                        style: TextStyle(color: Colors.white),
                      ));
                }),
              ),
            const SizedBox(
              width: 16.0,
            ),
            ExcludeFocus(
              child: TextButton(
                  onPressed: () async {
                    if (!await _removeSpecialChanges()) return;

                    _authViewModel.logout();
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            const SizedBox(
              width: 16.0,
            )
          ],
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Consumer(builder: (context, watch, child) {
                final authVM = watch(authVMProvider);
                final specialsVM = watch(specialsVMProvider);
                final storesVM = watch(storesVMProvider);
                final locationsVM = watch(locationsVMProvider);

                authVM.context = context;
                specialsVM.context = context;
                storesVM.context = context;

                return authVM.state == AuthViewState.fetchingUser
                    ? Center(child: LoadWidget())
                    : SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_authViewModel.currentUser.storeUuid == "")
                                  _locationSearchSection(),
                                if (_showStores) const SizedBox(width: 20.0),
                                if (_authViewModel.currentUser.storeUuid == "")
                                  _storeSearchSection(),
                                if (_showActivity) const SizedBox(width: 20.0),
                                if (_selectedStore != null) _activitySection(),
                                const SizedBox(width: 20.0),
                                if (_selectedSpecial != null)
                                  _selectedSpecialSection(),
                                const SizedBox(width: 20.0),
                                if (_selectedStore != null &&
                                    _selectedSpecial != null)
                                  SizedBox(
                                    width: 300.0,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 10.0),
                                        const SizedBox(
                                            height: 22.0,
                                            width: double.infinity,
                                            child: Center(
                                                child: Text(
                                              "Special Preview",
                                              textAlign: TextAlign.center,
                                            ))),
                                        const SizedBox(height: 16.0),
                                        SpecialCard(special: _tempSpecial!),
                                        const SizedBox(height: 16.0),
                                        if (_tempSpecial!.uuid != "" &&
                                            _tempSpecial!.status !=
                                                SpecialStatus.pending)
                                          SpecialStatsCard(
                                              special: _tempSpecial!),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
              }),
              Positioned(
                right: 8.0,
                bottom: 8.0,
                child: SizedBox(
                  width: 260.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const NotificationTimer(),
                      const Text(kVersion, style: kTextStyleSmallSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _showStores = false;
  // STORES SECTION
  Widget _storeSearchSection() {
    if (!_showStores) {
      return InkWell(
        canRequestFocus: false,
        onTap: () => setState(() => _showStores = true),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Icon(Icons.keyboard_arrow_right_rounded),
              const SizedBox(height: 16.0),
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  _selectedStore != null ? _selectedStore!.name : "Stores",
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        width: 300.0,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(
                canRequestFocus: false,
                onTap: () => setState(() => _showStores = false),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text("Stores"),
                      const SizedBox(
                        width: 12.0,
                      ),
                      const Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
              ),
              _addStoreButton(),
            ]),
            const SizedBox(height: 8.0),
            // const Divider(
            //   thickness: 0.5,
            //   color: kColorBackground,
            // ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search Store',
                icon: Icon(Icons.search),
              ),
              onChanged: (query) => setState(() => _storeFilter = query),
            ),
            const SizedBox(
              height: 20.0,
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height - 210.0,
                child: storeListView()),
          ],
        ),
      );
    }
  }

  bool _showLocations = true;
  // LOCATIONS SECTION
  Widget _locationSearchSection() {
    if (!_showLocations) {
      return InkWell(
        canRequestFocus: false,
        onTap: () => setState(() => _showLocations = true),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Icon(Icons.keyboard_arrow_right_rounded),
              const SizedBox(height: 16.0),
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  _selectedLocation != null ? _selectedLocation!.name : "Locations",
                  // "Locations",
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        width: 300.0,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(
                canRequestFocus: false,
                onTap: () => setState(() => _showLocations = false),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text("Locations"),
                      const SizedBox(
                        width: 12.0,
                      ),
                      const Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
              ),
              _addLocationButton(), // ?
            ]),
            const SizedBox(height: 8.0),
            // const Divider(
            //   thickness: 0.5,
            //   color: kColorBackground,
            // ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search Location',
                icon: Icon(Icons.search),
              ),
              onChanged: (query) => setState(() => _locationFilter = query),
            ),
            const SizedBox(
              height: 20.0,
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height - 210.0,
                child: locationListView()),
          ],
        ),
      );
    }
  }

  Widget storeListView() {
    return Consumer(builder: (context, watch, child) {
      final storeVM = watch(storesVMProvider);
      storeVM.context = context;

      final filteredStoresList = storeVM.storesList.where((store) =>
          store.name.toLowerCase().contains(_storeFilter.toLowerCase())
          && ((_selectedLocation == null || _selectedLocation!.id == 0 )? true : store.locationId == _selectedLocation!.id)
        );

      return storeVM.state == StoresViewState.busy
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              //scrollDirection: Axis.horizontal,
              itemCount: filteredStoresList.length,
              itemBuilder: (context, index) {
                final store = filteredStoresList.elementAt(index);
                return Card(
                  shape: const ContinuousRectangleBorder(),
                  margin: EdgeInsets.zero,
                  color: _selectedStore != null &&
                          store.uuid == _selectedStore!.uuid
                      ? kColorSelected
                      : kColorCard,
                  child: InkWell(
                    canRequestFocus: false,
                    onTap: () async {
                      if (!await _removeSpecialChanges()) return;

                      _selectedSpecial = null;
                      _tempSpecial = null;
                      _selectedStore = store;
                      _showStores = false;
                      _showActivity = true;
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(store.name),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // InkWell(
                              //   canRequestFocus: false,
                              //   onTap: () async {
                              //     if (!await _removeSpecialChanges()) return;
                              //
                              //     await Navigator.of(context).push(
                              //       MaterialPageRoute(
                              //         builder: (ctx) => UsersPage(store: store),
                              //       ),
                              //     );
                              //   },
                              //   hoverColor: kColorAccent.withAlpha(60),
                              //   child: const Padding(
                              //     padding: EdgeInsets.all(8.0),
                              //     child: Text(
                              //       "Users", // Navbar
                              //       style: kTextStyleSmallSecondary,
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(width: 8.0),
                              InkWell(
                                canRequestFocus: false,
                                onTap: () async {
                                  if (!await _removeSpecialChanges()) return;

                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          StoreStatsPage(store: store),
                                    ),
                                  );
                                },
                                hoverColor: kColorAccent.withAlpha(60),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Stats", // Navbar
                                    style: kTextStyleSmallSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              InkWell(
                                canRequestFocus: false,
                                onTap: () async {
                                  if (!await _removeSpecialChanges()) return;

                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => StorePage(store: store),
                                    ),
                                  );
                                },
                                hoverColor: kColorAccent.withAlpha(60),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Edit",
                                    style: kTextStyleSmallSecondary,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              });
    });
  }

  Widget locationListView() {
    return Consumer(builder: (context, watch, child) {
      final locationVM = watch(locationsVMProvider);
      locationVM.context = context;

      List<Location> tmpList = locationVM.locationsList;
      Location tmpLocation = Location(id: 0, name: "All Stores");
      if(tmpList.contains(tmpLocation)) {
        tmpList.remove(tmpLocation);
      }
      tmpList.insert(0, tmpLocation);
      final filteredLocationsList = tmpList.where((location) =>
          location.name.toLowerCase().contains(_locationFilter.toLowerCase()));

      return locationVM.state == LocationsViewState.busy
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              //scrollDirection: Axis.horizontal,
              itemCount: filteredLocationsList.length,
              itemBuilder: (context, index) {
                final location = filteredLocationsList.elementAt(index);
                return Card(
                  shape: const ContinuousRectangleBorder(),
                  margin: EdgeInsets.zero,
                  color: _selectedLocation == null && location.id == 0 ? kColorSelected : _selectedLocation != null &&
                          location.id == _selectedLocation!.id
                      ? kColorSelected
                      : kColorCard,
                  child: InkWell(
                    canRequestFocus: false,
                    onTap: () async {
                      if (!await _removeSpecialChanges()) return;

                      _selectedSpecial = null;
                      _tempSpecial = null;
                      _selectedLocation = location;
                      _showLocations = false;
                      _showStores = true;
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(location.name),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(width: 8.0),
                              if(location.id != 0)
                              InkWell(
                                canRequestFocus: false,
                                onTap: () async {
                                  if (!await _removeSpecialChanges()) return;

                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => LocationPage(location: location),
                                    ),
                                  );
                                },
                                hoverColor: kColorAccent.withAlpha(60),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Edit",
                                    style: kTextStyleSmallSecondary,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              });
    });
  }

  Widget _addStoreButton() {
    return SizedBox(
      height: 40.0,
      width: 130.0,
      child: Center(
          child: ExcludeFocus(
        child: TextButton.icon(
          onPressed: () async {
            final newStoreUuid = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const StorePage(),
              ),
            ) as String?;

            if (newStoreUuid != null) {
              _selectedStore = _storesViewModel.storesList
                  .firstWhere((store) => store.uuid == newStoreUuid);
              _selectedSpecial = null;
              _tempSpecial = null;
              setState(() {});
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Store"),
        ),
      )),
    );
  }

  Widget _addLocationButton() {
    return SizedBox(
      height: 40.0,
      width: 130.0,
      child: Center(
          child: ExcludeFocus(
        child: TextButton.icon(
          onPressed: () async {
            final newLocationId = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const LocationPage(),
              ),
            ) as int?;

            // if (newStoreUuid != null) {
            //   _selectedStore = _storesViewModel.storesList
            //       .firstWhere((store) => store.uuid == newStoreUuid);
            //   _selectedSpecial = null;
            //   _tempSpecial = null;
            //   setState(() {});
            // }
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Location"),
        ),
      )),
    );
  }

  // ACTIVITY SECTION
  // ButtonStyle _specialStatusInactiveTextButtonStyle(Color color) {
  //   return TextButton.styleFrom(
  //       primary: color,
  //       side: BorderSide(color: color),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))
  //   );
  // }
  // ButtonStyle _specialStatusActiveTextButtonStyle(Color color) {
  //   return TextButton.styleFrom(
  //       primary: Colors.white,
  //       backgroundColor: color,
  //       side: BorderSide(color: color),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))
  //   );
  // }
  Color _getStatusColor(Special special) {
    if (special.status == SpecialStatus.pending) return kColorWarning;
    if (special.status == SpecialStatus.active) return kColorActive;
    if (special.status == SpecialStatus.inactive) return kColorInactive;
    return kColorRepeated;
  }

  String _getFilterDropdownValue() {
    switch (_specialFilterStatus) {
      case null:
        return "all";
      case SpecialStatus.pending:
        return "pending";
      case SpecialStatus.active:
        return "active";
      case SpecialStatus.inactive:
        return "inactive";
      default:
        return "all";
    }
  }

  List<DropdownMenuItem<String>> _specialStatusList() {
    final List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(
        value: "all",
        child: Text("All"),
      ),
      const DropdownMenuItem(
        value: "pending",
        child: Text("Pending"),
      ),
      const DropdownMenuItem(
        value: "active",
        child: Text("Active"),
      ),
      const DropdownMenuItem(
        value: "inactive",
        child: Text("Inactive"),
      ),
    ];
    return items;
  }

  bool _showActivity = false;
  Widget _activitySection() {
    if (!_showActivity) {
      return InkWell(
        canRequestFocus: false,
        onTap: () => setState(() => _showActivity = true),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Icon(Icons.keyboard_arrow_right_rounded),
              const SizedBox(
                height: 16.0,
              ),
              const RotatedBox(
                quarterTurns: 3,
                child: Text("Activity"),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        width: 300.0,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(
                canRequestFocus: false,
                onTap: () => setState(() => _showActivity = false),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text("Activity"),
                      const SizedBox(
                        width: 12.0,
                      ),
                      const Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
              ),
              _addSpecialButton(),
            ]),
            // const SizedBox(height: 16.0),
            // const Align(
            //   alignment: Alignment.centerLeft,
            //     child: Text("Filter:", style: kTextStyleSmallSecondary)
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField(
                  icon: const Icon(Icons.filter_list_outlined),
                  value: _getFilterDropdownValue(),
                  items: _specialStatusList(),
                  onChanged: (specialStatus) {
                    if (specialStatus != null) {
                      switch (specialStatus) {
                        case "all":
                          _specialFilterStatus = null;
                          break;
                        case "pending":
                          _specialFilterStatus = SpecialStatus.pending;
                          break;
                        case "active":
                          _specialFilterStatus = SpecialStatus.active;
                          break;
                        case "inactive":
                          _specialFilterStatus = SpecialStatus.inactive;
                          break;
                        default:
                          _specialFilterStatus = null;
                      }

                      setState(() {});
                    }
                  }),
            ),
            const SizedBox(height: 16.0),
            SizedBox(height: _height - 60.0, child: _activityListView()),
          ],
        ),
      );
    }
  }

  Widget _activityListView() {
    // Add specials with matching store uuids & matching _selectedStatus
    final storeSpecialsList = _specialsViewModel.specialsList.where((special) =>
        // ignore: avoid_bool_literals_in_conditional_expressions
        special.storeUuid == _selectedStore!.uuid &&
        (_specialFilterStatus == null
            ? true
            : special.status == _specialFilterStatus));

    return _specialsViewModel.state == SpecialViewState.busy
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: storeSpecialsList.length,
            itemBuilder: (context, index) {
              final special = storeSpecialsList.elementAt(index);
              return Card(
                color: _selectedSpecial != null &&
                        special.uuid == _selectedSpecial!.uuid
                    ? kColorSelected
                    : kColorCard,
                child: InkWell(
                  canRequestFocus: false,
                  onTap: () async {
                    if (!await _removeSpecialChanges()) return;

                    if (_selectedSpecial == special) {
                      _selectedSpecial = null;
                      _tempSpecial = null;
                    } else {
                      _selectedSpecial = special;
                      _tempSpecial = special.copyWith();
                      _nameTextEditingController.text = special.name;
                      _priceTextEditingController.text =
                          (special.price.abs() / 100).toStringAsFixed(2);
                      _descriptionTextEditingController.text =
                          special.description;
                      // _showActivity = false;
                    }
                    setState(() {});
                  },
                  child: SizedBox(
                    width: 280.0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: SizedBox(
                                      child: Text(special.name.toUpperCase()))),
                              Text(
                                  toBeginningOfSentenceCase(
                                      special.statusToString)!,
                                  style: TextStyle(
                                      color: _getStatusColor(special))),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          Text(_typeStringBuilder(special.typeSet),
                              style:
                                  const TextStyle(color: kColorSecondaryText)),
                          const SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  DateFormat.yMMMd()
                                      .add_jm()
                                      .format(special.validFrom),
                                  style: kTextStyleTinySecondary),
                              Text(
                                  DateFormat.yMMMd()
                                      .add_jm()
                                      .format(special.validUntil),
                                  style: kTextStyleTinySecondary),
                            ],
                          ),
                          // const Divider(
                          //   thickness: 1.0,
                          //   color: kColorRepeated,
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
  }

  String _typeStringBuilder(Set<SpecialType> typeSet) {
    String typeString = "";
    if (typeSet.isEmpty) return typeString;
    for (final type in typeSet) {
      typeString =
          "$typeString   ${type.toString().substring(12).capitalizeFirsTofEach}";
    }
    return typeString.substring(0, typeString.length);
  }

  Widget _addSpecialButton() {
    Widget buttonContent;
    if (_specialsViewModel.state == SpecialViewState.create) {
      buttonContent = const SizedBox(
          height: 30.0,
          width: 30.0,
          child: Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kColorAccent),
            strokeWidth: 2,
          )));
    } else {
      buttonContent = ExcludeFocus(
        child: TextButton.icon(
          onPressed: () async {
            if (_selectedStore == null) {
              InfoSnackBar.show(context, "No Store Selected",
                  color: SnackBarColor.error);
              return;
            }
            if (!await _removeSpecialChanges()) return;

            final now = DateTime.now();
            _tempSpecial = Special(
              uuid: "",
              storeUuid: _selectedStore!.uuid,
              storeName: _selectedStore!.name,
              storeCategory: _selectedStore!.category,
              storeImageUrl: _selectedStore!.imageUrl,
              typeSet: {SpecialType.special},
              validFrom: now.add(const Duration(minutes: 30)),
              validUntil: DateTime(now.year, now.month, now.day, 23, 59),
            );
            _selectedSpecial = _tempSpecial!.copyWith();
            _nameTextEditingController.text = "";
            _priceTextEditingController.text = "";
            _descriptionTextEditingController.text = "";

            _showActivity = false;
            setState(() {});
            // _selectedSpecial = await _specialsViewModel.createSpecial(_selectedStore!);
            // if (_selectedSpecial != null) _tempSpecial = _selectedSpecial!.copyWith();
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Special"),
        ),
      );
    }
    return SizedBox(
      height: 40.0,
      width: 130.0,
      child: Center(child: buttonContent),
    );
  }

  // SPECIALS SECTION
  final _kSpecialTypeButtonHeight = 30.0;
  final _formKey = GlobalKey<FormState>();
  final _nameTextEditingController = TextEditingController();
  final _priceTextEditingController = TextEditingController();
  final _descriptionTextEditingController = TextEditingController();
  final _formHeadingTextStyle =
      const TextStyle(fontSize: 12.0, color: kColorSecondaryText);
  final _nameFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  Future<bool> _removeSpecialChanges() async {
    if (_tempSpecial == null || _tempSpecial!.status != SpecialStatus.pending) {
      return true;
    }

    if ((_selectedSpecial != null &&
            _selectedSpecial!.isUpdated(_tempSpecial!)) ||
        _tempSpecial!.uuid.isEmpty) {
      final confirmCancel = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.error_outline),
                    const SizedBox(width: 16.0),
                    const Text("Unsaved Changes"),
                  ],
                ),
                content: const SizedBox(
                    width: 260.0,
                    child: Text(
                        "Please confirm you want to remove all changes made to current special.")),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text("Remove")),
                ],
              )) as bool?;

      if (confirmCancel == null || confirmCancel == false) return false;
    }
    return true;
  }

  Widget _duplicateSpecialButton() {
    Widget buttonContent;
    if (_specialsViewModel.state == SpecialViewState.create) {
      buttonContent = const SizedBox(
          height: 30.0,
          width: 30.0,
          child: Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kColorAccent),
            strokeWidth: 2,
          )));
    } else {
      buttonContent = TextButton.icon(
        onPressed: () async {
          if (!await _removeSpecialChanges()) return;

          //   final _duplicateSpecial = _tempSpecial!.copyWith(
          //       name: _tempSpecial!.name,
          //       impressions: 0,
          //       clicks: 0,
          //       websiteClicks: 0,
          //       savedClicks: 0,
          //       shareClicks: 0,
          //       phoneClicks: 0,
          //       copied: true,
          //   );
          //   final tempSpecial = await _specialsViewModel.createSpecial(_duplicateSpecial);
          //   if (tempSpecial != null) {
          //     _selectedSpecial = tempSpecial;
          //     _tempSpecial = _selectedSpecial!.copyWith();
          //     _tempSpecial!.image = null;
          //     setState(() {});
          //   }
          _showActivity = false;
          _tempSpecial = _tempSpecial!.copyWith(
            uuid: "",
            status: SpecialStatus.pending,
            impressions: 0,
            clicks: 0,
            websiteClicks: 0,
            savedClicks: 0,
            shareClicks: 0,
            phoneClicks: 0,
            copied: true,
          );
          // _selectedSpecial = _tempSpecial;
          setState(() {});
        },
        icon: const Icon(
          Icons.add,
          color: kColorAccent,
        ),
        label: const Text(
          "Duplicate Special",
          style: TextStyle(color: kColorAccent),
        ),
      );
    }

    return SizedBox(
      height: 40.0,
      width: 140.0,
      child: Center(child: buttonContent),
    );
  }

  Widget _selectedSpecialSection() {
    return SizedBox(
      width: 360.0,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                    height: 38.0,
                    child: Center(
                        child: Text(
                      "Edit Special",
                      textAlign: TextAlign.center,
                    ))),
                _duplicateSpecialButton(),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Card(
            color: kColorSelected,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _tempSpecial!.copied
                              ? const Text("DUPLICATE ",
                                  style: TextStyle(color: Colors.yellowAccent))
                              : const SizedBox(),
                        ),
                        Text(
                            toBeginningOfSentenceCase(
                                _tempSpecial!.statusToString)!,
                            style: TextStyle(
                                color: _getStatusColor(_tempSpecial!))),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Text("Type", style: _formHeadingTextStyle),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: Tooltip(
                            message: "General promotion",
                            child: SizedBox(
                              height: _kSpecialTypeButtonHeight,
                              child: InkWell(
                                canRequestFocus: false,
                                onTap: () async {
                                  // if (_tempSpecial!.typeSet.contains(SpecialType.brand)) {
                                  //   _tempSpecial!.typeSet.remove(SpecialType.brand);
                                  // } else {  _tempSpecial!.typeSet.add(SpecialType.brand); }

                                  _tempSpecial!.typeSet = {SpecialType.special};
                                  setState(() {});
                                },
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: _tempSpecial!.typeSet
                                                .contains(SpecialType.special)
                                            ? kColorAccent
                                            : kColorCard),
                                    child:
                                        const Center(child: Text("Special"))),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Tooltip(
                            message: "Live music",
                            child: SizedBox(
                              height: _kSpecialTypeButtonHeight,
                              child: InkWell(
                                canRequestFocus: false,
                                onTap: () async {
                                  // if (_tempSpecial!.typeSet.contains(SpecialType.event)) {
                                  //   _tempSpecial!.typeSet.remove(SpecialType.event);
                                  // } else {  _tempSpecial!.typeSet.add(SpecialType.event); }

                                  _tempSpecial!.typeSet = {SpecialType.event};
                                  setState(() {});
                                },
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: _tempSpecial!.typeSet
                                                .contains(SpecialType.event)
                                            ? kColorAccent
                                            : kColorCard),
                                    child: const Center(child: Text("Event"))),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Tooltip(
                            message: "Reduced price on items",
                            child: SizedBox(
                              height: _kSpecialTypeButtonHeight,
                              child: InkWell(
                                canRequestFocus: false,
                                onTap: () async {
                                  // if (_tempSpecial!.typeSet.contains(SpecialType.discount)) {
                                  //   _tempSpecial!.typeSet.remove(SpecialType.discount);
                                  // } else {  _tempSpecial!.typeSet.add(SpecialType.discount); }

                                  _tempSpecial!.typeSet = {
                                    SpecialType.discount
                                  };
                                  setState(() {});
                                },
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: _tempSpecial!.typeSet
                                                .contains(SpecialType.discount)
                                            ? kColorAccent
                                            : kColorCard),
                                    child:
                                        const Center(child: Text("Discount"))),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Tooltip(
                            message: "Special that runs only on a specific day",
                            child: SizedBox(
                              height: _kSpecialTypeButtonHeight,
                              child: InkWell(
                                canRequestFocus: false,
                                onTap: () async {
                                  // if (_tempSpecial!.typeSet.contains(SpecialType.featured)) {
                                  //   _tempSpecial!.typeSet.remove(SpecialType.featured);
                                  // } else {  _tempSpecial!.typeSet.add(SpecialType.featured); }

                                  _tempSpecial!.typeSet = {
                                    SpecialType.featured
                                  };
                                  setState(() {});
                                },
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: _tempSpecial!.typeSet
                                                .contains(SpecialType.featured)
                                            ? kColorAccent
                                            : kColorCard),
                                    child:
                                        const Center(child: Text("Featured"))),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    InkWell(
                      canRequestFocus: false,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () => _nameFocusNode.requestFocus(),
                      child: Text("Name", style: _formHeadingTextStyle),
                    ),
                    TextFormField(
                      onChanged: (name) {
                        _tempSpecial!.name = name.trim().toUpperCase();
                        setState(() {});
                      },
                      onFieldSubmitted: (name) {
                        _tempSpecial!.name = name.trim().toUpperCase();
                        setState(() {});
                      },
                      // style: const TextStyle(height: 1.0),
                      focusNode: _nameFocusNode,
                      controller: _nameTextEditingController,
                    ),
                    const SizedBox(height: 16.0),
                    InkWell(
                      canRequestFocus: false,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () => _priceFocusNode.requestFocus(),
                      child: Text("Price", style: _formHeadingTextStyle),
                    ),
                    TextFormField(
                      onChanged: (price) {
                        final doublePrice = double.tryParse(price.trim());
                        if (doublePrice != null) {
                          _tempSpecial!.price =
                              (doublePrice.abs() * 100).toInt();
                        } else {
                          _tempSpecial!.price = 0;
                        }
                        setState(() {});
                      },
                      onFieldSubmitted: (price) {
                        final doublePrice = double.tryParse(price.trim());
                        if (doublePrice != null) {
                          _tempSpecial!.price =
                              (doublePrice.abs() * 100).toInt();
                        }
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        hintText: 'R 0.00',
                      ),
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      controller: _priceTextEditingController,
                    ),
                    const SizedBox(height: 16.0),
                    if (_tempSpecial!.status == SpecialStatus.pending)
                      Text("Image (1080 x 864)", style: _formHeadingTextStyle),
                    if (_tempSpecial!.status == SpecialStatus.pending)
                      const SizedBox(height: 8.0),
                    if (_tempSpecial!.status == SpecialStatus.pending)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                              onPressed: () async {
                                final pickedFile = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  var file = await pickedFile.readAsBytes();

                                  // If file large -> over 1MB
                                  if (file.lengthInBytes > kMaxImageByteSize) {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                              content: SizedBox(
                                                height: 250.0,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                        "Loading large file... may take a while",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                    const SizedBox(
                                                        height: 16.0),
                                                    const CircularProgressIndicator(),
                                                  ],
                                                ),
                                              ),
                                            ));
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));

                                    final input = ImageFile(
                                      rawBytes: file,
                                      filePath: pickedFile.path,
                                    );
                                    final compImg = await compressInQueue(
                                        ImageFileConfiguration(
                                      input: input,
                                      config:
                                          const Configuration(jpgQuality: 30),
                                    ));
                                    file = compImg.rawBytes;

                                    Navigator.of(context).pop();
                                  }
//                                   print(
//                                       "${pickedFile.path} : ${file.lengthInBytes / 1000000}");
                                  if (file.lengthInBytes > kMaxImageByteSize) {
                                    InfoSnackBar.show(
                                        context, "Image too large",
                                        color: SnackBarColor.error);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const AlertDialog(
                                          backgroundColor: kColorError,
                                          title: Center(
                                              child: Text("Image too large")),
                                          content: Text(
                                              "Max image upload size is ${kMaxImageByteSize / 1000000}MB"),
                                          actions: [],
                                          elevation: 4,
                                        );
                                      },
                                    );
                                    return;
                                  }

                                  _tempSpecial!.image = file;
                                  setState(() {});
                                } else {
                                  print('No image selected.');
                                }
                              },
                              icon: const Icon(
                                Icons.image_outlined,
                                color: Colors.white,
                              ),
                              label: _tempSpecial!.image == null &&
                                      _tempSpecial!.imageUrl == ""
                                  ? const Text("Add Image",
                                      style: TextStyle(color: Colors.white))
                                  : const Text("Update Image",
                                      style: TextStyle(color: Colors.white))
                              // ? const Text("Add Image (max ${kMaxImageByteSize/1000000}MB)", style: TextStyle(color: Colors.white))
                              // : const Text("Update Image (max ${kMaxImageByteSize/1000000}MB)", style: TextStyle(color: Colors.white))
                              ),
                          if (_tempSpecial!.image != null ||
                              _tempSpecial!.imageUrl.isNotEmpty)
                            TextButton.icon(
                              onPressed: () async {
                                late Uint8List image;
                                if (_tempSpecial!.image == null) {
                                  final client = Client();
                                  final r = await client.get(
                                    Uri.parse(_tempSpecial!.imageUrl),
                                  );

                                  // we get the bytes from the body
                                  image = r.bodyBytes;
                                } else {
                                  image = _tempSpecial!.image!;
                                }

                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          content: SizedBox(
                                            height: 250.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                    "Preparing... may take a while",
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                const SizedBox(height: 16.0),
                                                const CircularProgressIndicator(),
                                              ],
                                            ),
                                          ),
                                        ));
                                await Future.delayed(
                                    const Duration(milliseconds: 300));
                                final img = await showDialog(
                                        context: context,
                                        builder: (ctx) =>
                                            ImageCropper(image: image))
                                    as Uint8List?;
                                if (img != null) _tempSpecial!.image = img;
                                Navigator.of(context).pop();
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.crop,
                                color: Colors.white,
                              ),
                              label: const Text("Crop Image",
                                  style: TextStyle(color: Colors.white)),
                            ),
                        ],
                      ),
                    if (_tempSpecial!.status == SpecialStatus.pending)
                      const SizedBox(height: 16.0),
                    InkWell(
                      canRequestFocus: false,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () => _descriptionFocusNode.requestFocus(),
                      child: Text("Description & Terms",
                          style: _formHeadingTextStyle),
                    ),
                    const SizedBox(height: 8.0),
                    Stack(
                      children: [
                        TextFormField(
                          validator: (description) {
                            if (description == null || description.isEmpty) {
                              return "please enter a message";
                            }
                            return null;
                          },
                          onChanged: (description) {
                            _tempSpecial!.description = description;
                            setState(() {});
                          },
                          onFieldSubmitted: (description) {
                            _tempSpecial!.description = description;
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              helperMaxLines: 4,
                              hintMaxLines: 4),
                          focusNode: _descriptionFocusNode,
                          controller: _descriptionTextEditingController,
                          style: const TextStyle(fontSize: 12.0),
                          keyboardType: TextInputType.multiline,
                          maxLength: 500,
                          maxLines: 4,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 34,
                          child: TextButton(
                            onPressed: () async =>
                                setState(() => _descriptionFocusNode.unfocus()),
                            child: Text(
                              "Save",
                              style: TextStyle(
                                  color: _descriptionFocusNode.hasFocus
                                      ? kColorAccent
                                      : kColorSecondaryText),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    /// VALID DATE BUTTONS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Valid From",
                                    style: _formHeadingTextStyle),
                                const SizedBox(height: 4.0),
                                InkWell(
                                  onTap: () async {
                                    final tempTime = TimeOfDay.fromDateTime(
                                        _tempSpecial!.validFrom);
                                    final picked = await selectDate(
                                        _tempSpecial!.validFrom);

                                    if (picked != null &&
                                        picked != _tempSpecial!.validFrom) {
                                      setState(() {
                                        _tempSpecial!.validFrom = DateTime(
                                            picked.year,
                                            picked.month,
                                            picked.day,
                                            tempTime.hour,
                                            tempTime.minute);
                                        // _gift.validUntil = DateTime(_gift.validFrom.year, _gift.validFrom.month + _giftCard.validDurationMonth, _gift.validFrom.day, _gift.validFrom.hour, _gift.validFrom.minute);
                                        //print("valid from: ${_gift.validFrom} -- until ${_gift.validUntil}");
                                      });
                                    }

                                    if (_tempSpecial!.validUntil
                                        .isBefore(_tempSpecial!.validFrom)) {
                                      _tempSpecial!.validUntil =
                                          _tempSpecial!.validFrom;
                                    }
                                  },
                                  child: Text(
                                    DateFormat.yMMMd()
                                        .format(_tempSpecial!.validFrom),
                                    style: TextStyle(
                                        color: _tempSpecial!.status ==
                                                    SpecialStatus.pending &&
                                                _tempSpecial!.validFrom
                                                    .isBefore(DateTime.now())
                                            ? kColorError
                                            : Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                InkWell(
                                    onTap: () async {
                                      final tempDate = _tempSpecial!.validFrom;
                                      final picked = await selectTime(
                                          TimeOfDay.fromDateTime(
                                              _tempSpecial!.validFrom));

                                      if (picked != null &&
                                          picked !=
                                              TimeOfDay.fromDateTime(
                                                  _tempSpecial!.validFrom)) {
                                        setState(() {
                                          _tempSpecial!.validFrom = DateTime(
                                              tempDate.year,
                                              tempDate.month,
                                              tempDate.day,
                                              picked.hour,
                                              picked.minute);
                                          // _gift.validUntil = DateTime(_gift.validFrom.year, _gift.validFrom.month + _giftCard.validDurationMonth, _gift.validFrom.day, _gift.validFrom.hour, _gift.validFrom.minute);
                                          //print("valid from: ${_gift.validFrom} -- until ${_gift.validUntil}");
                                        });
                                      }

                                      if (_tempSpecial!.validUntil
                                          .isBefore(_tempSpecial!.validFrom)) {
                                        _tempSpecial!.validUntil =
                                            _tempSpecial!.validFrom;
                                      }
                                    },
                                    child: Text(
                                      DateFormat.Hm()
                                          .format(_tempSpecial!.validFrom),
                                      style: TextStyle(
                                          color: _tempSpecial!.status ==
                                                      SpecialStatus.pending &&
                                                  _tempSpecial!.validFrom
                                                      .isBefore(DateTime.now())
                                              ? kColorError
                                              : Colors.white),
                                    )),
                                // if (_gift.validFrom.difference(DateTime(_now.year, _now.month, _now.day)).inDays >= 1) Text(DateFormat.yMMMd().format(_gift.validFrom))
                                // else const Text("Immediately"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Valid Until",
                                    style: _formHeadingTextStyle),
                                const SizedBox(height: 4.0),
                                InkWell(
                                  onTap: () async {
                                    // if (_tempSpecial!.validUntil == null) {
                                    //   _tempSpecial!.validUntil = DateTime(
                                    //     _tempSpecial!.validFrom.year,
                                    //     _tempSpecial!.validFrom.month,
                                    //     _tempSpecial!.validFrom.day,
                                    //     _tempSpecial!.validFrom.hour,
                                    //     _tempSpecial!.validFrom.minute,
                                    //   );}

                                    final tempTime = TimeOfDay.fromDateTime(
                                        _tempSpecial!.validUntil);
                                    final picked = await selectDate(
                                        _tempSpecial!.validUntil);

                                    if (picked != null &&
                                        picked != _tempSpecial!.validUntil) {
                                      setState(() {
                                        _tempSpecial!.validUntil = DateTime(
                                            picked.year,
                                            picked.month,
                                            picked.day,
                                            tempTime.hour,
                                            tempTime.minute);
                                        // _gift.validUntil = DateTime(_gift.validFrom.year, _gift.validFrom.month + _giftCard.validDurationMonth, _gift.validFrom.day, _gift.validFrom.hour, _gift.validFrom.minute);
                                        //print("valid from: ${_gift.validFrom} -- until ${_gift.validUntil}");
                                      });
                                    }

                                    if (_tempSpecial!.validUntil
                                        .isBefore(_tempSpecial!.validFrom)) {
                                      _tempSpecial!.validUntil =
                                          _tempSpecial!.validFrom;
                                    }
                                  },
                                  child: Text(
                                    DateFormat.yMMMd()
                                        .format(_tempSpecial!.validUntil),
                                    style: TextStyle(
                                        color: _tempSpecial!.status ==
                                                    SpecialStatus.pending &&
                                                (_tempSpecial!.validUntil
                                                        .isBefore(
                                                            DateTime.now()) ||
                                                    _tempSpecial!.validUntil ==
                                                        _tempSpecial!.validFrom)
                                            ? kColorError
                                            : Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                InkWell(
                                  onTap: () async {
                                    // if (_tempSpecial!.validUntil == null) {
                                    //   _tempSpecial!.validUntil = DateTime(
                                    //     _tempSpecial!.validFrom.year,
                                    //     _tempSpecial!.validFrom.month,
                                    //     _tempSpecial!.validFrom.day,
                                    //     _tempSpecial!.validFrom.hour,
                                    //     _tempSpecial!.validFrom.minute,
                                    //   );}

                                    final tempDate = _tempSpecial!.validUntil;
                                    final picked = await selectTime(
                                        TimeOfDay.fromDateTime(
                                            _tempSpecial!.validUntil));

                                    if (picked != null &&
                                        picked !=
                                            TimeOfDay.fromDateTime(
                                                _tempSpecial!.validUntil)) {
                                      setState(() {
                                        _tempSpecial!.validUntil = DateTime(
                                            tempDate.year,
                                            tempDate.month,
                                            tempDate.day,
                                            picked.hour,
                                            picked.minute);
                                        // _gift.validUntil = DateTime(_gift.validFrom.year, _gift.validFrom.month + _giftCard.validDurationMonth, _gift.validFrom.day, _gift.validFrom.hour, _gift.validFrom.minute);
                                        //print("valid from: ${_gift.validFrom} -- until ${_gift.validUntil}");
                                      });
                                    }

                                    if (_tempSpecial!.validUntil
                                        .isBefore(_tempSpecial!.validFrom)) {
                                      _tempSpecial!.validUntil =
                                          _tempSpecial!.validFrom;
                                    }
                                  },
                                  child: Text(
                                    DateFormat.Hm()
                                        .format(_tempSpecial!.validUntil),
                                    style: TextStyle(
                                        color: _tempSpecial!.status ==
                                                    SpecialStatus.pending &&
                                                (_tempSpecial!.validUntil
                                                        .isBefore(
                                                            DateTime.now()) ||
                                                    _tempSpecial!.validUntil ==
                                                        _tempSpecial!.validFrom)
                                            ? kColorError
                                            : Colors.white),
                                  ),
                                ),
                                // if (_gift.validFrom.difference(DateTime(_now.year, _now.month, _now.day)).inDays >= 1) Text(DateFormat.yMMMd().format(_gift.validFrom))
                                // else const Text("Immediately"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_tempSpecial!.uuid != "")
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _tempSpecial!.status ==
                                          SpecialStatus.pending ||
                                      _tempSpecial!.status ==
                                          SpecialStatus.active
                                  ? _toggleActivateSpecialButton()
                                  : const SizedBox(),
                            ),
                          ),
                        Expanded(
                            child: _selectedSpecial!.isUpdated(_tempSpecial!) &&
                                    _tempSpecial!.status ==
                                        SpecialStatus.pending
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: _tempSpecial!.uuid == ""
                                        ? _createSpecialButton()
                                        : _updateSpecialButton())
                                : const SizedBox()),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.centerRight, child: _deleteSpecialButton()),
        ],
      ),
    );
  }

  Future<DateTime?> selectDate(DateTime initDateTime) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initDateTime.isBefore(now) ? now : initDateTime,
        firstDate: now,
        lastDate: DateTime(
            initDateTime.year, initDateTime.month + 3, initDateTime.day));

    return picked;
  }

  Future<TimeOfDay?> selectTime(TimeOfDay initTime) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: initTime,
        // initialEntryMode: TimePickerEntryMode.input,
        builder: (context, childWidget) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  // Using 24-Hour format
                  alwaysUse24HourFormat: true),
              // If you want 12-Hour format, just change alwaysUse24HourFormat to false or remove all the builder argument
              child: childWidget!);
        });

    return picked;
  }

  bool checkSpecialFormStatus() {
    // if (_formKey.currentState!.validate()) return true
    return true;
  }

  final _specialsStatusActivateButtonStyle = ElevatedButton.styleFrom(
      primary: kColorActive,
      // side: BorderSide(color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)));
  final _specialsStatusActivateErrorButtonStyle = ElevatedButton.styleFrom(
      primary: kColorUpdateInactive,
      // side: BorderSide(color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)));
  final _specialsStatusDeactivateButtonStyle = TextButton.styleFrom(
      primary: kColorInactive,
      side: const BorderSide(color: kColorInactive),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)));
  final _specialsStatusUpdateButtonStyle = ElevatedButton.styleFrom(
      primary: kColorUpdate,
      // side: BorderSide(color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)));
  // final _specialsStatusUpdateInactiveButtonStyle = ElevatedButton.styleFrom(
  //     primary: kColorUpdateInactive,
  //     // side: BorderSide(color: color),
  //     shape:
  //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))
  // );
  Widget _toggleActivateSpecialButton() {
    Widget buttonContent;

    // Check if inactive on save
    if (_specialsViewModel.state == SpecialViewState.updatingStatus) {
      buttonContent = const SizedBox(
          height: 30.0,
          width: 30.0,
          child: Center(child: CircularProgressIndicator()));
    } else if (_tempSpecial!.status == SpecialStatus.inactive ||
        _tempSpecial!.status == SpecialStatus.pending) {
      _tempSpecial!.activatedAt = DateTime.now();

      final canActivate = !(_selectedSpecial!.isUpdated(_tempSpecial!) ||
          !_tempSpecial!.validUntil.isAfter(
              _tempSpecial!.validFrom.add(const Duration(minutes: 14))) ||
          _tempSpecial!.activatedAt!.isAfter(_tempSpecial!.validFrom) ||
          (_tempSpecial!.activatedAt!.isAfter(_tempSpecial!.validUntil)));

      buttonContent = SizedBox(
        width: 140.0,
        child: ElevatedButton.icon(
          onPressed: () async {
            if (_selectedSpecial!.isUpdated(_tempSpecial!)) {
              InfoSnackBar.show(
                  context, "Please save special before activating",
                  color: SnackBarColor.error);
              _tempSpecial!.activatedAt = null;
              return;
            }
            if (_tempSpecial!.activatedAt!.isAfter(_tempSpecial!.validFrom)) {
              InfoSnackBar.show(
                  context, "Valid from needs to be after current date & time",
                  color: SnackBarColor.error);
              _tempSpecial!.activatedAt = null;
              return;
            }
            if (_tempSpecial!.activatedAt!.isAfter(_tempSpecial!.validUntil)) {
              InfoSnackBar.show(
                  context, "Valid until cant be before current date & time",
                  color: SnackBarColor.error);
              _tempSpecial!.activatedAt = null;
              return;
            }
            if (!_tempSpecial!.validUntil.isAfter(
                _tempSpecial!.validFrom.add(const Duration(minutes: 14)))) {
              InfoSnackBar.show(context,
                  "Please set time Until to be at least 15min after valid from time",
                  color: SnackBarColor.error);
              return;
            }

            _tempSpecial!.status = SpecialStatus.active;
            if (!await _specialsViewModel
                .toggleSpecialActivate(_tempSpecial!)) {
              _tempSpecial!.activatedAt = null;
              _tempSpecial!.status = SpecialStatus.pending;
            } else {
              _showActivity = true;
            }

            setState(() {});
          },
          style: canActivate
              ? _specialsStatusActivateButtonStyle
              : _specialsStatusActivateErrorButtonStyle,
          icon: Icon(
            canActivate ? Icons.check : Icons.close,
            color: Colors.white,
          ),
          label: const Text(
            "Activate",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      buttonContent = SizedBox(
        width: 140.0,
        child: TextButton.icon(
          onPressed: () async {
            _tempSpecial!.activatedAt = null;
            _tempSpecial!.status = SpecialStatus.inactive;

            if (!await _specialsViewModel
                .toggleSpecialActivate(_tempSpecial!)) {
              _tempSpecial!.status = SpecialStatus.active;
            }

            setState(() {});
          },
          style: _specialsStatusDeactivateButtonStyle,
          icon: const Icon(
            Icons.check,
            color: kColorInactive,
          ),
          label: const Text(
            "Deactivate",
            style: TextStyle(color: kColorInactive),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40.0,
      width: 140.0,
      child: Center(child: buttonContent),
    );
  }

  Widget _updateSpecialButton() {
    Widget buttonContent;
    if (_specialsViewModel.state == SpecialViewState.uploading) {
      buttonContent = const SizedBox(
          height: 30.0,
          width: 30.0,
          child: Center(child: CircularProgressIndicator()));
      // } else if (_tempSpecial!.validFrom.isBefore(DateTime.now())) {       // TODO REMOVE AND AUTO CHANGE TIME TO NOW ON CREATE
      //   buttonContent =  ElevatedButton.icon(
      //     onPressed: () async {
      //       if (_tempSpecial!.validFrom.isBefore(DateTime.now())) {
      //         InfoSnackBar.show(context, "Please update date / time from to after now!", color: SnackBarColor.error);
      //         return;
      //       }
      //     },
      //     style: _specialsStatusUpdateInactiveButtonStyle,
      //     icon: const Icon(
      //       Icons.close,
      //       color: Colors.white,
      //     ),
      //     label: const Text(
      //       "Save",
      //       style: TextStyle(color: Colors.white),
      //     ),
      //   );
    } else {
      buttonContent = ElevatedButton.icon(
        onPressed: () async {
          // if (_tempSpecial!.status == SpecialStatus.active) {
          //   InfoSnackBar.show(context, "Please deactivate special before updating!", color: SnackBarColor.error);
          //   return;
          // }

          if (_tempSpecial!.imageUrl == "" && _tempSpecial!.image == null) {
            InfoSnackBar.show(
                context, "Please add an image for current special",
                color: SnackBarColor.error);
            return;
          }

          if (_formKey.currentState != null &&
              _formKey.currentState!.validate()) {
            if (await _specialsViewModel.updateSpecial(_tempSpecial!)) {
              _selectedSpecial = _tempSpecial!.copyWith();
              _tempSpecial = _tempSpecial!.copyWith();
            }
          }
        },
        style: _specialsStatusUpdateButtonStyle,
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ),
        label: const Text(
          "Save",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SizedBox(
      height: 40.0,
      width: 100,
      child: Center(child: buttonContent),
    );
  }

  Widget _createSpecialButton() {
    Widget buttonContent;
    if (_specialsViewModel.state == SpecialViewState.create) {
      buttonContent = const SizedBox(
          height: 30.0,
          width: 30.0,
          child: Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kColorUpdate),
            strokeWidth: 2,
          )));
    } else {
      buttonContent = ElevatedButton.icon(
        onPressed: () async {
          if (_tempSpecial!.image == null &&
              _tempSpecial!.imageUrl.isEmpty &&
              !_tempSpecial!.copied) {
            InfoSnackBar.show(
                context, "Please add an image for current special",
                color: SnackBarColor.error);
            return;
          }
          if (_formKey.currentState != null &&
              _formKey.currentState!.validate()) {
            final tempSpecial =
                await _specialsViewModel.createSpecial(_tempSpecial!);
            if (tempSpecial != null) {
              _tempSpecial = tempSpecial;
              _tempSpecial!.image = null;
              _selectedSpecial = _tempSpecial!.copyWith();
              setState(() {});
            }
          }
        },
        style: _specialsStatusUpdateButtonStyle,
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ),
        label: const Text(
          "Create",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SizedBox(
      height: 40.0,
      width: 110.0,
      child: Center(child: buttonContent),
    );
  }

  Widget _deleteSpecialButton() {
    Widget buttonContent;
    if (_specialsViewModel.state == SpecialViewState.deleting) {
      buttonContent = const SizedBox(
          height: 30.0,
          width: 30.0,
          child: Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kColorInactive),
            strokeWidth: 2,
          )));
    } else {
      buttonContent = TextButton.icon(
        onPressed: () async {
          await _specialsViewModel.deleteSpecial(_selectedSpecial!);
          _selectedSpecial = null;
          _tempSpecial = null;
          _showActivity = true;
          setState(() {});
        },
        icon: const Icon(
          Icons.delete_outline,
          color: kColorError,
        ),
        label: const Text(
          "Delete",
          style: TextStyle(color: kColorError),
        ),
      );
    }

    return SizedBox(
      height: 40.0,
      width: 130.0,
      child: Center(child: buttonContent),
    );
  }

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    _priceTextEditingController.dispose();
    _descriptionTextEditingController.dispose();
    super.dispose();
  }
}

class BroadcastMessageDialog extends StatefulWidget {
  const BroadcastMessageDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<BroadcastMessageDialog> createState() => _BroadcastMessageDialogState();
}

class _BroadcastMessageDialogState extends State<BroadcastMessageDialog> {
  final _messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Broadcast to all users"),
      content: TextField(
        decoration: const InputDecoration(
          hintText: "Message",
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kColorSecondaryText),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kColorAccent),
          ),
        ),
        onChanged: (_) => setState(() {}),
        autofocus: true,
        maxLines: null,
        controller: _messageTextController,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: kColorSecondaryText),
          ),
        ),
        TextButton(
          onPressed: _messageTextController.text.trim().isNotEmpty
              ? () =>
                  Navigator.of(context).pop(_messageTextController.text.trim())
              : null,
          child: Text(
            "Send",
            style: TextStyle(
                color: _messageTextController.text.trim().isNotEmpty
                    ? kColorAccent
                    : kColorSecondaryText),
          ),
        ),
      ],
    );
  }
}
