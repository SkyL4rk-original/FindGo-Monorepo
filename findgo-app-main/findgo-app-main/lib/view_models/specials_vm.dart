import 'dart:async';
import 'dart:developer';

import 'package:findgo/core/constants.dart';
import 'package:findgo/core/failure.dart';
import 'package:findgo/data_models/special.dart';
import 'package:findgo/internal_services/routes.dart';
import 'package:findgo/repositories/specials_repo.dart';
import 'package:findgo/view_models/network_vm.dart';
import 'package:findgo/view_pages/special_pg.dart';
import 'package:findgo/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

enum SpecialViewState { idle, busy, error, uploading }

class SpecialsViewModel extends ChangeNotifier {
  final NetworkViewModel networkViewModel;
  final SpecialsRepository specialsRepository;

  SpecialsViewModel({
    required this.networkViewModel,
    required this.specialsRepository,
  });

  // Iterable<Special> filteredSpecialList = [];
  List<Special> _specialsList = [];
  List<Special> get specialsList => _specialsList;

  Set<String> _savedSpecialsUuidSet = {};
  Set<String> get savedSpecialsUuidSet => _savedSpecialsUuidSet;

  // Build Context
  late BuildContext _context;
  // ignore: avoid_setters_without_getters
  set context(BuildContext ctx) => _context = ctx;

  // State Management
  SpecialViewState _state = SpecialViewState.busy;
  SpecialViewState get state => _state;
  void setState(SpecialViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  // Error Handling
  void _handleFailure(Failure failure) {
    log("Specials VM: $failure");
    if (failure is OfflineFailure &&
        networkViewModel.state == NetworkViewState.online) {
      InfoSnackBar.show(
        _context,
        kMessageOfflineError,
        color: SnackBarColor.error,
      );
      networkViewModel.setState(NetworkViewState.offline);
      networkViewModel.streamNetworkStatus();
    } else if (networkViewModel.state != NetworkViewState.offline) {
      Failure.handleFailure(context: _context, failure: failure);
    }
    // Failure.handleFailure(context: _context, failure: failure, logoutFunction: authViewModel.logout, );

    setState(SpecialViewState.error);
  }

  void clearSpecialsList() {
    _specialsList = [];
  }

  // SPECIALS
  bool _fetchingSpecials = false;
  Future<void> getAllSpecials() async {
    if (_fetchingSpecials) return;
    setState(SpecialViewState.busy);
    _fetchingSpecials = true;

    // await Future.delayed(const Duration(seconds: 1), () {} );

    final failureOrSpecialsList = await specialsRepository.getAllSpecials();
    failureOrSpecialsList.fold((failure) => _handleFailure(failure),
        (specialsList) {
      // ignore: prefer_function_declarations_over_variables
      final Comparator<Special> dateComparator =
          (a, b) => a.validFrom.compareTo(b.validFrom);
      _specialsList = specialsList.toList();
      _specialsList.sort(dateComparator);
      final List<Special> featuredSpecials = _specialsList
          .where((special) => special.typeSet.contains(SpecialType.featured))
          .toList();

      _specialsList = [
        ...featuredSpecials,
        ..._specialsList
            .where((special) => !special.typeSet.contains(SpecialType.featured))
            .toList()
      ];
    });
    // await Future.delayed(const Duration(seconds: 1),
    //   () => _specialsList = mockSpecialsList.map((special) => Special.fromJson(special)).toSet()
    // );
    _fetchingSpecials = false;
    setState(SpecialViewState.idle);
  }

  Future<Special?> getSpecialByUuid(String uuid) async {
    setState(SpecialViewState.busy);
    Special? special;

    final failureOrSpecialsList =
        await specialsRepository.getSpecialByUuid(uuid);
    failureOrSpecialsList.fold((failure) => {}, (specialResp) {
      special = specialResp;
    });
    setState(SpecialViewState.idle);
    return special;
  }

  bool hasActiveSpecialsFromFollowed(Set<String> followedStoresUuid) {
    for (final storeUuid in followedStoresUuid) {
      if (_specialsList.any((special) => special.storeUuid == storeUuid)) {
        return true;
      }
    }
    return false;
  }

  // Saved Specials
  Future<void> removeExpiredSavedSpecials() async {
    for (final specialUuid in _savedSpecialsUuidSet) {
      if (!_specialsList.any((special) => specialUuid == special.uuid)) {
        // Remove Expired Special
        await specialsRepository.removeSavedSpecial(specialUuid);
      }
    }
  }

  Future<void> getAllSavedSpecials() async {
    setState(SpecialViewState.busy);

    final failureOrSavedStoreSet =
        await specialsRepository.getAllSavedSpecials();
    failureOrSavedStoreSet.fold((failure) => _handleFailure(failure),
        (savedSpecials) {
      _savedSpecialsUuidSet = savedSpecials;
    });

    // await Future.delayed(const Duration(seconds: 1),
    //         () => followedStoresUuidList = mockFollowedStoreUuidList.toSet()
    // );
    setState(SpecialViewState.idle);
    // removeExpiredSavedSpecials(); // TODO TEST REMOVE EXPIRED SPECIALS
  }

  Future<void> saveSpecial({
    required String specialUuid,
    required bool save,
  }) async {
    if (save) {
      final failureOrSuccess =
          await specialsRepository.addSavedSpecial(specialUuid);
      failureOrSuccess.fold(
        (failure) => _handleFailure(failure),
        (_) => _savedSpecialsUuidSet.add(specialUuid),
      );
    } else {
      final failureOrSuccess =
          await specialsRepository.removeSavedSpecial(specialUuid);
      failureOrSuccess.fold(
        (failure) => _handleFailure(failure),
        (_) => _savedSpecialsUuidSet.remove(specialUuid),
      );
    }
    await Future.delayed(const Duration(milliseconds: 300), () => null);
  }

  Future<void> addSpecialStatIncrement(
    String specialUuid,
    SpecialStat specialStat,
  ) async {
    specialsRepository.addSpecialStatIncrement(specialUuid, specialStat);
  }

  // DEEP LINKS
  bool _initComplete = false;
  late StreamSubscription _deepLinkSub;
  Future<void> initUniLinks() async {
    if (_initComplete) return;
    _initComplete = true;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialUrl = await getInitialLink();
      // final initialUri = await getInitialUri();
      //InfoSnackBar.show(_context, " INIT URI: $initialUri");
      handleUri(initialUrl);
    } on FormatException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }

