import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import '../core/constants.dart';
import '../data_models/special.dart';
import '../main.dart';
import '../view_models/specials_vm.dart';
import '../widgets/special_card.dart';

class DownloadPage extends StatefulWidget {
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late SpecialsViewModel _specialsViewModel;
  Special? _special;
  // double _screenWidth = 0.0;
  @override
  void initState() {
    _specialsViewModel = context.read(specialsVMProvider);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final uuid = context.vRouter.queryParameters["uid"];
      // print("SPECIAL UUID: $uuid");
      if (uuid != null)
        _special = await _specialsViewModel.getSpecialByUuid(uuid);
      // print(_special);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final specialVM = watch(specialsVMProvider);
      specialVM.context = context;
      // _screenWidth = MediaQuery.of(context).size.width;

      return Scaffold(
        backgroundColor: kColorBackground,
        body: Scrollbar(
          isAlwaysShown: true,
          child: SingleChildScrollView(child: _downloadSection()),
        ),
      );
    });
  }

  final _kButtonHeight = 40.0;
  // final _kButtonWidth = 180.0;
  Widget _downloadSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 140,
              // width: _kButtonWidth,
              child: Image.asset("images/findgo.jpeg"),
              // child: Image.asset("images/findgo.png"),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          if (_specialsViewModel.state == SpecialViewState.busy)
            const CircularProgressIndicator(),
          if (_special != null)
            SizedBox(width: 400, child: SpecialCard(special: _special!)),
          const SizedBox(
            height: 40.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: _kButtonHeight,
                // width: _kButtonWidth,
                child: InkWell(
                  onTap: () => context.vRouter.toExternal(
                      "https://apps.apple.com/us/app/findgo/id1574321570",
                      openNewTab: true),
                  child: Image.asset("images/apple_store.png"),
                ),
              ),
              const SizedBox(
                width: 20.0,
              ),
              SizedBox(
                height: _kButtonHeight,
                // width: _kButtonWidth,
                child: InkWell(
                  onTap: () => context.vRouter.toExternal(
                      "https://play.google.com/store/apps/details?id=app.specials.findgo",
                      openNewTab: true),
                  child: Image.asset("images/google_store.png"),
                ),
              ),
              const SizedBox(
                width: 20.0,
              ),
              SizedBox(
                height: _kButtonHeight,
                // width: _kButtonWidth,
                child: InkWell(
                  onTap: () => context.vRouter.toExternal(
                      "https://appgallery.huawei.com/#/app/C104564149",
                      openNewTab: true),
                  child: Image.asset("images/huawei_store.png"),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 40.0,
          ),
        ],
      ),
    );
  }
}

