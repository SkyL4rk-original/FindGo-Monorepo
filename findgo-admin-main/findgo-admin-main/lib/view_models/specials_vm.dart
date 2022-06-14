import 'package:findgo_admin/core/failure.dart';
import 'package:findgo_admin/data_models/special.dart';
import 'package:findgo_admin/data_models/store_stats.dart';
import 'package:findgo_admin/repositories/specials_repo.dart';
import 'package:findgo_admin/widgets/snackbar.dart';
import 'package:flutter/material.dart';

enum SpecialViewState {
  idle,
  busy,
  error,
  create,
  uploading,
  deleting,
  updatingStatus,
  uploadingImage
}

class SpecialsViewModel extends ChangeNotifier {
  SpecialsRepository specialsRepository;

  SpecialsViewModel({required this.specialsRepository});

  List<Special> _specialsList = [];
  List<Special> get specialsList => _specialsList;

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
  void _handleFailure(Failure failure, String funcName) {
    print("Specials VM: $funcName: $failure");
    Failure.handleFailure(context: _context, failure: failure);
    // Failure.handleFailure(context: _context, failure: failure, logoutFunction: authViewModel.logout, );

    setState(SpecialViewState.error);
  }

  // SPECIALS

  Future<Special?> createSpecial(Special special) async {
    setState(SpecialViewState.create);
    Special? returnSpecial;

    final failureOrSpecialUuid =
        await specialsRepository.createSpecial(special);
    failureOrSpecialUuid.fold(
        (failure) => _handleFailure(failure, "createSpecial"), (newSpecial) {
      _specialsList.add(newSpecial as Special);
      _sortSpecials();

      returnSpecial = newSpecial;

      InfoSnackBar.show(_context, "New Special Created");
      setState(SpecialViewState.idle);
    });

    return returnSpecial;
  }

  Future<void> getAllSpecials() async {
    setState(SpecialViewState.busy);

    final failureOrSpecialsList = await specialsRepository.getAllSpecials();
    failureOrSpecialsList.fold(
        (failure) => _handleFailure(failure, "getAllSpecials"), (specialsList) {
      _specialsList = (specialsList as Set<Special>).toList();
      _sortSpecials();
      setState(SpecialViewState.idle);
    });

    // TODO Put on timer
    _checkForOldSpecials();
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

  Future<bool> updateSpecial(Special special) async {
    setState(SpecialViewState.uploading);
    bool updateSuccess = false;

    final failureOrSuccess = await specialsRepository.updateSpecial(special);
    failureOrSuccess.fold((failure) => _handleFailure(failure, "updateSpecial"),
        (_) {
      special.image = null;
      _specialsList[(_specialsList.indexWhere(
        (tempSpecial) => tempSpecial.uuid == special.uuid,
      ))] = special;
      _sortSpecials();
      updateSuccess = true;
      InfoSnackBar.show(_context, "Special Updated");
      setState(SpecialViewState.idle);
    });

    return updateSuccess;
  }

  Future<bool> toggleSpecialActivate(
    Special special, {
    bool showSnackBar = true,
  }) async {
    setState(SpecialViewState.updatingStatus);
    bool updateSuccess = false;

    final failureOrSuccess =
        await specialsRepository.toggleSpecialActivate(special);
    failureOrSuccess.fold(
        (failure) => _handleFailure(failure, "toggleSpecialActivate"), (_) {
      _specialsList[(_specialsList.indexWhere(
        (tempSpecial) => tempSpecial.uuid == special.uuid,
      ))] = special;
      _sortSpecials();
      updateSuccess = true;
      if (showSnackBar) {
        InfoSnackBar.show(
          _context,
          "Special ${special.status == SpecialStatus.active ? "Activated" : "De-activated"}",
        );
      }
      setState(SpecialViewState.idle);
    });

    return updateSuccess;
  }

  Future<void> deleteSpecial(Special special) async {
    setState(SpecialViewState.deleting);

    final failureOrSuccess = await specialsRepository.deleteSpecial(special);
    failureOrSuccess.fold((failure) => _handleFailure(failure, "deleteSpecial"),
        (_) {
      _specialsList.remove(special);
      InfoSnackBar.show(_context, "Special Deleted");
      setState(SpecialViewState.idle);
    });
  }

  Future<StoreStats> getStoreStats({required String storeUuid}) async {
    StoreStats storeStats = StoreStats.init(storeUuid: storeUuid);
    setState(SpecialViewState.busy);

    for (final special in _specialsList) {
      if (special.storeUuid == storeUuid) {
        storeStats = storeStats.copyWith(
          impressions: storeStats.impressions + special.impressions,
          clicks: storeStats.clicks + special.clicks,
          phoneClicks: storeStats.phoneClicks + special.phoneClicks,
          savedClicks: storeStats.savedClicks + special.savedClicks,
          sharedClicks: storeStats.sharedClicks + special.shareClicks,
          websiteClicks: storeStats.websiteClicks + special.websiteClicks,
        );
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    setState(SpecialViewState.idle);
    return storeStats;
  }

  bool _checkingForTimeUpdates = false;
  Future<void> _checkForOldSpecials() async {
    if (_checkingForTimeUpdates) return;
    _checkingForTimeUpdates = true;

    while (true) {
      final dateNow = DateTime.now();

      // print("Checking for Expired Specials");
      for (final special in _specialsList) {
        if (special.status == SpecialStatus.active &&
            special.validUntil.year > 2020) {
          if (special.validUntil.isBefore(dateNow)) {
            print("Found expired: ${special.uuid}");
            special.status = SpecialStatus.inactive;
            await toggleSpecialActivate(special, showSnackBar: false);
          }
        }
      }
      await Future.delayed(const Duration(minutes: 1), () {});
    }
  }

  void _sortSpecials() {
    _specialsList.sort((a, b) {
      final int cmp = a.status.index.compareTo(b.status.index);
      if (cmp != 0) return cmp;
      return a.validFrom.compareTo(b.validFrom);
    });
    // _specialsList.sort((a, b) => a.validFrom.compareTo(b.validFrom));
    // _specialsList.sort((a, b) => a.status.index.compareTo(b.status.index));
    // _specialsList.sort((a, b) => a.name.compareTo(b.name));
  }
}
