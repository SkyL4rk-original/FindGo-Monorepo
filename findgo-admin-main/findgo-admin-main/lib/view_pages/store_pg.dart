// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:findgo_admin/core/constants.dart';
import 'package:findgo_admin/data_models/lat_lon.dart';
import 'package:findgo_admin/data_models/store.dart';
import 'package:findgo_admin/main.dart';
import 'package:findgo_admin/view_models/locations_vm.dart';
import 'package:findgo_admin/view_models/stores_vm.dart';
import 'package:findgo_admin/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class StorePage extends ConsumerStatefulWidget {
  final Store? store;
  const StorePage({Key? key, this.store}) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends ConsumerState<StorePage> {
  late StoresViewModel _storesViewModel;
  late LocationsViewModel _locationsViewModel;
  late Store _store;
  late Store _tempStore;

  final _picker = ImagePicker();

  int _selectedCategory = 13;
  int? _selectedLocation;

  final _formKey = GlobalKey<FormState>();
  final _nameTextEditingController = TextEditingController();
  final _descriptionTextEditingController = TextEditingController();
  final _phoneNumberTextEditingController = TextEditingController();
  final _websiteTextEditingController = TextEditingController();
  final _lngTextController = TextEditingController();
  final _latTextController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _phoneNumberFocusNode = FocusNode();
  final _websiteFocusNode = FocusNode();
  final _streetAddressFocusNode = FocusNode();
  final _latFocusNode = FocusNode();
  final _lngFocusNode = FocusNode();

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    _descriptionTextEditingController.dispose();
    _phoneNumberTextEditingController.dispose();
    _websiteTextEditingController.dispose();
    _latTextController.dispose();
    _lngTextController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _websiteFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _storesViewModel = ref.read(storesVMProvider);
    _locationsViewModel = ref.read(locationsVMProvider);

    if (widget.store != null) {
      _store = widget.store!;
      _tempStore = widget.store!.copyWith();
      _selectedCategory = widget.store!.categoryId;
      _selectedLocation = widget.store!.locationId;
      _nameTextEditingController.text = _tempStore.name;
      _descriptionTextEditingController.text = _tempStore.description;
      _phoneNumberTextEditingController.text = _tempStore.phoneNumber;
      _websiteTextEditingController.text = _tempStore.website;
      if (_tempStore.latLng.isNotNil) {
        _latTextController.text = _tempStore.latLng.lat.toString();
      }
      if (_tempStore.latLng.isNotNil) {
        _lngTextController.text = _tempStore.latLng.lng.toString();
      }
    } else {
      _store = Store(
        uuid: "",
        imageUrl: "",
        category: "Other",
        location: "", // ?
        name: "",
        description: "",
      );
      _tempStore = _store.copyWith();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          // leading: IconButton(onPressed: () => context.vRouter.to("/", isReplacement: true), icon: const Icon(Icons.arrow_back_ios)),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(_tempStore.uuid),
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Center(child: _updateStoreSection()),
          ),
        ),
      ),
    );
  }

  ButtonStyle _storesStatusToggleButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      primary: color,
      // side: BorderSide(color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
  }

  ButtonStyle _storeStatusInactiveTextButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      primary: color,
      // side: BorderSide(color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
  }

  final _formHeadingTextStyle =
      const TextStyle(fontSize: 12.0, color: kColorSecondaryText);

  ImageProvider? _getStoreImage() {
    if (_tempStore.image != null) return MemoryImage(_tempStore.image!);
    if (_tempStore.imageUrl != "") return NetworkImage(_tempStore.imageUrl);
    return null;
  }

  Widget _updateStoreSection() {
    return Consumer(
      builder: (context, ref, _) {
        final authVM = ref.watch(authVMProvider);
        final storeVM = ref.watch(storesVMProvider);
        final locationVM = ref.watch(locationsVMProvider);
        storeVM.context = context;
        locationVM.context = context;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 360.0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Restaurant Profile",
                        style: TextStyle(fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        width: 40.0,
                      )
                    ],
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
                            if (_store.uuid.isNotEmpty)
                              InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onTap: () async {
                                  InfoSnackBar.show(
                                    context,
                                    "Restaurant id added to clipboard",
                                  );
                                  await Clipboard.setData(
                                    ClipboardData(text: _store.uuid),
                                  );
                                },
                                child: Text(
                                  _store.uuid,
                                  style: _formHeadingTextStyle,
                                ),
                              ),
                            if (_store.uuid.isNotEmpty)
                              const SizedBox(height: 16.0),
                            InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () => _nameFocusNode.requestFocus(),
                              child: Text(
                                "Restaurant Name",
                                style: _formHeadingTextStyle,
                              ),
                            ),
                            TextFormField(
                              validator: (description) {
                                if (description == null ||
                                    description.isEmpty) {
                                  return "please enter your restaurant name";
                                }
                                return null;
                              },
                              onChanged: (name) =>
                                  setState(() => _tempStore.name = name),
                              // style: const TextStyle(height: 1.0),
                              focusNode: _nameFocusNode,
                              controller: _nameTextEditingController,
                            ),
                            const SizedBox(height: 16.0),
                            // Text("Store Image", style: _formHeadingTextStyle),
                            // const SizedBox(height: 4.0),
                            // Text("Category", style: _formHeadingTextStyle),
                            // DropdownButtonFormField(
                            //   value: _selectedCategory,
                            //   items: _storeCategoryList(),
                            //   onChanged: (value) {
                            //     if (value != null) {
                            //       setState(() {
                            //         _tempStore.category = storeVM.categoryList
                            //             .firstWhere(
                            //               (category) => category.id == value as int,
                            //             )
                            //             .name;
                            //         _tempStore.categoryId = value as int;
                            //         _selectedCategory = value;
                            //       });
                            //     }
                            //   },
                            // ),
                            const SizedBox(height: 16.0),
                            // Text("Store Image", style: _formHeadingTextStyle),
                            // const SizedBox(height: 4.0),
                            Text("Location", style: _formHeadingTextStyle),
                            DropdownButtonFormField(
                              value: _selectedLocation,
                              items: _storeLocationList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _tempStore.location =
                                        locationVM.locationsList
                                            .firstWhere(
                                              (location) =>
                                                  location.id == value as int,
                                            )
                                            .name;
                                    _tempStore.locationId = value as int;
                                    _selectedLocation = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16.0),
                            if (_getStoreImage() != null)
                              Center(
                                child: CircleAvatar(
                                  backgroundImage: _getStoreImage(),
                                  radius: 40,
                                  child: InkWell(
                                    onTap: () async {
                                      final pickedFile =
                                          await _picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (pickedFile != null) {
                                        final file =
                                            await pickedFile.readAsBytes();
                                        // print("BYTES: ${file.lengthInBytes}");
                                        if (file.lengthInBytes >
                                            kMaxImageByteSize) {
                                          InfoSnackBar.show(
                                            context,
                                            "Image too large",
                                            color: SnackBarColor.error,
                                          );
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const AlertDialog(
                                                backgroundColor: Colors.red,
                                                title: Center(
                                                  child:
                                                      Text("Image too large"),
                                                ),
                                                content: Text(
                                                  "Max image upload size is 3MB",
                                                ),
                                                actions: [],
                                                elevation: 4,
                                              );
                                            },
                                          );
                                          return;
                                        }

                                        _tempStore.image = file;
                                        setState(() {});
                                      } else {
                                        print('No image selected.');
                                      }
                                    },
                                    child: const SizedBox(
                                      height: 50,
                                      width: 50,
                                    ),
                                  ),
                                ),
                              )
                            else
                              TextButton.icon(
                                onPressed: () async {
                                  final pickedFile = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (pickedFile != null) {
                                    final file = await pickedFile.readAsBytes();
                                    // print("BYTES: ${file.lengthInBytes}");
                                    if (file.lengthInBytes >
                                        kMaxImageByteSize) {
                                      InfoSnackBar.show(
                                        context,
                                        "Image too large",
                                        color: SnackBarColor.error,
                                      );
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const AlertDialog(
                                            backgroundColor: kColorError,
                                            title: Center(
                                              child: Text("Image too large"),
                                            ),
                                            content: Text(
                                              "Max image upload size is 3MB",
                                            ),
                                            actions: [],
                                            elevation: 4,
                                          );
                                        },
                                      );
                                      return;
                                    }

                                    _tempStore.image = file;
                                    setState(() {});
                                  } else {
                                    print('No image selected.');
                                  }
                                },
                                icon: const Icon(
                                  Icons.image_outlined,
                                  color: Colors.white,
                                ),
                                label: _tempStore.image == null &&
                                        _tempStore.imageUrl == ""
                                    ? const Text(
                                        "Add Image (max 3MB)",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : const Text(
                                        "Update Image (max 3MB)",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            const SizedBox(height: 16.0),
                            InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () => _descriptionFocusNode.requestFocus(),
                              child: Text(
                                "Description",
                                style: _formHeadingTextStyle,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Stack(
                              children: [
                                TextFormField(
                                  validator: (description) {
                                    if (description == null ||
                                        description.isEmpty) {
                                      return "Please enter a resaurant description";
                                    }
                                    return null;
                                  },
                                  onChanged: (description) => setState(
                                    () => _tempStore.description = description,
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    helperMaxLines: 4,
                                    hintMaxLines: 4,
                                  ),
                                  focusNode: _descriptionFocusNode,
                                  controller: _descriptionTextEditingController,
                                  style: const TextStyle(fontSize: 12.0),
                                  keyboardType: TextInputType.multiline,
                                  maxLength: 254,
                                  maxLines: 4,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 34,
                                  child: TextButton(
                                    onPressed: () async => setState(
                                      () => _descriptionFocusNode.unfocus(),
                                    ),
                                    child: Text(
                                      "Save",
                                      style: TextStyle(
                                        color: _descriptionFocusNode.hasFocus
                                            ? kColorAccent
                                            : kColorSecondaryText,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // INFO: Phone number inputs
                            InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () => _phoneNumberFocusNode.requestFocus(),
                              child: Text(
                                "Phone Number",
                                style: _formHeadingTextStyle,
                              ),
                            ),
                            TextFormField(
                              // validator: (phoneNumber) {
                              //   if (phoneNumber == null || phoneNumber.isEmpty) {
                              //     return "please enter your store phone number";
                              //   }
                              //
                              //   return null;
                              // },
                              onFieldSubmitted: (phoneNumber) async {
                                _tempStore.phoneNumber = phoneNumber.trim();
                                _tempStore.phoneNumber =
                                    _tempStore.phoneNumber.replaceAll(' ', '');
                                // print( _tempStore.phoneNumber);
                                setState(() {});
                              },
                              onChanged: (phoneNumber) async {
                                _tempStore.phoneNumber = phoneNumber.trim();
                                _tempStore.phoneNumber =
                                    _tempStore.phoneNumber.replaceAll(' ', '');
                                // print( _tempStore.phoneNumber);
                                setState(() {});
                              },
                              // style: const TextStyle(height: 1.0),
                              focusNode: _phoneNumberFocusNode,
                              controller: _phoneNumberTextEditingController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16.0),
                            // INFO: Website inputs
                            InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () => _websiteFocusNode.requestFocus(),
                              child: Text(
                                "Full Website Url",
                                style: _formHeadingTextStyle,
                              ),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: "https://www.findgo.co.za",
                              ),
                              // validator: (website) {
                              //   if (website == null || website.isEmpty) {
                              //     return "please enter your website";
                              //   }
                              //   return null;
                              // },
                              onChanged: (website) => setState(
                                () => _tempStore.website = website.trim(),
                              ),
                              onFieldSubmitted: (website) {
                                setState(
                                  () => _tempStore.website = website.trim(),
                                );
                                _streetAddressFocusNode.requestFocus();
                                // TODO Check url can be reached
                              },
                              // style: const TextStyle(height: 1.0),
                              focusNode: _websiteFocusNode,
                              controller: _websiteTextEditingController,
                            ),
                            const SizedBox(height: 16.0),
                            // INFO: Street Address inputs
                            Text(
                              "Street Address",
                              style: _formHeadingTextStyle,
                            ),
                            const SizedBox(
                              height: 12.0,
                            ),
                            TextButton(
                              focusNode: _streetAddressFocusNode,
                              onPressed: () async {
                                final placeId = await showDialog(
                                  context: context,
                                  builder: (ctx) =>
                                      const _AddressSearchDialog(),
                                ) as String?;

                                if (placeId != null) {
                                  final nameList = placeId.split(":");
                                  if (nameList.first == "name") {
                                    _tempStore.streetAddress = nameList.last;
                                    setState(() {});
                                    return;
                                  }

                                  final placeDetails = await _storesViewModel
                                      .searchPlaceDetails(placeId);
                                  if (placeDetails != null) {
                                    _tempStore.latLng = placeDetails.latLon;
                                    _latTextController.text =
                                        placeDetails.latLon.lat.toString();
                                    _lngTextController.text =
                                        placeDetails.latLon.lng.toString();

                                    final addressStringSplit =
                                        placeDetails.streetAddress.split(",");
                                    if (addressStringSplit.length > 1) {
                                      _tempStore.streetAddress =
                                          "${addressStringSplit.elementAt(0)}, ${addressStringSplit.elementAt(1)}";
                                    } else {
                                      _tempStore.streetAddress =
                                          addressStringSplit.elementAt(0);
                                    }
                                    setState(() {});
                                  }
                                }
                              },
                              child: Text(
                                _tempStore.streetAddress.isEmpty
                                    ? "+ Add Street Address"
                                    : _tempStore.streetAddress,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // INFO: Latitude inputs
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        onTap: () =>
                                            _latFocusNode.requestFocus(),
                                        child: Text(
                                          "Latitiude",
                                          style: _formHeadingTextStyle,
                                        ),
                                      ),
                                      TextFormField(
//                                   decoration: const InputDecoration(
//                                     hintText: "Latitude",
//                                   ),
//                               onFieldSubmitted: (latitude) async {
//                                 final lat = double.tryParse(latitude.trim());
//                                 if (lat != null) {
//                                   _tempStore.latLon =
//                                       _tempStore.latLon.copyWith(lat: lat);
//                                 }
//                                 setState(() {});
//                               },
                                        onChanged: (latitude) async {
                                          final lat =
                                              double.tryParse(latitude.trim());
                                          if (lat != null) {
                                            _tempStore.latLng = _tempStore
                                                .latLng
                                                .copyWith(lat: lat);
                                          } else {
                                            _tempStore.latLng =
                                                const LatLng.nil();
                                            _latTextController.text = "";
                                          }

                                          setState(() {});
                                        },
                                        // style: const TextStyle(height: 1.0),
                                        controller: _latTextController,
                                        focusNode: _latFocusNode,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                // INFO: Lonitude inputs
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        onTap: () =>
                                            _lngFocusNode.requestFocus(),
                                        child: Text(
                                          "Longitude",
                                          style: _formHeadingTextStyle,
                                        ),
                                      ),
                                      TextFormField(
//                                   decoration: const InputDecoration(
//                                     hintText: "Lonitude",
//                                   ),
//                               onFieldSubmitted: (lonitude) async {
//                                 final lon = double.tryParse(lonitude.trim());
//                                 if (lon != null) {
//                                   _tempStore.latLon =
//                                       _tempStore.latLon.copyWith(lng: lon);
//                                 }
//                                 setState(() {});
//                               },
                                        onChanged: (longitude) async {
                                          final lon =
                                              double.tryParse(longitude.trim());
                                          if (lon != null) {
                                            _tempStore.latLng = _tempStore
                                                .latLng
                                                .copyWith(lng: lon);
                                          } else {
                                            _tempStore.latLng =
                                                const LatLng.nil();
                                            _lngTextController.text = "";
                                          }
                                          setState(() {});
                                        }, // style: const TextStyle(height: 1.0),
                                        controller: _lngTextController,
                                        focusNode: _lngFocusNode,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            SizedBox(
                              height: 30.0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_tempStore.uuid.isNotEmpty)
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: _toggleActivateStoreButton(),
                                      ),
                                    ),
                                  if (_store.isUpdated(_tempStore) ||
                                      _store.uuid.isEmpty)
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: _actionButton(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (authVM.currentUser.isSuperUser)
                    Align(
                      alignment: Alignment.centerRight,
                      child: _deleteStoreButton(),
                    ),
                ],
              ),
            ),
            if (_store.status == StoreStatus.inactive)
              const SizedBox(width: 20.0),
            if (_store.status == StoreStatus.inactive)
              Padding(
                padding: const EdgeInsets.only(top: 36.0),
                child: Card(
                  color: kColorSelected,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Reqirements",
                          style: TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          "- Restaurant Name",
                          style: TextStyle(color: kColorSecondaryText),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          "- Restaurant Location",
                          style: TextStyle(color: kColorSecondaryText),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          "- Restaurant Image",
                          style: TextStyle(color: kColorSecondaryText),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          "- Restaurant Description",
                          style: TextStyle(color: kColorSecondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  final _specialsStatusActivateButtonStyle = ElevatedButton.styleFrom(
    primary: kColorActive,
    // side: BorderSide(color: color),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  );
  final _specialsStatusActivateErrorButtonStyle = ElevatedButton.styleFrom(
    primary: kColorUpdateInactive,
    // side: BorderSide(color: color),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  );
  final _specialsStatusDeactivateButtonStyle = TextButton.styleFrom(
    primary: kColorInactive,
    side: const BorderSide(color: kColorInactive),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  );
  Widget _toggleActivateStoreButton() {
    Widget buttonContent;

    // Check if inactive on save
    if (_storesViewModel.state == StoresViewState.updatingStatus) {
      buttonContent = const SizedBox(
        height: 30.0,
        width: 30.0,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_tempStore.status == StoreStatus.inactive) {
      buttonContent = SizedBox(
        width: 140.0,
        child: ElevatedButton.icon(
          onPressed: () async {
            if (_store.isUpdated(_tempStore)) {
              InfoSnackBar.show(
                context,
                "Please save resaurant updates before activating",
                color: SnackBarColor.error,
              );
              return;
            }

            _tempStore.status = StoreStatus.active;
            if (!await _storesViewModel.toggleStoreActivate(_tempStore)) {
              // _tempStore.status = StoreStatus.inactive;
            }

            setState(() {});
          },
          style: !_store.isUpdated(_tempStore) &&
                  !(_tempStore.imageUrl == "" && _tempStore.image == null)
              ? _specialsStatusActivateButtonStyle
              : _specialsStatusActivateErrorButtonStyle,
          icon: Icon(
            !_store.isUpdated(_tempStore) &&
                    !(_tempStore.imageUrl == "" && _tempStore.image == null)
                ? Icons.check
                : Icons.close,
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
            _tempStore.status = StoreStatus.inactive;

            if (!await _storesViewModel.toggleStoreActivate(_tempStore)) {
              // _tempStore.status = StoreStatus.active;
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

  Widget _actionButton() {
    Widget buttonContent;
    // INFO: Loading Indicator
    if (_storesViewModel.state == StoresViewState.uploading) {
      buttonContent = const SizedBox(
        height: 30.0,
        width: 30.0,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kColorAccent),
            strokeWidth: 2,
          ),
        ),
      );
      // INFO: Create Button
    } else if (_store.uuid.isEmpty) {
      buttonContent = ElevatedButton.icon(
        onPressed: _tempStore.categoryId == 0 ||
                _tempStore.locationId == 0 ||
                _tempStore.image == null
            ? null
            : () async {
                if (_tempStore.categoryId == 0) {
                  InfoSnackBar.show(
                    context,
                    "Please choose a category",
                    color: SnackBarColor.error,
                  );
                  return;
                }
                if (_tempStore.locationId == 0) {
                  InfoSnackBar.show(
                    context,
                    "Please choose a location",
                    color: SnackBarColor.error,
                  );
                  return;
                }
                if (_tempStore.imageUrl == "" && _tempStore.image == null) {
                  InfoSnackBar.show(
                    context,
                    "Please add an image",
                    color: SnackBarColor.error,
                  );
                  return;
                }

                if (_formKey.currentState != null &&
                    _formKey.currentState!.validate()) {
                  final newStore = Store(
                    uuid: "",
                    imageUrl: _tempStore.imageUrl,
                    category: _tempStore.category,
                    categoryId: _tempStore.categoryId,
                    location: _tempStore.location,
                    locationId: _tempStore.locationId,
                    image: _tempStore.image,
                    name: _tempStore.name,
                    description: _tempStore.description,
                    phoneNumber: _tempStore.phoneNumber,
                    website: _tempStore.website,
                    streetAddress: _tempStore.streetAddress,
                    latLng: _tempStore.latLng,
                    status: StoreStatus.active,
                  );

                  final createdStore =
                      await _storesViewModel.createStore(newStore);
                  if (createdStore != null) {
                    createdStore.image = null;
                    _store = createdStore.copyWith();
                    _tempStore = createdStore.copyWith();

                    print(_store.toJson());
                    print(_tempStore.toJson());
                    print(_store.isUpdated(_tempStore));

                    if (_store.latLng.isNil) {
                      _latTextController.text = "";
                      _lngTextController.text = "";
                    }
                    // await Future.delayed(
                    //     const Duration(milliseconds: 300), () {});
                    // Navigator.of(context).pop(newStoreUuid);
                    setState(() {});
                  }
                }
              },
        style: _storeStatusInactiveTextButtonStyle(kColorAccent),
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ),
        label: const Text(
          "Create",
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      // INFO: Update Button
      buttonContent = ElevatedButton.icon(
        onPressed: () async {
          if (_tempStore.imageUrl == "" && _tempStore.image == null) {
            InfoSnackBar.show(
              context,
              "Please add an image for current store",
              color: SnackBarColor.error,
            );
            return;
          }

          if (_formKey.currentState != null &&
              _formKey.currentState!.validate()) {
            if (await _storesViewModel.updateStore(_tempStore)) {
              _store = _tempStore.copyWith();
              _tempStore = _tempStore.copyWith();

              if (_store.latLng.isNil) {
                _latTextController.text = "";
                _lngTextController.text = "";
              }
            }

            setState(() {});
          }
        },
        style: _storesStatusToggleButtonStyle(kColorUpdate),
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ),
        label: const Text(
          "Update",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SizedBox(
      height: 40.0,
      width: 140.0,
      child: buttonContent,
    );
  }

  // INFO: Delete Store Button
  Widget _deleteStoreButton() {
    Widget buttonContent;
    if (_storesViewModel.state == StoresViewState.deleting) {
      buttonContent = const SizedBox(
        height: 30.0,
        width: 30.0,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kColorInactive),
          ),
        ),
      );
    } else {
      buttonContent = TextButton.icon(
        onPressed: () async {
          _storesViewModel.deleteStore(_store);
          await Future.delayed(const Duration(milliseconds: 300), () {});
          Navigator.of(context).pop();
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
      width: 140.0,
      child: buttonContent,
    );
  }

  List<DropdownMenuItem<int>>? _storeCategoryList() {
    final List<DropdownMenuItem<int>> items = [];

    for (final category in _storesViewModel.categoryList) {
      items.add(
        DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        ),
      );
    }

    return items;
  }

  List<DropdownMenuItem<int>>? _storeLocationList() {
    final List<DropdownMenuItem<int>> items = [];

    for (final location in _locationsViewModel.locationsList) {
      items.add(
        DropdownMenuItem(
          value: location.id,
          child: Text(location.name),
        ),
      );
    }

    return items;
  }
}

class _AddressSearchDialog extends ConsumerStatefulWidget {
  const _AddressSearchDialog({Key? key}) : super(key: key);

  @override
  _AddressSearchDialogState createState() => _AddressSearchDialogState();
}

class _AddressSearchDialogState extends ConsumerState<_AddressSearchDialog> {
  late final StoresViewModel _storeVM;

  List<SearchedPlace> _placeList = [];

  final _addressTextController = TextEditingController();

  @override
  void dispose() {
    _addressTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _storeVM = ref.read(storesVMProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 460.0,
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 80.0,
                width: 400.0,
                child: TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "1 Ballito Street, Ballito, KZN, South Africa",
                  ),
                  onChanged: (query) async {
                    if (query.length == 4) {
                      _placeList = await _storeVM.searchPlaceByQuery(query);
                      setState(() {});
                    } else {
                      _onChangeHandler(query);
                    }
                  },
                  controller: _addressTextController,
                ),
              ),
              SizedBox(
                height: 300.0,
                width: 400.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _placeList.length,
                  itemBuilder: (ctx, index) {
                    final place = _placeList.elementAt(index);
                    return Card(
                      color: kColorCard,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(place.placeId),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 8.0,
                          ),
                          child: Text(place.description),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: kColorSecondaryText),
                        ),
                      ),
                      TextButton(
                        onPressed: _addressTextController.text.trim().isNotEmpty
                            ? () => Navigator.of(context).pop(
                                  "name: ${_addressTextController.text.trim()}",
                                )
                            : null,
                        child: const Text(
                          "Manual Add",
                          style: TextStyle(color: kColorAccent),
                        ),
                      ),
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

  Timer? searchOnStoppedTyping;

  void _onChangeHandler(String value) {
    const duration = Duration(milliseconds: 800);
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping?.cancel()); // clear timer
    }

    searchOnStoppedTyping = Timer(duration, () => search(value));
  }

  Future<void> search(String value) async {
    if (value.length <= 4) return;
    _placeList = await _storeVM.searchPlaceByQuery(value);
    setState(() {});
  }
}
