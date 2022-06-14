import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:findgo/core/constants.dart';
import 'package:findgo/data_models/store.dart';
import 'package:findgo/internal_services/routes.dart';
import 'package:findgo/main.dart';
import 'package:findgo/view_models/location_vm.dart';
import 'package:findgo/view_models/stores_vm.dart';
import 'package:findgo/view_pages/store_pg.dart';
import 'package:findgo/widgets/auth_scaffold.dart';
import 'package:findgo/widgets/bottom_nav.dart';
import 'package:findgo/widgets/loading.dart';
import 'package:findgo/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vrouter/vrouter.dart';

class MapPage extends ConsumerStatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  late final LocationViewModel _locationVM;
  late final StoresViewModel _storeVM;
  // late final SpecialsViewModel _specialsVM;
  late CameraPosition _cameraLocation;
  bool _initComplete = false;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Set<Marker> _clMarkers = {};
  late ClusterManager _manager;

  late final GoogleMapController _googleMapController;
  final Completer<GoogleMapController> _mapController = Completer();

  Iterable<Store> _stores = <Store>[];
  bool _showStoreIcons = false;
  // final _kZoomIconLvl = 15.5;
  final _kZoomIconLvl = 13.5;

  // static Future<BitmapDescriptor> fromAsset({
  //   String name = "",
  //   double size = 130,
  // }) async {
  //   final pictureRecorder = ui.PictureRecorder();
  //   final canvas = Canvas(pictureRecorder);
  //
  //   // INFO: Asset
  //   final radSize = Size.fromRadius(size / 2);
  //   final imageFile = await rootBundle.load("assets/icons/logo.png");
  //   final imageUInt8List = imageFile.buffer.asUint8List();
  //   final ui.Codec codec = await ui.instantiateImageCodec(imageUInt8List);
  //   final ui.FrameInfo imageFI = await codec.getNextFrame();
  //   paintImage(
  //     fit: BoxFit.contain,
  //     canvas: canvas,
  //     rect: Rect.fromLTWH(0, 0, radSize.width, radSize.height),
  //     image: imageFI.image,
  //   );
  //
  //   // INFO: Text
  //   final textPainter = TextPainter(textDirection: TextDirection.ltr);
  //   const length = 11;
  //   if (name.length > length) name = "${name.substring(0, length - 3)}...";
  //   textPainter.text = TextSpan(
  //     text: name,
  //     style: const TextStyle(
  //       overflow: TextOverflow.visible,
  //       fontSize: 24,
  //       color: Colors.black,
  //       fontWeight: FontWeight.bold,
  //       backgroundColor: Colors.white,
  //     ),
  //   );
  //   textPainter.textAlign = TextAlign.center;
  //   textPainter.layout();
  //   textPainter.paint(canvas, Offset.zero);
  //
  //   // INFO: Create Marker
  //   final picture = pictureRecorder.endRecording();
  //   final image = await picture.toImage(size.round(), size.round());
  //   final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  //   return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  // }
  //
  // static Future<BitmapDescriptor> fromIcon({
  //   String name = "",
  //   IconData icon = Icons.location_on_rounded,
  //   Color color = Colors.red,
  //   double size = 140,
  // }) async {
  //   final pictureRecorder = ui.PictureRecorder();
  //   final canvas = Canvas(pictureRecorder);
  //
  //   // INFO: Icon
  //   final iconPainter = TextPainter(textDirection: TextDirection.ltr);
  //   iconPainter.text = TextSpan(
  //     text: String.fromCharCode(icon.codePoint),
  //     style: TextStyle(
  //       letterSpacing: 0.0,
  //       fontSize: size,
  //       fontFamily: icon.fontFamily,
  //       package: icon.fontPackage,
  //       color: color,
  //     ),
  //   );
  //   iconPainter.layout();
  //   iconPainter.paint(canvas, Offset.zero);
  //
  //   // INFO: Text
  //   final textPainter = TextPainter(textDirection: TextDirection.ltr);
  //   const length = 11;
  //   if (name.length > length) name = "${name.substring(0, length - 3)}...";
  //   textPainter.text = TextSpan(
  //     text: name,
  //     style: const TextStyle(
  //       overflow: TextOverflow.visible,
  //       fontSize: 24,
  //       color: Colors.black,
  //       fontWeight: FontWeight.bold,
  //       backgroundColor: Colors.white,
  //     ),
  //   );
  //   textPainter.textAlign = TextAlign.center;
  //   textPainter.layout();
  //   textPainter.paint(canvas, Offset.zero);
  //
  //   // INFO: Create Marker
  //   final picture = pictureRecorder.endRecording();
  //   final image = await picture.toImage(size.round(), size.round());
  //   final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  //   return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  // }

  // static Future<BitmapDescriptor> downloadResizePictureCircle(
  //     String imageUrl, {
  //       int size = 150,
  //       bool addBorder = false,
  //       Color borderColor = Colors.white,
  //       double borderSize = 10,
  //       String name = "",
  //       IconData icon = Icons.location_on_rounded,
  //       Color color = Colors.red,
  //     }) async {
  //   final File imageFile = await DefaultCacheManager().getSingleFile(imageUrl);
  //
  //   final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   final Paint paint = Paint()..color;
  //
  //   final double radius = size / 2;
  //
  //   //make canvas clip path to prevent image drawing over the circle
  //   final Path clipPath = Path();
  //   clipPath.addRRect(RRect.fromRectAndRadius(
  //       Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  //       Radius.circular(100)));
  //   /* clipPath.addRRect(RRect.fromRectAndRadius(
  //       Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
  //       Radius.circular(100))); */
  //   canvas.clipPath(clipPath);
  //
  //   // INFO: Icon
  //   final iconPainter = TextPainter(textDirection: TextDirection.ltr);
  //   iconPainter.text = TextSpan(
  //     text: String.fromCharCode(icon.codePoint),
  //     style: TextStyle(
  //       letterSpacing: 0.0,
  //       fontSize: size.toDouble(),
  //       fontFamily: icon.fontFamily,
  //       package: icon.fontPackage,
  //       color: color,
  //     ),
  //   );
  //   iconPainter.layout();
  //   iconPainter.paint(canvas, Offset.zero);
  //
  //   //paintImage
  //   final Uint8List imageUint8List = await imageFile.readAsBytes();
  //   final ui.Codec codec = await ui.instantiateImageCodec(imageUint8List);
  //   final ui.FrameInfo imageFI = await codec.getNextFrame();
  //   paintImage(
  //       fit: BoxFit.fill,
  //       alignment: Alignment.center,
  //       canvas: canvas,
  //       rect: Rect.fromCircle(radius: 40, center: Offset(75, 60)),
  //       image: imageFI.image);
  //
  //
  //   //convert canvas as PNG bytes
  //   final _image = await pictureRecorder
  //       .endRecording()
  //       .toImage(size, (size * 1.1).toInt());
  //   final data = await _image.toByteData(format: ui.ImageByteFormat.png);
  //
  //   //convert PNG bytes as BitmapDescriptor
  //   return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  // }

  Future<void> _createStoreMarkers(String? storeUuid) async {
    // if (usrLoc != null) {
    //   const MarkerId markerId = MarkerId("me");
    //   final Marker marker = Marker(
    //     markerId: markerId,
    //     position: LatLng(usrLoc, usrLoc),
    //     infoWindow: const InfoWindow(title: "Me", snippet: 'You are here'),
    //     onTap: () {},
    //     icon: await MarkerIcon.circleCanvasWithText(
    //       size: const Size.fromRadius(60.0),
    //       text: "You",
    //       fontSize: 30,
    //       circleColor: kColorAccent,
    //     ),
    //   );
    //   markers[markerId] = marker;
    // }

    // _storeVM.storesList.add(_storeVM.storesList.first.copyWith(
    //     uuid: "2",
    //     latLng: ll.LatLng(lat: -29.7381408, lng: 31.07363889999999)));
    // _storeVM.storesList.add(_storeVM.storesList.first.copyWith(
    //     uuid: "1",
    //     latLng: ll.LatLng(lat: -29.7371408, lng: 31.07363889999999)));
    _stores = _storeVM.storesList.where((store) => store.latLng.isNotNil);
    if (storeUuid != null) {
      _stores = _stores.where((store) => store.uuid == storeUuid);
    }

    // print("Stores $_stores");
    for (final store in _stores) {
      // print("${store.name} ${store.latLng.isNil} : lat: ${store.latLng.lat} lng: ${store.latLng.lng}");

      // if (store.latLng.isNil) continue;

      // final hasSpecial =
      //     _specialsVM.specialsList.any((s) => s.storeUuid == store.uuid);

      // final BitmapDescriptor mkr = hasSpecial
      //     ? await fromAsset(name: store.name)
      //     // ? await downloadResizePictureCircle(store.imageUrl)
      //     : await fromIcon(
      //         name: store.name,
      //         color: Colors.grey.withOpacity(0.4),
      //       );

      final BitmapDescriptor mkr = await MarkerIcon.downloadResizePictureCircle(
        store.imageUrl,
        size: 100,
        borderColor: Colors.black,
        addBorder: true,
        borderSize: 5,
      );

      final MarkerId markerId = MarkerId(store.uuid);
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(store.latLng.lat!, store.latLng.lng!),
        // infoWindow: InfoWindow(title: store.name, snippet: store.streetAddress),
        onTap: () {
          _selectedStore = store;
          setState(() {});
        },
        icon: mkr,
      );
      markers[markerId] = marker;
    }

    setState(() {});
  }

  Future<void> _updateMarkers(Set<Marker> markers) async {
    // print('Updated ${markers.length} markers');
    // print(await _googleMapController.getZoomLevel());
    final lvl = await _googleMapController.getZoomLevel();
    setState(() {
      if (lvl >= _kZoomIconLvl || _stores.length <= 1) {
        _showStoreIcons = true;
      } else {
        _showStoreIcons = false;
      }
      _clMarkers = markers;
    });
  }

  Future<Marker> Function(Cluster<Store>) get _markerBuilder =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          infoWindow: cluster.isMultiple
              ? InfoWindow.noText
              : InfoWindow(title: cluster.items.first.name),
          onTap: () {
            if (cluster.count == 1) _selectedStore = cluster.items.first;
            setState(() {});
          },
          icon: await _getMarkerBitmap(
            cluster.isMultiple ? 125 : 75,
            text: cluster.isMultiple ? cluster.count.toString() : null,
          ),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = kColorAccent;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      final painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size / 3,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  @override
  void initState() {
    _storeVM = ref.read(storesVMProvider);
    // _specialsVM = ref.read(specialsVMProvider);
    _locationVM = ref.read(locationVMProvider);

    // Do after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _locationVM.context = context;
      // if (_locationVM.latLng.isNil &&
      //  if (!await _locationVM.fetchCurrentPosition()) return;
      await _locationVM.fetchCurrentPosition();

      // Set init camera position
      final usrLoc = _locationVM.latLng;
      if (_locationVM.showUserLoc) {
        _cameraLocation = CameraPosition(
          target: LatLng(usrLoc.lat!, usrLoc.lng!),
          zoom: 12.0,
        );
        // await _createStoreMarkers(LatLng(usrLoc.lat!, usrLoc.lng!));
      } else {
        _cameraLocation = const CameraPosition(
          target: LatLng(-29, 31),
          zoom: 5.0,
        );
        // await _createStoreMarkers(null);
      }
      final storeUuid = context.vRouter.pathParameters["storeUuid"];
      await _createStoreMarkers(storeUuid);

      final store =
          _stores.firstWhereOrNull((store) => store.uuid == storeUuid);
      if (store != null) {
        _stores = [store];
        _selectedStore = store;

        _cameraLocation = CameraPosition(
          target: LatLng(store.latLng.lat!, store.latLng.lng!),
          zoom: _kZoomIconLvl,
        );
      }

      _manager = ClusterManager<Store>(
        _stores,
        _updateMarkers,
        markerBuilder: _markerBuilder,

        // levels: [1, 4.25, 9.7, 11.5, _kZoomIconLvl],
        // stopClusteringZoom: _kZoomIconLvl - 2, // TODO: MAYBE PUT BACK
        stopClusteringZoom: _kZoomIconLvl,
      );

      _initComplete = true;
      // setState(() {});
    });
    super.initState();
  }

  Store? _selectedStore;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AuthScaffold(
        body: Consumer(
          builder: (context, ref, child) {
            // final networkVM = ref.watch(networkVMProvider);
            // final themeVM = ref.watch(themeVMProvider);
            ref.watch(networkVMProvider);
            ref.watch(themeVMProvider);
            final locationVM = ref.watch(locationVMProvider);

            if (locationVM.busy || !_initComplete) return LoadWidget();
            if (locationVM.noPermission) {
              return const Center(
                child: Text("No Permission Granted"),
              );
            }
            // print(_selectedStore);
            return Stack(
              children: [
                GoogleMap(
                  onTap: (_) => _selectedStore != null
                      ? setState(() => _selectedStore = null)
                      : null,
                  //mapType: MapType.hybrid,
                  myLocationEnabled: true,
                  mapToolbarEnabled: false,
                  initialCameraPosition: _cameraLocation,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                    _googleMapController = controller;
                    _googleMapController.setMapStyle(
                      jsonEncode([
                        {
                          "featureType": "poi",
                          "stylers": [
                            {"visibility": "off"}
                          ]
                        }
                      ]),
                    );
                    _manager.setMapId(controller.mapId);
                  },
                  onCameraMove: _manager.onCameraMove,
                  onCameraIdle: _manager.updateMap,
                  // markers: Set<Marker>.of(markers.values),
                  markers: _showStoreIcons
                      ? Set<Marker>.of(markers.values)
                      : _clMarkers,
                ),
                if (_selectedStore != null)
                  _StoreInfoCard(
                    selectedStore: _selectedStore!,
                    locationVM: _locationVM,
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      ),
    );
  }
}

class _StoreInfoCard extends StatelessWidget {
  const _StoreInfoCard({
    Key? key,
    required Store selectedStore,
    required LocationViewModel locationVM,
  })  : _selectedStore = selectedStore,
        _locationVM = locationVM,
        super(key: key);

  final Store _selectedStore;
  final LocationViewModel _locationVM;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: () => Routes.push(context, StorePage(store: _selectedStore)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 16.0,
                    ),
                    CircleAvatar(
                      radius: 21.0,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        // backgroundImage: NetworkImage(special.storeImageUrl)),
                        backgroundImage:
                            CachedNetworkImageProvider(_selectedStore.imageUrl),
                      ),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedStore.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_selectedStore.category != "")
                          Text(
                            _selectedStore.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        // SizedBox(width: 16.0,),
                      ],
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                  ],
                ),
                if (_selectedStore.description.isNotEmpty)
                  const SizedBox(
                    height: 16.0,
                  ),
                if (_selectedStore.description.isNotEmpty)
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                if (_selectedStore.description.isNotEmpty)
                  const SizedBox(
                    height: 4.0,
                  ),
                if (_selectedStore.description.isNotEmpty)
                  Text(
                    _selectedStore.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                if (_selectedStore.streetAddress.isNotEmpty)
                  const SizedBox(
                    height: 16.0,
                  ),
                if (_selectedStore.streetAddress.isNotEmpty)
                  const Text(
                    "Street Address",
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                if (_selectedStore.streetAddress.isNotEmpty)
                  const SizedBox(
                    height: 4.0,
                  ),
                if (_selectedStore.streetAddress.isNotEmpty)
                  Text(
                    _selectedStore.streetAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      // fontStyle: FontStyle.italic,
                    ),
                  ),
                if (_locationVM.latLng.isNotNil &&
                    _selectedStore.latLng.isNotNil)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _locationVM
                            .getDistanceBetweenAsString(_selectedStore.latLng),
                        style: const TextStyle(
                          // fontSize: 16,
                          fontWeight: FontWeight.bold,
                          // fontStyle: FontStyle.italic,
                        ),
                        // textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final originLat = _locationVM.latLng.lat;
                          final originLng = _locationVM.latLng.lng;
                          final destLat = _selectedStore.latLng.lat;
                          final destLng = _selectedStore.latLng.lng;

                          String _url =
                              "https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng";
                          if (Platform.isIOS) {
                            _url =
                                "http://maps.apple.com/maps?saddr=$originLat,$originLng&daddr=$destLat,$destLng";
                          }

                          await canLaunchUrlString(_url)
                              ? await launchUrlString(_url)
                              : InfoSnackBar.show(
                                  context,
                                  "Error showing directions!",
                                  color: SnackBarColor.error,
                                );
                        },
                        icon: const Icon(Icons.location_pin),
                        label: const Text("Directions"),
                      ),
                    ],
                  ),
                if (_locationVM.latLng.isNil) const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
