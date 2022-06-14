import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:findgo/core/constants.dart';
import 'package:findgo/data_models/special.dart';
import 'package:findgo/main.dart';
import 'package:findgo/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vrouter/vrouter.dart';

class SpecialPageBACKUP extends StatefulWidget {
  final Special special;
  const SpecialPageBACKUP({Key? key, required this.special}) : super(key: key);
  @override
  _SpecialPageBACKUPState createState() => _SpecialPageBACKUPState();
}

class _SpecialPageBACKUPState extends State<SpecialPageBACKUP>
    with TickerProviderStateMixin {
  // late SpecialsViewModel _specialsViewModel;
  late Special _special;
  late AnimationController _slideAnimationController;

  Animation<double>? _animateHeight;

  @override
  void initState() {
    // _specialsViewModel = context.read(specialsVMProvider);
    _special = widget.special;
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimationController.addListener(() {
      setState(() {});
    });
    // Do after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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

  bool _isShowingFullImage = false;
  double _imageHeight = 0.0;

  late Completer<ui.Image> _completer;

  @override
  Widget build(BuildContext context) {
    // if (_special != null) {
    late Image image;
    _special.imageUrl != ""
        ? image = Image.network(_special.imageUrl)
        : image = Image.asset("assets/icons/logo.png");

    _completer = Completer<ui.Image>();
    image.image.resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        _completer.complete(info.image);
      }),
    );

    // if (_animateHeight != null) print("animH: ${_animateHeight!.value}");

    return Scaffold(
      // backgroundColor: kColorBackground,
      body: Consumer(
        builder: (context, ref, child) {
          final themeVM = ref.watch(themeVMProvider);
          final specialsVM = ref.watch(specialsVMProvider);
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
                  if (_special.imageUrl == "")
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          "assets/icons/logo.png",
                          height: 100.0,
                        ),
                      ),
                    )
                  else
                    FutureBuilder<ui.Image>(
                      future: _completer.future,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<ui.Image> snapshot,
                      ) {
                        if (snapshot.hasData && snapshot.hasData) {
                          final imageWidth = snapshot.data!.width.toDouble();
                          final deviceWidth = MediaQuery.of(context).size.width;

                          final expandRatio = deviceWidth / imageWidth;
                          final expandedHeight =
                              expandRatio * snapshot.data!.height.toDouble();
                          if (_imageHeight != expandedHeight) {
                            _imageHeight = expandedHeight;

                            WidgetsBinding.instance
                                .addPostFrameCallback((_) async {
                              if (_imageHeight != 0.0) {
                                _animateHeight = Tween<double>(
                                  begin: 160,
                                  end: _imageHeight,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _slideAnimationController,
                                    curve: Curves.decelerate,
                                  ),
                                );
                              }

                              setState(() {});
                            });
                          }

                          return GestureDetector(
                            onVerticalDragUpdate: (details) => setState(() {
                              _isShowingFullImage
                                  ? _slideAnimationController.forward()
                                  : _slideAnimationController.reverse();
                              if (details.delta.dy > 0) {
                                _isShowingFullImage = true;
                              } else if (details.delta.dy < 0) {
                                _isShowingFullImage = false;
                              } // Up
                            }),
                            // onTap: () {
                            //   // _slideAnimationController.forward();
                            //   _isShowingFullImage ? _slideAnimationController.reverse() : _slideAnimationController.forward();
                            //   setState(() => _isShowingFullImage = !_isShowingFullImage);
                            // },

                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: CachedNetworkImage(
                                imageUrl: _special.imageUrl,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        SizedBox(
                          height: _animateHeight != null
                              ? _animateHeight!.value
                              : 100,
                        ),
                        // SizedBox(
                        //     height: _isShowingFullImage
                        //         ? _animateHeight.value == 0.0
                        //         ? 200
                        //         : _animateHeight.value
                        //         : 160.0
                        // ),
                        Expanded(
                          child: GestureDetector(
                            onVerticalDragUpdate: (details) => setState(() {
                              _isShowingFullImage
                                  ? _slideAnimationController.forward()
                                  : _slideAnimationController.reverse();
                              if (details.delta.dy > 0) {
                                _isShowingFullImage = true;
                              } else if (details.delta.dy < 0) {
                                _isShowingFullImage = false;
                              } // Up
                            }),
                            // onTap: () {
                            //   _isShowingFullImage ? _slideAnimationController.reverse() : _slideAnimationController.forward();
                            //   setState(() => _isShowingFullImage = !_isShowingFullImage);
                            // },
                            child: Card(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              color: themeVM.mode == ThemeMode.dark
                                  ? kColorBackgroundDark
                                  : Colors.white,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 30.0,
                                ),
                                child: _cardContent(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 20),
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
                                // await canLaunch(tel) ? await launch(tel) : print('Could not launch $tel');
                                try {
                                  final uri = Uri(
                                    scheme: "tel",
                                    path: _special.storePhoneNumber,
                                  );
                                  specialsVM.addSpecialStatIncrement(
                                    _special.uuid,
                                    SpecialStat.phoneClick,
                                  );
                                  await launchUrl(uri);
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
                              child: Column(
                                children: [
                                  const Icon(Icons.phone, color: kColorAccent),
                                  const SizedBox(height: 8.0),
                                  const Text(
                                    "Call",
                                    style: TextStyle(
                                      color: kColorAccent,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          InkWell(
                            onTap: () async {
                              // Download image to a file
                              specialsVM.addSpecialStatIncrement(
                                _special.uuid,
                                SpecialStat.shareClick,
                              );
                              final file = await DefaultCacheManager()
                                  .getSingleFile(_special.imageUrl);
                              Share.shareFiles(
                                [file.path],
                                text:
                                    "${_special.storeName}\n${_special.name}\n\nFind out more click: https://findgo.co.za/admin/#/special?uid=${_special.uuid}",
                                // "Special @ ${_special!.storeName} : ${_special!.name} \n ${_special!.imageUrl}",
                                // subject: "subject",
                              );

                              // DefaultCacheManager().emptyCache();
                            },
                            child: Column(
                              children: [
                                const Icon(Icons.share, color: kColorAccent),
                                const SizedBox(height: 8.0),
                                const Text(
                                  "Share",
                                  style: TextStyle(
                                    color: kColorAccent,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_special.storeWebsite != "")
                            InkWell(
                              onTap: () async {
                                try {
                                  specialsVM.addSpecialStatIncrement(
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
                              child: Column(
                                children: [
                                  const Icon(Icons.web, color: kColorAccent),
                                  const SizedBox(height: 8.0),
                                  const Text(
                                    "Website",
                                    style: TextStyle(
                                      color: kColorAccent,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (saved)
                            InkWell(
                              onTap: () async {
                                await specialsVM.saveSpecial(
                                  specialUuid: _special.uuid,
                                  save: false,
                                );
                                setState(() {});
                              },
                              //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.bookmark_outlined,
                                    color: kColorAccent,
                                  ),
                                  const SizedBox(height: 8.0),
                                  const Text(
                                    " Saved",
                                    style: TextStyle(
                                      color: kColorAccent,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            InkWell(
                              onTap: () async {
                                specialsVM.addSpecialStatIncrement(
                                  _special.uuid,
                                  SpecialStat.savedClick,
                                );
                                await specialsVM.saveSpecial(
                                  specialUuid: _special.uuid,
                                  save: true,
                                );
                                setState(() {});
                              },
                              //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.bookmark_border,
                                    color: kColorAccent,
                                  ),
                                  const SizedBox(height: 8.0),
                                  const Text(
                                    " Save ",
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
            ),
          );
        },
      ),
    );
  }

  Widget _cardContent() {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              // backgroundImage: NetworkImage(_special.storeImageUrl)
              backgroundImage:
                  CachedNetworkImageProvider(_special.storeImageUrl),
            ),
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
          child: Text(
            _special.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: GlowingOverscrollIndicator(
            axisDirection: AxisDirection.up,
            color: kColorAccent,
            child: GlowingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              color: kColorAccent,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 36.0,
                  ),
                  Text(
                    _special.storeName,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (_special.storeCategory != "")
                    const SizedBox(
                      height: 4.0,
                    ),
                  if (_special.storeCategory != "")
                    Text(
                      _special.storeCategory,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  if (_special.price != 0)
                    const SizedBox(
                      height: 24.0,
                    ),
                  if (_special.price != 0)
                    Text(
                      "R ${(_special.price / 100).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                              child: Text(
                                "From:",
                                style: kTextStyleSmallSecondary,
                                textAlign: TextAlign.end,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                DateFormat.E()
                                    .add_yMMMd()
                                    .format(_special.validFrom),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(width: 30.0),
                            Expanded(
                              flex: 2,
                              child: Text(
                                DateFormat.jm().format(_special.validFrom),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Until:",
                                style: kTextStyleSmallSecondary,
                                textAlign: TextAlign.end,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                DateFormat.E()
                                    .add_yMMMd()
                                    .format(_special.validUntil!),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(width: 30.0),
                            Expanded(
                              flex: 2,
                              child: Text(
                                DateFormat.jm().format(_special.validUntil!),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 42.0,
                  ),
                  const Text(
                    "Description & Terms",
                    style: kTextStyleSmallSecondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    _special.description,
                    style: const TextStyle(fontSize: 14),
                  ),
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
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 80.0,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    super.dispose();
  }
}
