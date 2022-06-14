import 'package:findgo/data_models/store.dart';
import 'package:findgo/view_models/stores_vm.dart';
import 'package:flutter/material.dart';

// const kButtonHeight = 40.0;
const kButtonFollowingWidth = 70.0;
const kButtonNotifyWidth = 40.0;

const kColorEnable = Colors.blueAccent;
const kColorDisable = Colors.redAccent;

class ToggleStoreFollowButton extends StatefulWidget {
  final StoresViewModel storesVM;
  final Store store;

  const ToggleStoreFollowButton({
    Key? key,
    required this.storesVM,
    required this.store,
  }) : super(key: key);

  @override
  _ToggleStoreFollowButtonState createState() =>
      _ToggleStoreFollowButtonState();
}

class _ToggleStoreFollowButtonState extends State<ToggleStoreFollowButton> {
  late StoresViewModel _storesVM; // Todo remove as param / add in class
  late Store _store;
  bool _busy = false;

  final kButtonUnfollowStyle = TextButton.styleFrom(
    primary: kColorDisable,
    side: const BorderSide(color: kColorDisable),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  );
  final kButtonFollowStyle = TextButton.styleFrom(
    primary: kColorEnable,
    side: const BorderSide(color: kColorEnable),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  );

  // @override
  // void initState() {
  //   _storesVM = widget.storesVM;
  //   _store = widget.store;
  //   print(_store.name);
  //
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    _storesVM = widget.storesVM;
    _store = widget.store;

    // Dont show follow unfollow for find go
    if (_storesVM.findgoUuid == _store.uuid) return const SizedBox();

    final followed =
        _storesVM.followedStoresUuidList.any((uuid) => uuid == _store.uuid);
    late Widget child;
    final style = followed ? kButtonUnfollowStyle : kButtonFollowStyle;

    // Select Button Child
    if (_busy) {
      child = SizedBox(
        width: kButtonFollowingWidth,
        child: Center(
          child: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: followed ? kColorDisable : kColorEnable,
            ),
          ),
        ),
      );
    } else if (followed) {
      child = const SizedBox(
        width: kButtonFollowingWidth,
        child: Text(
          "Unfollow",
          textAlign: TextAlign.center,
        ),
      );
    } else {
      child = const SizedBox(
        width: kButtonFollowingWidth,
        child: Text(
          "Follow",
          textAlign: TextAlign.center,
        ),
      );
    }

    return TextButton(
      onPressed: _busy
          ? () async {}
          : () async {
              setState(() {
                _busy = true;
              });
              await _storesVM.followStore(
                storeUuid: _store.uuid,
                follow: !followed,
              );
              setState(() {
                _busy = false;
              });
            },
      style: style,
      child: child,
    );
  }
}

class ToggleStoreNotifyButton extends StatefulWidget {
  final StoresViewModel storesVM;
  final Store store;

  const ToggleStoreNotifyButton({
    Key? key,
    required this.storesVM,
    required this.store,
  }) : super(key: key);

  @override
  _ToggleStoreNotifyButtonState createState() =>
      _ToggleStoreNotifyButtonState();
}

class _ToggleStoreNotifyButtonState extends State<ToggleStoreNotifyButton> {
  late StoresViewModel _storesVM;
  late Store _store;
  bool _busy = false;

  final kButtonNotifyStyle = TextButton.styleFrom(
    primary: kColorEnable,
    side: const BorderSide(color: kColorEnable),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  );
  final kButtonUnNotifyStyle = TextButton.styleFrom(
    primary: kColorDisable,
    side: const BorderSide(color: kColorDisable),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  );

  // @override
  // void initState() {
  //   _storesVM = widget.storesVM;
  //   _store = widget.store;
  //   print(_store.name);
  //
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    _storesVM = widget.storesVM;
    _store = widget.store;

    final notify =
        _storesVM.notifyStoresUuidList.any((uuid) => uuid == _store.uuid);
    late Widget child;
    final style = notify ? kButtonUnNotifyStyle : kButtonNotifyStyle;

    // Select Button Child
    if (_busy) {
      child = SizedBox(
        width: kButtonNotifyWidth,
        child: Center(
          child: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: notify ? kColorDisable : kColorEnable,
            ),
          ),
        ),
      );
    } else if (notify) {
      child = const SizedBox(
        width: kButtonNotifyWidth,
        child: Icon(Icons.notifications_none, size: 20),
      );
    } else {
      child = const SizedBox(
        width: kButtonNotifyWidth,
        child: Icon(Icons.notifications_active_outlined, size: 20),
      );
    }

    return TextButton(
      onPressed: _busy
          ? () async {}
          : () async {
              setState(() {
                _busy = true;
              });
              await _storesVM.notifyStore(
                storeUuid: _store.uuid,
                notify: !notify,
              );
              setState(() {
                _busy = false;
              });
            },
      style: style,
      child: child,
    );
  }
}

