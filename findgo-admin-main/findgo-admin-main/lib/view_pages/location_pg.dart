import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../data_models/location.dart';
import '../main.dart';
import '../view_models/locations_vm.dart';
import '../widgets/snackbar.dart';

class LocationPage extends StatefulWidget {
  final Location? location;
  const LocationPage({Key? key, this.location}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late LocationsViewModel _locationsViewModel;
  late Location _location;
  late Location _tempLocation;

  final _formKey = GlobalKey<FormState>();
  final _nameTextEditingController = TextEditingController();

  final _nameFocusNode = FocusNode();

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _locationsViewModel = context.read(locationsVMProvider);

    if (widget.location != null) {
      _location = widget.location!;
      _tempLocation = widget.location!.copyWith();
      _nameTextEditingController.text = _tempLocation.name;
    } else {
      _location = Location(
        id: 0,
        name: "",
      );
      _tempLocation = _location.copyWith();
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
              onPressed: () => Navigator.of(context).pop(_tempLocation.id),
              icon: const Icon(Icons.arrow_back_ios)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(child: _updateLocationSection()),
        ),
      ),
    );
  }

  ButtonStyle _locationsStatusToggleButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
        primary: color,
        // side: BorderSide(color: color),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)));
  }

  ButtonStyle _locationStatusInactiveTextButtonStyle(Color color) { // ?
    return ElevatedButton.styleFrom(
        primary: color,
        // side: BorderSide(color: color),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)));
  }

  final _formHeadingTextStyle =
      const TextStyle(fontSize: 12.0, color: kColorSecondaryText);

  Widget _updateLocationSection() {
    return Consumer(builder: (context, watch, child) {
      final authVM = watch(authVMProvider);
      final locationVM = watch(locationsVMProvider);
      locationVM.context = context;

      return SizedBox(
        width: 360.0,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Location Profile",
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
                      // if (_location.id != 0)
                      //   InkWell(
                      //     highlightColor: Colors.transparent,
                      //     splashColor: Colors.transparent,
                      //     hoverColor: Colors.transparent,
                      //     onTap: () async {
                      //       InfoSnackBar.show(
                      //           context, "Location id added to clipboard");
                      //       await Clipboard.setData(
                      //           ClipboardData(text: _location.id as String));
                      //     },
                      //     child:
                      //         Text(_location.uuid, style: _formHeadingTextStyle),
                      //   ),
                      if (_location.id != 0) const SizedBox(height: 16.0),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () => _nameFocusNode.requestFocus(),
                        child: Text("Location  Name", style: _formHeadingTextStyle),
                      ),
                      TextFormField(
                        validator: (description) {
                          if (description == null || description.isEmpty) {
                            return "please enter your location name";
                          }
                          return null;
                        },
                        onChanged: (name) =>
                            setState(() => _tempLocation.name = name),
                        // style: const TextStyle(height: 1.0),
                        focusNode: _nameFocusNode,
                        controller: _nameTextEditingController,
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: 30.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_location.isUpdated(_tempLocation))
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
                child: _deleteLocationButton(),
              ),
          ],
        ),
      );
    });
  }

  Widget _actionButton() {
    Widget buttonContent;
    // INFO: Loading Indicator
    if (_location.id == 0) {
      buttonContent = ElevatedButton.icon(
        onPressed: () async {
          if (_formKey.currentState != null &&
              _formKey.currentState!.validate()) {
            final newLocation = Location(
              id: 0,
              name: _tempLocation.name,
            );

            final newLocationId = await _locationsViewModel.createLocation(newLocation);
            if (newLocationId != 0) {
              _location = newLocation.copyWith(id: newLocationId);
              _tempLocation = _location.copyWith();
            }
            setState(() {});
          }
        },
        style: _locationStatusInactiveTextButtonStyle(kColorAccent),
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
          if (_formKey.currentState != null &&
              _formKey.currentState!.validate()) {
            if (await _locationsViewModel.updateLocation(_tempLocation)) {
              _location = _tempLocation.copyWith();
              _tempLocation = _tempLocation.copyWith();
            }

            setState(() {});
          }
        },
        style: _locationsStatusToggleButtonStyle(kColorUpdate),
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

  // INFO: Delete Location Button
  Widget _deleteLocationButton() {
    Widget buttonContent;
    if (_locationsViewModel.state == LocationsViewState.deleting) {
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
          _locationsViewModel.deleteLocation(_location);
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
}
