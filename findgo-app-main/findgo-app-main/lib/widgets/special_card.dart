import 'package:cached_network_image/cached_network_image.dart';
import 'package:findgo/core/constants.dart';
import 'package:findgo/data_models/special.dart';
import 'package:findgo/data_models/store.dart';
import 'package:findgo/internal_services/routes.dart';
import 'package:findgo/main.dart';
import 'package:findgo/view_models/location_vm.dart';
import 'package:findgo/view_models/specials_vm.dart';
import 'package:findgo/view_pages/image_pg.dart';
import 'package:findgo/view_pages/special_pg.dart';
import 'package:findgo/view_pages/store_pg.dart';
import 'package:findgo/widgets/snackbar.dart';
import 'package:findgo/widgets/util_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vrouter/vrouter.dart';

class SpecialCard extends ConsumerStatefulWidget {
  final Special special;

  const SpecialCard({Key? key, required this.special}) : super(key: key);

  @override
  _SpecialCardState createState() => _SpecialCardState();
}

class _SpecialCardState extends ConsumerState<SpecialCard> {
  late final Special _special;
  late final Store _store;
  late final SpecialsViewModel _specialsViewModel;
  late final LocationViewModel _locationVM;

  @override
  void initState() {
    _special = widget.special;
    _specialsViewModel = ref.read(specialsVMProvider);
    final storesViewModel = ref.read(storesVMProvider);
    _store = storesViewModel.storesList
        .firstWhere((store) => store.uuid == _special.storeUuid);
    _locationVM = ref.read(locationVMProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(special.name);
    //specialsVM.addSpecialStatIncrement(special.uuid, SpecialStat.impression);
    return Consumer(
      builder: (context, ref, _) {
        final themeVM = ref.watch(themeVMProvider);

        return GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
            _specialsViewModel.addSpecialStatIncrement(
              _special.uuid,
              SpecialStat.click,
            );
            Routes.push(context, SpecialPage(special: _special));
//           print("special_store: ${_special.storeUuid} ${_special.storeName}");
//           print("store: ${_store.uuid} ${_store.name}\n");
          },
          child: Card(
            color: themeVM.mode == ThemeMode.dark
                ? kColorCardDark
                : kColorCardLight,
            elevation: 4,
            // margin: const EdgeInsets.symmetric(vertical: 12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    children: [
                      InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () async =>
                            Routes.push(context, StorePage(store: _store)),
                        // onTap: () async => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => StorePage(store: store))),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 16.0,
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              // backgroundImage: NetworkImage(special.storeImageUrl)),
                              backgroundImage: CachedNetworkImageProvider(
                                _special.storeImageUrl,
                              ),
                            ),

                            const SizedBox(
                              width: 16.0,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _special.storeName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_special.storeCategory != "")
                                    Text(
                                      _special.storeCategory,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            // if (special.type == SpecialType.discount) InkWell(
                            //     hoverColor: Colors.transparent,
                            //     splashColor: Colors.transparent,
                            //     onTap: () async => Routes.push(context, SpecialPage(special: special)),
                            //     child: const Icon(Icons.qr_code)
                            // ),
                            if (_special.typeSet.contains(SpecialType.featured))
                              Container(
                                color: kColorAccent,
                                // decoration: BoxDecoration(
                                //   border: Border.all(color: kColorAccent),
                                //   borderRadius: BorderRadius.circular(10.0),
                                // ),
                                padding: const EdgeInsets.all(6.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 4.0,
                                    ),
                                    const Text(
                                      "Featured",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              )
                            else if (_special.activatedAt.isAfter(
                              DateTime.now().subtract(const Duration(days: 1)),
                            ))
                              Container(
                                color: Colors.green,
                                // decoration: BoxDecoration(
                                //   border: Border.all(color: kColorAccent),
                                //   borderRadius: BorderRadius.circular(10.0),
                                // ),
                                padding: const EdgeInsets.all(6.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 4.0,
                                    ),
                                    const Text(
                                      "New",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              )
                            else if (_special.validFrom.isAfter(DateTime.now()))
                              Container(
                                color: kColorError,
                                // decoration: BoxDecoration(
                                //   border: Border.all(color: kColorAccent),
                                //   borderRadius: BorderRadius.circular(10.0),
                                // ),
                                padding: const EdgeInsets.all(6.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 4.0,
                                    ),
                                    const Text(
                                      "Coming Soon",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),

                            // TODO put back for reporting
                            // PopupMenuButton(
                            //   itemBuilder: (BuildContext bc) => [
                            //     const PopupMenuItem(value: "/report", child: Text("Report")),
                            //   ],
                            //   onSelected: (route) {
                            //     print(route);
                            //     // Note You must create respective pages for navigation
                            //     //Navigator.pushNamed(context, route);
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      if (_special.imageUrl != "") const SizedBox(height: 16.0),
                      if (_special.imageUrl != "")
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  ImagePage(imageUrl: _special.imageUrl),
                            ),
                          ),
                          child: SizedBox(
                            // height: constraints.maxWidth * 0.8,
                            width: constraints.maxWidth,
                            child: CachedNetworkImage(
                              imageUrl: _special.imageUrl,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(child: Icon(Icons.error)),
                              fit: BoxFit.fitWidth,
                              // alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _actionRow(),
                            const SizedBox(height: 8.0),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                _special.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_special.price > 0)
                                  Text(
                                    "R ${(_special.price / 100).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (_special.price > 0)
                                  const SizedBox(
                                    height: 16.0,
                                  ),
                                Text(
                                  DateFormat.E()
                                      .add_yMMMd()
                                      .add_jm()
                                      .format(_special.validFrom),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                if (_special.validUntil != null &&
                                    _special.validUntil!.year > 2020)
                                  Text(
                                    "Until  ${DateFormat.E().add_yMMMd().add_jm().format(_special.validUntil!)}",
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                if (_locationVM.latLng.isNotNil &&
                                    _store.latLng.isNotNil)
                                  Text(
                                    "Distance: ${_locationVM.getDistanceBetweenAsString(_store.latLng)}",
                                    style: const TextStyle(fontSize: 10),
                                  ),
                              ],
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: DescriptionWidget(
                                text: _special.description.trim(),
                              ),
                            ),
                            // const SizedBox(height: 32.0,),
                          ],
                        ),
                      )
                      // const Divider(
                      //   indent: 50.0,
                      //   endIndent: 50.0,
                      //   color: kColorCard,
                      //   thickness: 2.0,
                      // ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _actionRow() {
    final saved = _specialsViewModel.savedSpecialsUuidSet
        .any((uuid) => uuid == _special.uuid);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          splashRadius: 20,
          onPressed: () async {
            FocusScope.of(context).unfocus();
            _specialsViewModel.addSpecialStatIncrement(
              _special.uuid,
              SpecialStat.click,
            );
            Routes.push(context, SpecialPage(special: _special));
          },
          // onTap: () => context.vRouter.pushExternal("tel:${_special!.storePhoneNumber}"),
          icon: const Icon(Icons.info_outline_rounded),
        ),
        if (_special.storePhoneNumber != "")
          IconButton(
            splashRadius: 20,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              final tel = "tel:${_special.storePhoneNumber.trim()}";
              print(tel);
              // await canLaunch(tel) ? await launch(tel) : print('Could not launch $tel');
              try {
                // _specialsViewModel.addSpecialStatIncrement(_special.uuid, SpecialStat.phoneClick);
                final uri =
                    Uri(scheme: "tel", path: _special.storePhoneNumber.trim());
                await launchUrl(uri);
                // await launchUrl("tel:${_special.storePhoneNumber.trim()}");
              } catch (e) {
                InfoSnackBar.show(
                  context,
                  "Error trying to call ${_special.storePhoneNumber}",
                  color: SnackBarColor.error,
                );
                print(e);
              }
            },
            // onTap: () => context.vRouter.pushExternal("tel:${_special!.storePhoneNumber}"),
            icon: const Icon(Icons.phone),
          ),
        IconButton(
          splashRadius: 20,
          onPressed: () async {
            FocusScope.of(context).unfocus();
            // Download image to a file
            _specialsViewModel.addSpecialStatIncrement(
              _special.uuid,
              SpecialStat.shareClick,
            );
            final file =
                await DefaultCacheManager().getSingleFile(_special.imageUrl);

            // final fileInfo = await DefaultCacheManager().downloadFile(_special.imageUrl);
            Share.shareFiles(
              [file.path],
              text:
                  "${_special.storeName}\n${_special.name}\n\nFind out more click: https://findgo.co.za/admin/#/special?uid=${_special.uuid}",
              // "Special @ ${_special!.storeName} : ${_special!.name} \n ${_special!.imageUrl}",
              // subject: "subject",
            );
            // DefaultCacheManager().emptyCache();
          },
          icon: const Icon(Icons.share),
        ),
        if (_special.storeWebsite != "")
          IconButton(
            splashRadius: 20,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              try {
                _specialsViewModel.addSpecialStatIncrement(
                  _special.uuid,
                  SpecialStat.websiteClick,
                );
                await launchUrlString(_special.storeWebsite);
              } catch (e) {
                InfoSnackBar.show(
                  context,
                  "Error opening ${_special.storeWebsite}",
                  color: SnackBarColor.error,
                );
                print(e);
              }
            },
            //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
            icon: const Icon(Icons.web),
          ),
        if (saved)
          IconButton(
            splashRadius: 20,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              await _specialsViewModel.saveSpecial(
                specialUuid: _special.uuid,
                save: false,
              );
              setState(() {});
            },
            //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
            icon: const Icon(Icons.bookmark_outlined, color: kColorAccent),
          )
        else
          IconButton(
            splashRadius: 20,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              _specialsViewModel.addSpecialStatIncrement(
                _special.uuid,
                SpecialStat.savedClick,
              );
              await _specialsViewModel.saveSpecial(
                specialUuid: _special.uuid,
                save: true,
              );
              setState(() {});
            },
            //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
            icon: const Icon(Icons.bookmark_border),
          ),
        if (_store.latLng.isNotNil)
          IconButton(
            splashRadius: 20,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              context.vRouter.to("/map/${_store.uuid}");

//               print("special: ${_special.storeUuid} ${_special.storeName}");
//               print("store: ${_store.uuid} ${_store.name}\n");
            },
            icon: const Icon(Icons.location_pin),
          ),
      ],
    );
  }
}