    // Attach a listener to the stream
    _deepLinkSub = linkStream.listen(
      (String? url) {
        // InfoSnackBar.show(_context, "URI: $uri");
        handleUri(url);
      },
      onError: (err) {
        InfoSnackBar.show(_context, "Url Error: could not parse url");
        // Handle exception by warning the user their action did not succeed
      },
    );
  }

  Future<void> handleUri(String? url) async {
    if (url != null) {
      // Remove # from flutter web
      final parsedUrl = url.replaceFirst("/#/", "/");
      final uri = Uri.parse(parsedUrl);

      final queries = uri.queryParametersAll;
      if (queries.isEmpty && queries["uid"] != null) {
        InfoSnackBar.show(_context, "Url Error: could not find query");
        return;
      }
      // print(link);
      final special = await getSpecialByUuid(queries["uid"]![0]);
      if (special == null) {
        InfoSnackBar.show(
          _context,
          "Error Finding Special: The special may have expired or been removed.",
          color: SnackBarColor.error,
        );
      } else {
//         print(special);
//         print(_context);
        // if (_context.toString().contains("(DEFUNCT)(no widget)"))
        // await Future.delayed(const Duration(seconds: 2));
        Routes.push(
          _context,
          SpecialPage(special: special),
        );
      }

      // final link = "/special/${queries["uid"]![0]}";
      // VRouter.of(_context).push(link);
    }
  }

  @override
  void dispose() {
    _deepLinkSub.cancel();
    super.dispose();
  }
}
