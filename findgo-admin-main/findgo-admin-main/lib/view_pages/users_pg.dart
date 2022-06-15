// ignore_for_file: use_build_context_synchronously

import 'package:findgo_admin/core/constants.dart';
import 'package:findgo_admin/data_models/managed_user.dart';
import 'package:findgo_admin/data_models/store.dart';
import 'package:findgo_admin/main.dart';
import 'package:findgo_admin/view_models/users_vm.dart';
import 'package:findgo_admin/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

class UsersPage extends ConsumerStatefulWidget {
  final Store store;
  const UsersPage({Key? key, required this.store}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  late UsersViewModel _usersViewModel;
  ManagedUser? _selectedUser;
  ManagedUser? _tempUser;

  final _emailAddressTextEditingController = TextEditingController();

  @override
  void initState() {
    _usersViewModel = ref.read(usersVMProvider);
    _usersViewModel.context = context;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _usersViewModel.getAllStoreUsers(widget.store);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.vRouter.to("/", isReplacement: true),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            widget.store.name,
            style: const TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Consumer(
              builder: (context, ref, _) {
                final usersVM = ref.watch(usersVMProvider);
                usersVM.context = context;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _userListSection(),
                        const SizedBox(width: 60.0),
                        if (_selectedUser != null)
                          _updateUserSection(_tempUser!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // // USERS STORE SECTION
  // bool _addingUser = false;
  // Widget _addUserButton() {
  //   return _usersViewModel.state == UsersViewState.fetchingUser
  //       ? const CircularProgressIndicator()
  //       : SizedBox(
  //           height: 40.0,
  //           width: 130.0,
  //           child: Center(
  //             child: TextButton.icon(
  //               onPressed: () async {
  //                 _addingUser = true;
  //                 setState(() {});
  //               },
  //               icon: const Icon(Icons.add),
  //               label: const Text("Add User"),
  //             ),
  //           ),
  //         );
  // }

  Widget _userListSection() {
    return SizedBox(
      width: 300.0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Users List"),
              // _addUserButton(),
            ],
          ),
          const SizedBox(height: 16.0),
          // if (_addingUser)
          TextField(
            decoration: InputDecoration(
              hintText: 'Search User Email To Add',
              icon: InkWell(
                onTap: () {
                  _getUserFromEmail();
                },
                child: const Icon(Icons.search),
              ),
            ),
            controller: _emailAddressTextEditingController,
            onSubmitted: (_) {
              _getUserFromEmail();
            },
          ),
          // if (_addingUser) const SizedBox(height: 20.0),
          const SizedBox(height: 20.0),
          SizedBox(height: 500, child: _usersListView()),
        ],
      ),
    );
  }

  Widget _usersListView() {
    final storeUsersList = _usersViewModel.storeUsersList;
    return _usersViewModel.state == UsersViewState.busy
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            //scrollDirection: Axis.horizontal,
            itemCount: storeUsersList.length,
            itemBuilder: (context, index) {
              final user = storeUsersList.elementAt(index);
              return Card(
                shape: const ContinuousRectangleBorder(),
                margin: EdgeInsets.zero,
                color: _selectedUser != null && user.uuid == _selectedUser!.uuid
                    ? kColorSelected
                    : kColorCard,
                child: InkWell(
                  canRequestFocus: false,
                  onTap: () async {
                    // if (!await _removeSpecialChanges()) return;

                    _selectedUser = user;
                    _tempUser = user.copyWith();
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user.email),
                        Text(
                          user.managedUserRoleToString(),
                          style: kTextStyleSmallSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Future<void> _getUserFromEmail() async {
    _selectedUser = await _usersViewModel
        .getUserByEmail(_emailAddressTextEditingController.text.trim());
    if (_selectedUser != null) {
      _tempUser = _selectedUser!.copyWith();
    } else {
      _tempUser = null;
      // ignore: use_build_context_synchronously
      InfoSnackBar.show(
        context,
        "No admin user found with matching email",
        color: SnackBarColor.warning,
      );
    }
  }

  // USER PROFILE SECTION
  final _formHeadingTextStyle = const TextStyle(
    fontSize: 12.0,
    color: kColorSecondaryText,
  );
  // List<DropdownMenuItem<ManagedUserRole>> _userRoleList() {
  //   final List<DropdownMenuItem<ManagedUserRole>> items = [
  //     const DropdownMenuItem(
  //       value: ManagedUserRole.none,
  //       child: Text("None"),
  //     ),
  //     const DropdownMenuItem(
  //       value: ManagedUserRole.superAdmin,
  //       child: Text("Super Admin"),
  //     ),
  //     const DropdownMenuItem(
  //       value: ManagedUserRole.admin,
  //       child: Text("Admin"),
  //     ),
  //     const DropdownMenuItem(
  //       value: ManagedUserRole.designer,
  //       child: Text("Designer"),
  //     ),
  //   ];
  //   return items;
  // }

  Widget _updateUserSection(ManagedUser user) {
    return SizedBox(
      width: 360.0,
      child: Column(
        children: [
          const Text(
            "User Profile",
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Card(
            color: kColorSelected,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 300.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email", style: _formHeadingTextStyle),
                    const SizedBox(height: 16.0),
                    Text(user.email),
                    const SizedBox(height: 24.0),
                    Text("Name", style: _formHeadingTextStyle),
                    const SizedBox(height: 16.0),
                    Text("${user.firstName} ${user.lastName}"),
                    // const SizedBox(height: 24.0),
                    //     Text("Role", style: _formHeadingTextStyle),
                    //     DropdownButtonFormField(
                    //       value: user.role,
                    //       items: _userRoleList(),
                    //       onChanged: (role) {
                    //         if (role != null || role != _selectedUser!.role) {
                    //           _tempUser =
                    //               user.copyWith(role: role as ManagedUserRole?);
                    //           setState(() {});
                    //         }
                    //       },
                    //     ),
                    //     if (_selectedUser!.role != user.role)
                    //       const SizedBox(height: 16.0),
                    //     if (_selectedUser!.role != user.role)
                    //       Align(
                    //         alignment: Alignment.centerRight,
                    //         child: _updateUserButton(),
                    //       ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: _actionButton(),
          ),
        ],
      ),
    );
  }

  Widget _actionButton() {
    Widget buttonContent;
    // INFO: Loading Indicator
    if (_usersViewModel.state == UsersViewState.updatingUser) {
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
      // INFO: Add Button
    } else if (!_usersViewModel.storeUsersList.contains(_tempUser)) {
      buttonContent = TextButton.icon(
        onPressed: () async {
          final confirm = await showDialog(
            context: context,
            builder: (tontext) => ConfirmDialog(
              message:
                  "Are you sure you wanto add ${_tempUser!.email} as an Admin  for this restaurant?",
            ),
          ) as bool?;

          if (confirm != null) {
            final success =
                await _usersViewModel.addUserToStore(_tempUser!, widget.store);

            if (success) {
              InfoSnackBar.show(context, "User added to restaurant.");
            }
          }
        },
        icon: const Icon(
          Icons.check,
          color: kColorAccent,
        ),
        label: const Text(
          "Add User",
          style: TextStyle(color: kColorAccent),
        ),
      );
    } else {
      // INFO: Remove Button
      buttonContent = TextButton.icon(
        onPressed: () async {
          final confirm = await showDialog(
            context: context,
            builder: (tontext) => ConfirmDialog(
              message:
                  "Are you sure you wanto remove ${_tempUser!.email} as an Admin for this restaurant?",
            ),
          ) as bool?;

          if (confirm != null) {
            final success = await _usersViewModel.removeUserFromStore(
                _tempUser!, widget.store);
            if (success) {
              InfoSnackBar.show(context, "User removed from restaurant.");
            }
          }
        },
        icon: const Icon(
          Icons.close,
          color: Colors.red,
        ),
        label: const Text(
          "Remove",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return SizedBox(
      height: 40.0,
      width: 140.0,
      child: buttonContent,
    );
  }

  @override
  void dispose() {
    _emailAddressTextEditingController.dispose();
    super.dispose();
  }
}

class ConfirmDialog extends StatelessWidget {
  final String message;
  const ConfirmDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: kColorSecondaryText),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            "Confirm",
            style: TextStyle(
              color: kColorAccent,
            ),
          ),
        ),
      ],
    );
  }
}
