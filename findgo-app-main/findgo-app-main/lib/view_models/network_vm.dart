import 'package:flutter/material.dart';

import '../external_services/network_info.dart';

enum NetworkViewState { online, offline}

class NetworkViewModel extends ChangeNotifier {
  NetworkInfo networkInfo;
  // Constructor
  NetworkViewModel({required this.networkInfo,});

  // late BuildContext _context;
  // // ignore: avoid_setters_without_getters
  // set context(BuildContext ctx) => _context = ctx;

  NetworkViewState _state = NetworkViewState.online;
  NetworkViewState get state => _state;
  void setState(NetworkViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  Future<void> checkNetworkStatus() async => setState(await networkInfo.isConnected ? NetworkViewState.online : NetworkViewState.offline);
  Future<void> streamNetworkStatus() async {
    while (state == NetworkViewState.offline) {
      await checkNetworkStatus();
      // print(state);
      await Future.delayed(const Duration(seconds: 5));
    }
  }

}