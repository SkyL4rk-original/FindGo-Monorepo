import 'package:cached_network_image/cached_network_image.dart';
import 'package:findgo/data_models/store.dart';
import 'package:findgo/view_pages/image_pg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vrouter/vrouter.dart';

import '../core/constants.dart';
import '../data_models/special.dart';
import '../main.dart';
import '../widgets/snackbar.dart';

class SpecialPage extends StatefulWidget {
  final Special special;
  const SpecialPage({Key? key, required this.special}) : super(key: key);
  @override
  _SpecialPageState createState() => _SpecialPageState();
}

class _SpecialPageState extends State<SpecialPage> {
  // late SpecialsViewModel _specialsViewModel;
  late Special _special;
  String? distance;
  late Store _store;

  @override
  void initState() {
    final _specialsViewModel = context.read(specialsVMProvider);
    _special = widget.special;

    final storeVM = context.read(storesVMProvider);
    _store = storeVM.storesList
        .firstWhere((store) => store.uuid == _special.storeUuid);

    // Do after build
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final locationVM = context.read(locationVMProvider);
      if (locationVM.latLng.isNil) await locationVM.fetchCurrentPosition();
      final latLng = _store.latLng;
      if (latLng.isNotNil) {
        distance = locationVM.getDistanceBetweenAsString(latLng);
      }
      setState(() {});
      // MAYBE USE IF NEED FOR V_ROUTER
      // if (_special == null) {
      //   final specialUuid = context.vRouter.pathParameters["uuid"];
      //   print("specialUuid: $specialUuid");
      //   if (specialUuid == null) {
      //     context.vRouter.pushReplacement(
      //       context.vRouter.previousUrl ?? "/");
      //   }
      //
      //   // Check if special not in specials list download new special list
      //   if (!_specialsViewModel.specialsList.any((special) =>
      //   special.uuid == specialUuid)) await _specialsViewModel.getAllSpecials();
      //   // Check if special not in specials list again redirect to last url or home
      //   if (!_specialsViewModel.specialsList.any((special) =>
      //   special.uuid == specialUuid)) {
      //     context.vRouter.pushReplacement(
      //       context.vRouter.previousUrl ?? "/");
      //   }
      //   // If special found
      //   _special =
      //       _specialsViewModel.specialsList.firstWhere((special) => special
      //           .uuid == specialUuid);
      //   setState(() {});
      // }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kColorBackground,
      body: Consumer(builder: (context, watch, child) {
        final themeVM = watch(themeVMProvider);
        final specialsVM = watch(specialsVMProvider);
        specialsVM.context = context;

        final saved = specialsVM.savedSpecialsUuidSet
            .any((uuid) => uuid == _special.uuid);

        return SafeArea(
            // child: _special == null ? const CircularProgressIndicator() : SizedBox(
            child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Card(
                color: themeVM.mode == ThemeMode.dark
                    ? kColorBackgroundDark
                    : Colors.white,
                margin: EdgeInsets.zero,
                child: ListView(
                  children: [
                    if (_special.imageUrl == "")
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: SizedBox(
                            width: double.infinity,
                            child: Image.asset(
                              "assets/icons/logo.png",
                              height: 100.0,
                            )),
                      )
                    else
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (ctx) =>
                                      ImagePage(imageUrl: _special.imageUrl))),
                          child: CachedNetworkImage(
                              imageUrl: _special.imageUrl,
                              fit: BoxFit.fitWidth),
                        ),
                      ),
                    _cardContent(),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  } else {
                    context.vRouter.to("/", isReplacement: true);
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 12, top: 12),
                  color: themeVM.mode == ThemeMode.dark
                      ? kColorBackgroundDark
                      : Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (_special.storePhoneNumber != "")
                        InkWell(
                          onTap: () async {
                            final tel =
                                "tel:${_special.storePhoneNumber.trim()}";

                            // await canLaunch(tel) ? await launch(tel) : print('Could not launch $tel');
                            try {
                              specialsVM.addSpecialStatIncrement(
                                  _special.uuid, SpecialStat.phoneClick);
                              await launch(tel);
                            } catch (e) {
                              InfoSnackBar.show(context,
                                  "Error trying to call ${_special.storePhoneNumber}",
                                  color: SnackBarColor.error);
                              print(e);
                            }
                          },
                          // onTap: () => context.vRouter.pushExternal("tel:${_special!.storePhoneNumber}"),
                          child: Column(
                            children: [
                              const Icon(Icons.phone, color: kColorAccent),
                              const SizedBox(height: 8.0),
                              const Text("Call",
                                  style: TextStyle(
                                      color: kColorAccent, fontSize: 12.0)),
                            ],
                          ),
                        ),
                      InkWell(
                        onTap: () async {
                          // Download image to a file
                          specialsVM.addSpecialStatIncrement(
                              _special.uuid, SpecialStat.shareClick);
                          final file = await DefaultCacheManager()
                              .getSingleFile(_special.imageUrl);
                          Share.shareFiles([file.path],
                              text:
                                  "${_special.storeName}\n${_special.name}\n\nFind out more click: https://findgo.co.za/admin/#/special?uid=${_special.uuid}"
                              // "Special @ ${_special!.storeName} : ${_special!.name} \n ${_special!.imageUrl}",
                              // subject: "subject",

                              );

                          // DefaultCacheManager().emptyCache();
                        },
                        child: Column(
                          children: [
                            const Icon(Icons.share, color: kColorAccent),
                            const SizedBox(height: 8.0),
                            const Text("Share",
                                style: TextStyle(
                                    color: kColorAccent, fontSize: 12.0)),
                          ],
                        ),
                      ),
                      if (_special.storeWebsite != "")
                        InkWell(
                          onTap: () async {
                            try {
                              specialsVM.addSpecialStatIncrement(
                                  _special.uuid, SpecialStat.websiteClick);
                              await launch(_special.storeWebsite);
                            } catch (e) {
                              InfoSnackBar.show(context,
                                  "Error opening ${_special.storeWebsite}",
                                  color: SnackBarColor.error);
                              print(e);
                            }
                          },
                          //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
                          child: Column(
                            children: [
                              const Icon(Icons.web, color: kColorAccent),
                              const SizedBox(height: 8.0),
                              const Text("Website",
                                  style: TextStyle(
                                      color: kColorAccent, fontSize: 12.0)),
                            ],
                          ),
                        ),
                      if (saved)
                        InkWell(
                          onTap: () async {
                            await specialsVM.saveSpecial(
                                specialUuid: _special.uuid, save: false);
                            setState(() {});
                          },
                          //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
                          child: Column(
                            children: [
                              const Icon(Icons.bookmark_outlined,
                                  color: kColorAccent),
                              const SizedBox(height: 8.0),
                              const Text(" Saved",
                                  style: TextStyle(
                                      color: kColorAccent, fontSize: 12.0)),
                            ],
                          ),
                        )
                      else
                        InkWell(
                          onTap: () async {
                            specialsVM.addSpecialStatIncrement(
                                _special.uuid, SpecialStat.savedClick);
                            await specialsVM.saveSpecial(
                                specialUuid: _special.uuid, save: true);
                            setState(() {});
                          },
                          //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
                          child: Column(
                            children: [
                              const Icon(Icons.bookmark_border,
                                  color: kColorAccent),
                              const SizedBox(height: 8.0),
                              const Text(" Save ",
                                  style: TextStyle(
                                      color: kColorAccent, fontSize: 12.0)),
                            ],
                          ),
                        ),
                      if (_store.latLng.isNotNil)
                        InkWell(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            context.vRouter.to("/map/${_store.uuid}");
                          },
                          //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                color: kColorAccent,
                              ),
                              const SizedBox(height: 8.0),
                              const Text(
                                " Map ",
                                style: TextStyle(
                                  color: kColorAccent,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
      }),
    );
  }

  Widget _cardContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                  backgroundColor: Colors.transparent,
                  // backgroundImage: NetworkImage(_special.storeImageUrl)
                  backgroundImage:
                      CachedNetworkImageProvider(_special.storeImageUrl)),
              Expanded(
                child: Container(
                  // color: Colors.red,
                  color: Colors.transparent,
                  height: 32,
                  child: const Divider(
                    indent: 50.0,
                    endIndent: 70.0,
                    color: kColorCardDark,
                    thickness: 2.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          SizedBox(
              child: Text(_special.name.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 32.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center)),
          const SizedBox(
            height: 36.0,
          ),
          Text(_special.storeName,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
          if (_special.storeCategory != "")
            const SizedBox(
              height: 4.0,
            ),
          if (_special.storeCategory != "")
            Text(_special.storeCategory,
                style: const TextStyle(fontStyle: FontStyle.italic),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
          if (distance != null)
            const SizedBox(
              height: 4.0,
            ),
          if (distance != null)
            Text(distance!,
                style: const TextStyle(fontStyle: FontStyle.italic),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
          if (_special.price != 0)
            const SizedBox(
              height: 24.0,
            ),
          if (_special.price != 0)
            Text("R ${(_special.price / 100).toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          const SizedBox(
            height: 24.0,
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                        child: Text("From:",
                            style: kTextStyleSmallSecondary,
                            textAlign: TextAlign.end)),
                    Expanded(
                      flex: 3,
                      child: Text(
                          DateFormat.E().add_yMMMd().format(_special.validFrom),
                          textAlign: TextAlign.end),
                    ),
                    const SizedBox(width: 30.0),
                    Expanded(
                      flex: 2,
                      child: Text(DateFormat.jm().format(_special.validFrom),
                          textAlign: TextAlign.start),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: [
                    const Expanded(
                        child: Text("Until:",
                            style: kTextStyleSmallSecondary,
                            textAlign: TextAlign.end)),
                    Expanded(
                      flex: 3,
                      child: Text(
                          DateFormat.E()
                              .add_yMMMd()
                              .format(_special.validUntil!),
                          textAlign: TextAlign.end),
                    ),
                    const SizedBox(width: 30.0),
                    Expanded(
                      flex: 2,
                      child: Text(DateFormat.jm().format(_special.validUntil!),
                          textAlign: TextAlign.start),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 42.0,
          ),
          const Text("Description & Terms",
              style: kTextStyleSmallSecondary, textAlign: TextAlign.center),
          const SizedBox(
            height: 8.0,
          ),
          Text(_special.description, style: const TextStyle(fontSize: 14)),
          const SizedBox(
            height: 24.0,
          ),
          // if (_special!.type == SpecialType.discount) SizedBox(
          //   height: 200.0,
          //   width: 200.0,
          //   child: BarcodeWidget(
          //     padding: const EdgeInsets.all(12.0),
          //     height: 200,
          //     width: 200,
          //     barcode: Barcode.qrCode(),
          //     data: _special!.uuid,
          //     backgroundColor: Colors.white,
          //   ),
          // ),
          const SizedBox(
            height: 80.0,
          ),
        ],
      ),
    );
  }
}
