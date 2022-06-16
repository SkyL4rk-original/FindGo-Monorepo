import 'package:findgo/core/constants.dart';
import 'package:findgo/main.dart';
import 'package:findgo/view_models/auth_vm.dart';
import 'package:findgo/widgets/loading.dart';
import 'package:findgo/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:vrouter/vrouter.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  // double _screenWidth = 0.0;
  bool _hasCode = false;

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height - 160,
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 50.0),
                            child: Text(
                              'Password Reset',
                              style: TextStyle(
                                fontSize: 40.0,
                              ), //color: TEXT_COLOR
                            ),
                          ),
                          if (!_hasCode)
                            _passwordResetEmailForm()
                          else
                            PasswordResetPasswordFormController(),
                          const SizedBox(height: 20.0),
                          if (authVM.state == AuthViewState.busy)
                            LoadWidget()
                          else
                            const SizedBox(),
                          const SizedBox(height: 40.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (_hasCode)
                                TextButton(
                                  onPressed: () async =>
                                      setState(() => _hasCode = false),
                                  child: const Text(
                                    "Get new code",
                                    style: TextStyle(
                                      color: kColorAccent,
                                      fontStyle: FontStyle.italic,
                                      // decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              if (!_hasCode)
                                TextButton(
                                  onPressed: () async =>
                                      setState(() => _hasCode = true),
                                  child: const Text(
                                    "I have a code",
                                    style: TextStyle(
                                      color: kColorAccent,
                                      fontStyle: FontStyle.italic,
                                      // decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text("I remember my password "),
                              TextButton(
                                onPressed: () async =>
                                    context.vRouter.to("/login"),
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  Widget _passwordResetEmailForm() {
    return Form(
      key: _formKey,
      child: Consumer(
        builder: (context, ref, child) {
          // Watch Providers
          final authVM = ref.watch(authVMProvider);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                validator: (value) => value == null || value.isEmpty
                    ? kFieldNotEnteredMessage
                    : null,
                style: const TextStyle(fontSize: 18.0),
                decoration: const InputDecoration(
                  hintText: 'email',
//                  hintStyle: TextStyle(fontSize: 18.0, color: TEXT_COLOR),
//                  helperStyle: TextStyle(fontSize: 18.0, color: TEXT_COLOR),
                  prefixIcon: Icon(
                    Icons.mail_outline,
//                    color: TEXT_COLOR,
                  ),
//                  enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: TEXT_CONTENT_COLOR),
//                  ),
//                  focusedBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: LIKE_COLOR),
//                  ),
                ),
                autofillHints: [AutofillHints.email],
                controller: _emailController,
              ),
              const SizedBox(height: 16.0),
              Wrap(
                children: [
                  const Text(
                    "Enter email for the account you want to reset the password for and a recovery code will be sent to that email",
                    style: kTextStyleSmallSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                //style: TextStyle(color: TILE_DIV_LINE_COLOR)
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _hasCode = await authVM.passwordResetRequest(
                      _emailController.text.trim(),
                    );
                    if (_hasCode) setState(() {});
                    _emailController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(primary: kColorAccent),
                child: const Text(
                  'SEND EMAIL',
                  style: TextStyle(color: Colors.white),
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
    super.dispose();
  }
}

const String kFieldNotEnteredMessage = 'Field cannot be left empty';

class PasswordResetPasswordFormController extends StatefulWidget {
  @override
  _PasswordResetPasswordFormControllerState createState() =>
      _PasswordResetPasswordFormControllerState();
}

class _PasswordResetPasswordFormControllerState
    extends State<PasswordResetPasswordFormController> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _retypePwFocusNode = FocusNode();

  bool _hidePassword = true;
  bool _hideCheckPassword = true;

  PinTheme _pinPutTheme(double radius) {
    return PinTheme(
      height: 60.0,
      width: 60.0,
      decoration: BoxDecoration(
        border: Border.all(color: kColorAccent),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

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
              const Text(
                "Enter Code Below",
                style: kTextStyleSubHeading,
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                height: 60.0,
                child: Pinput(
                  length: 6,
                  // onSubmit: (String pin) => _showSnackBar(pin, context),
                  focusNode: _pinPutFocusNode,
                  controller: _pinPutController,
                  submittedPinTheme: _pinPutTheme(40.0),
                  errorPinTheme: _pinPutTheme(0.0),
                  disabledPinTheme: _pinPutTheme(0.0),
                  defaultPinTheme: _pinPutTheme(10.0),
                  followingPinTheme: _pinPutTheme(10.0),
                  focusedPinTheme: _pinPutTheme(10.0),
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return kFieldNotEnteredMessage;
                  } else if (value.trim().length < 6) {
                    return kPasswordNotLongEnough;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'new password (min 6 characters)',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    //                    color: TEXT_COLOR,
                  ),
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
                onFieldSubmitted: (_) => _retypePwFocusNode.requestFocus(),
                obscureText: _hidePassword,
                focusNode: _passwordFocusNode,
                controller: _passwordController,
              ),
              const SizedBox(height: 16.0),
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
                    child: Icon(
                      _hideCheckPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                onFieldSubmitted: (_) => resetPassword(authVM),
                obscureText: _hideCheckPassword,
                focusNode: _retypePwFocusNode,
                controller: _passwordConfirmController,
              ),
              const SizedBox(height: 30.0),
              Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => resetPassword(authVM),
                  style: ElevatedButton.styleFrom(primary: kColorAccent),
                  child: const Text(
                    'RESET PASSWORD',
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

  Future<void> resetPassword(AuthViewModel authVM) async {
    final code = _pinPutController.text.trim();
    if (code.isEmpty || code.length < 6) {
      InfoSnackBar.show(
        context,
        "Please enter the code sent to your email",
        color: SnackBarColor.error,
      );
    }
    if (_formKey.currentState!.validate()) {
      await authVM.passwordReset(
        _passwordController.text.trim(),
        _pinPutController.text.trim(),
      );
    }
    // _passwordController.clear();
    // _passwordConfirmController.clear();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
    _passwordFocusNode.dispose();
    _retypePwFocusNode.dispose();
    super.dispose();
  }
}
