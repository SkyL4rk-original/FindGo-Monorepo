import 'package:findgo/core/constants.dart';
import 'package:findgo/main.dart';
import 'package:findgo/view_models/auth_vm.dart';
import 'package:findgo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Watch Providers
        final themeVM = ref.watch(themeVMProvider);
        final authVM = ref.watch(authVMProvider);
        authVM.context = context;

        return Scaffold(
          // backgroundColor: kColorBackground,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  context.vRouter.to("/", isReplacement: true);
                }
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: themeVM.mode == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          body: authVM.state == AuthViewState.fetchingUser
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: SizedBox(
                    width: 300,
                    child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Update my Profile',
                            style: kTextStyleHeading,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        UserInfoUpdateCard(
                          title: const Text('Update Name'),
                          subtitle: Text(
                            "${authVM.currentUser.firstName} ${authVM.currentUser.lastName}",
                            style: const TextStyle(color: kColorAccent),
                          ),
                          formController: UserNameUpdateForm(),
                        ),
                        UserInfoUpdateCard(
                          title: const Text('Update Email'),
                          subtitle: Text(
                            authVM.currentUser.email,
                            style: const TextStyle(color: kColorAccent),
                          ),
                          formController: const EmailUpdateForm(),
                        ),
                        UserInfoUpdateCard(
                          title: const Text('Update Password'),
                          formController: PasswordUpdateForm(),
                        ),
                        const SizedBox(height: 30.0),
                        UserInfoUpdateCard(
                          title: const Text(
                            'Delete Account',
                            style: TextStyle(color: kColorInactive),
                          ),
                          formController: DeleteAccountForm(),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class UserInfoUpdateCard extends StatefulWidget {
  final Widget formController;
  final Text? title;
  final Text? subtitle;
  const UserInfoUpdateCard({
    Key? key,
    required this.formController,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  _UserInfoUpdateCardState createState() => _UserInfoUpdateCardState();
}

class _UserInfoUpdateCardState extends State<UserInfoUpdateCard> {
  bool _formVisible = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final themeVM = ref.watch(themeVMProvider);
        return Card(
          color:
              themeVM.mode == ThemeMode.dark ? kColorCardDark : kColorCardLight,
          child: Column(
            children: <Widget>[
              ListTile(
                title: widget.title,
                subtitle: widget.subtitle,
                onTap: () {
                  setState(() {
                    _formVisible = !_formVisible;
                  });
                },
              ),
              Visibility(
                visible: _formVisible,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24),
                  child: widget.formController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EmailUpdateForm extends StatefulWidget {
  const EmailUpdateForm({Key? key}) : super(key: key);

  @override
  _EmailUpdateFormState createState() => _EmailUpdateFormState();
}

class _EmailUpdateFormState extends State<EmailUpdateForm> {
  final _formKey = GlobalKey<FormState>();

  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Consumer(
        builder: (context, ref, child) {
          final authVM = ref.watch(authVMProvider);
          authVM.context = context;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(bottom: 50.0),
//                  child: Text(
//                    'sign up',
//                    style: Theme.of(context).textTheme.display1,
//                  ),
//                ),

                TextFormField(
                  validator: (email) {
                    if (authVM.isEmail(email)) {
                      return "please enter a valid email";
                    }
                    return email == null || email.isEmpty
                        ? kFieldNotEnteredMessage
                        : null;
                  },
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'new email'),
                  controller: _newEmailController,
                ),
                TextFormField(
                  validator: (password) {
                    if (password != null || password!.isEmpty) {
                      return kFieldNotEnteredMessage;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'confirm password',
                    suffixIcon: GestureDetector(
                      onTap: () async =>
                          setState(() => _hidePassword = !_hidePassword),
                      child: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  obscureText: _hidePassword,
                  controller: _passwordController,
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Builder(
                  builder: (context) => authVM.state == AuthViewState.busy
                      ? LoadWidget()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await authVM.updateEmail(
                                _newEmailController.text.trim(),
                                _passwordController.text.trim(),
                              );

                              _newEmailController.text.trim();
                              _passwordController.clear();
                            }
                          },
                          style:
                              ElevatedButton.styleFrom(primary: kColorAccent),
                          child: const Text('UPDATE'),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class DeleteAccountForm extends StatefulWidget {
  @override
  _DeleteAccountFormState createState() => _DeleteAccountFormState();
}

class _DeleteAccountFormState extends State<DeleteAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Consumer(
        builder: (context, ref, child) {
          final authVM = ref.watch(authVMProvider);
          authVM.context = context;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  validator: (password) {
                    if (password == null || password.isEmpty) {
                      return kFieldNotEnteredMessage;
                    }
                    return null;
                  },
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'confirm password',
                    suffixIcon: GestureDetector(
                      onTap: () async =>
                          setState(() => _hidePassword = !_hidePassword),
                      child: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  obscureText: _hidePassword,
                  controller: _passwordController,
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Builder(
                  builder: (context) => authVM.state == AuthViewState.busy
                      ? LoadWidget()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await authVM.deleteUser(
                                _passwordController.text.trim(),
                              );
                              _passwordController.clear();
                            }
                          },
                          style:
                              ElevatedButton.styleFrom(primary: kColorAccent),
                          child: const Text('Delete'),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _passwordController.dispose();
    super.dispose();
  }
}

class UserNameUpdateForm extends StatefulWidget {
  @override
  _UserNameUpdateFormFormState createState() => _UserNameUpdateFormFormState();
}

class _UserNameUpdateFormFormState extends State<UserNameUpdateForm> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authVM = ref.watch(authVMProvider);
        return Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  validator: (username) {
                    if (username == null || username.isEmpty) {
                      _firstNameController.text = authVM.currentUser.firstName;
                      return null;
                    }
                    return null;
                  },
                  autofocus: true,
                  decoration:
                      InputDecoration(hintText: authVM.currentUser.firstName),
                  controller: _firstNameController,
                ),
                TextFormField(
                  validator: (username) {
                    if (username == null || username.isEmpty) {
                      _lastNameController.text = authVM.currentUser.lastName;
                      return null;
                    }
                    return null;
                  },
                  decoration:
                      InputDecoration(hintText: authVM.currentUser.lastName),
                  controller: _lastNameController,
                ),
                TextFormField(
                  validator: (password) {
                    if (password == null || password.isEmpty) {
                      return kFieldNotEnteredMessage;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'confirm password',
                    suffixIcon: GestureDetector(
                      onTap: () async =>
                          setState(() => _hidePassword = !_hidePassword),
                      child: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  obscureText: _hidePassword,
                  controller: _passwordController,
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Builder(
                  builder: (context) => authVM.state == AuthViewState.busy
                      ? LoadWidget()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await authVM.updateUsername(
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                            }
                            _firstNameController.clear();
                            _lastNameController.clear();
                            _passwordController.clear();
                          },
                          style:
                              ElevatedButton.styleFrom(primary: kColorAccent),
                          child: const Text('UPDATE'),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class PasswordUpdateForm extends StatefulWidget {
  @override
  _PasswordUpdateFormState createState() => _PasswordUpdateFormState();
}

class _PasswordUpdateFormState extends State<PasswordUpdateForm> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmNewPassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Consumer(
        builder: (context, ref, child) {
          final authVM = ref.watch(authVMProvider);
          authVM.context = context;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(bottom: 50.0),
//                  child: Text(
//                    'sign up',
//                    style: Theme.of(context).textTheme.display1,
//                  ),
//                ),

                TextFormField(
                  validator: (newPassword) {
                    if (newPassword == null || newPassword.isEmpty) {
                      return kFieldNotEnteredMessage;
                    } else if (!authVM
                        .checkLengthOfPassword(newPassword.trim())) {
                      return kPasswordNotLongEnough;
                    }
                    return null;
                  },
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'new password',
                    suffixIcon: GestureDetector(
                      onTap: () async =>
                          setState(() => _hideNewPassword = !_hideNewPassword),
                      child: Icon(
                        _hideNewPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  obscureText: _hideNewPassword,
                  controller: _newPasswordController,
                ),
                TextFormField(
                  validator: (confirmPassword) {
                    if (confirmPassword == null || confirmPassword.isEmpty) {
                      return kFieldNotEnteredMessage;
                    } else if (!authVM.checkPasswordsMatch(
                      confirmPassword.trim(),
                      _newPasswordController.text.trim(),
                    )) {
                      return kPasswordMissMatch;
                    }
                    return null;
                  },
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'retype new password',
                    suffixIcon: GestureDetector(
                      onTap: () async => setState(
                        () =>
                            _hideConfirmNewPassword = !_hideConfirmNewPassword,
                      ),
                      child: Icon(
                        _hideConfirmNewPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  obscureText: _hideConfirmNewPassword,
                  controller: _confirmNewPasswordController,
                ),
                TextFormField(
                  validator: (password) {
                    if (password == null || password.isEmpty) {
                      return kFieldNotEnteredMessage;
                    } else if (!authVM.checkLengthOfPassword(password.trim())) {
                      return kPasswordNotLongEnough;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'current password',
                    suffixIcon: GestureDetector(
                      onTap: () async =>
                          setState(() => _hidePassword = !_hidePassword),
                      child: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  obscureText: _hidePassword,
                  controller: _passwordController,
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Builder(
                  builder: (context) => authVM.state == AuthViewState.busy
                      ? LoadWidget()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await authVM.updatePassword(
                                _passwordController.text.trim(),
                                _newPasswordController.text.trim(),
                              );
                              _confirmNewPasswordController.clear();
                              _newPasswordController.clear();
                              _passwordController.clear();
                            }
                          },
                          style:
                              ElevatedButton.styleFrom(primary: kColorAccent),
                          child: const Text('UPDATE'),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _confirmNewPasswordController.dispose();
    _newPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
