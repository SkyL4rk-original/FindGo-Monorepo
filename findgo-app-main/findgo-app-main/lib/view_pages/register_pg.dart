import 'package:findgo/core/constants.dart';
import 'package:findgo/data_models/user.dart';
import 'package:findgo/main.dart';
import 'package:findgo/view_models/auth_vm.dart';
import 'package:findgo/widgets/loading.dart';
import 'package:findgo/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // double _screenWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    // _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // backgroundColor: kColorBackground,
      body: Consumer(
        builder: (context, ref, child) {
          // Watch Providers
          final authVM = ref.watch(authVMProvider);
          authVM.context = context;

          return Center(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Sign Up', style: TextStyle(fontSize: 40.0)),
                      const SizedBox(
                        height: 40.0,
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      const RegisterFormController(),
                      const SizedBox(height: 20.0),
                      if (authVM.state == AuthViewState.busy)
                        LoadWidget()
                      else
                        const SizedBox(),
                      const SizedBox(height: 20.0),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          const Text("Have an account? "),
                          TextButton(
                            onPressed: () async => context.vRouter.to("/login"),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: kColorAccent,
                                fontStyle: FontStyle.italic,
                                // decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RegisterFormController extends StatefulWidget {
  const RegisterFormController({Key? key}) : super(key: key);

  @override
  _RegisterFormControllerState createState() => _RegisterFormControllerState();
}

class _RegisterFormControllerState extends State<RegisterFormController> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _focusNodePassword = FocusNode();
  final _focusNodePasswordConfirm = FocusNode();
  final _focusNodeFirstName = FocusNode();
  final _focusNodeLastName = FocusNode();

  bool _hidePassword = true;
  bool _hideCheckPassword = true;
  bool _termsCheck = false;
  bool _ageCheck = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Consumer(
        builder: (context, ref, child) {
          // Watch Providers
          final authVM = ref.watch(authVMProvider);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  return value == null || value.isEmpty
                      ? kFieldNotEnteredMessage
                      : null;
                },
                onEditingComplete: () => _focusNodeFirstName.requestFocus(),
                decoration: const InputDecoration(
                  hintText: 'email',
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    //                    color: TEXT_COLOR,
                  ),
                ),
                // autofocus: true,
                controller: _emailController,
              ),
              TextFormField(
                validator: (value) {
                  return value == null || value.isEmpty
                      ? kFieldNotEnteredMessage
                      : null;
                },
                onEditingComplete: () => _focusNodeLastName.requestFocus(),
                decoration: const InputDecoration(
                  hintText: 'first name',
                  prefixIcon: Icon(
                    Icons.face,
                    //                    color: TEXT_COLOR,
                  ),
                ),
                focusNode: _focusNodeFirstName,
                controller: _firstNameController,
              ),
              TextFormField(
                validator: (value) {
                  return value == null || value.isEmpty
                      ? kFieldNotEnteredMessage
                      : null;
                },
                onEditingComplete: () => _focusNodePassword.requestFocus(),
                decoration: const InputDecoration(
                  hintText: 'last name',
                  prefixIcon: Icon(
                    Icons.face,
                    //                    color: TEXT_COLOR,
                  ),
                ),
                focusNode: _focusNodeLastName,
                controller: _lastNameController,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return kFieldNotEnteredMessage;
                  } else if (value.trim().length < 6) {
                    return kPasswordNotLongEnough;
                  }
                  return null;
                },
                onEditingComplete: () =>
                    _focusNodePasswordConfirm.requestFocus(),
                decoration: InputDecoration(
                  hintText: 'password (min 6 characters)',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    //                    color: TEXT_COLOR,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () async =>
                        setState(() => _hidePassword = !_hidePassword),
                    // onTapDown: (_) async => setState(() => _hidePassword = false),
                    // onTapUp: (_) async => setState(() => _hidePassword = true),
                    child: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                focusNode: _focusNodePassword,
                obscureText: _hidePassword,
                controller: _passwordController,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return kFieldNotEnteredMessage;

                    // Check password length longer than or equal to 6 characters
                  } else if (!authVM.checkLengthOfPassword(value)) {
                    return kPasswordNotLongEnough;

                    // Check passwords match
                  } else if (!authVM.checkPasswordsMatch(
                    value.trim(),
                    _passwordController.text.trim(),
                  )) {
                    return kPasswordMissMatch;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'retype password',
                  prefixIcon: const Icon(
                    Icons.lock_open,
//                    color: TEXT_COLOR,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () async => setState(
                      () => _hideCheckPassword = !_hideCheckPassword,
                    ),
                    // onTapDown: (_) async => setState(() => _hideCheckPassword = false),
                    // onTapUp: (_) async => setState(() => _hideCheckPassword = true),
                    child: Icon(
                      _hideCheckPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                focusNode: _focusNodePasswordConfirm,
                obscureText: _hideCheckPassword,
                controller: _passwordConfirmController,
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                width: 240,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      activeColor: kColorAccent,
                      checkColor: Colors.white,
                      value: _termsCheck,
                      onChanged: (checked) => checked != null
                          ? setState(() {
                              _termsCheck = checked;
                            })
                          : null,
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    const Text("Accept Terms and Conditions"),
                  ],
                ),
              ),
              SizedBox(
                width: 240,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      activeColor: kColorAccent,
                      checkColor: Colors.white,
                      value: _ageCheck,
                      onChanged: (checked) => checked != null
                          ? setState(() {
                              _ageCheck = checked;
                            })
                          : null,
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    const Text("I'm over the age of 13 years   "),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    print("CALLED PG");
                    if (!_termsCheck) {
                      InfoSnackBar.show(
                        context,
                        "Please confirm you have read the terms and conditions",
                        color: SnackBarColor.error,
                      );
                    }
                    if (!_ageCheck) {
                      InfoSnackBar.show(
                        context,
                        "Please confirm you are over the age of 13 years",
                        color: SnackBarColor.error,
                      );
                    }
                    if (_formKey.currentState!.validate()) {
                      final user = User(
                        uuid: "",
                        email: _emailController.text.trim(),
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        password: _passwordController.text.trim(),
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      //print("CALLED PG");
                      await authVM.signUpUser(user);
                    }
                    _passwordController.clear();
                    _passwordConfirmController.clear();
                  },
                  style: ElevatedButton.styleFrom(primary: kColorAccent),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
