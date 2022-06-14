import 'package:findgo_admin/core/constants.dart';
import 'package:findgo_admin/main.dart';
import 'package:findgo_admin/view_models/auth_vm.dart';
import 'package:findgo_admin/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authVM = ref.read(authVMProvider);
    authVM.context = context;

    return Scaffold(
      backgroundColor: kColorBackground,
      body: Scrollbar(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 40.0,
                  ), //color: TEXT_COLOR
                ),
                const SizedBox(
                  height: 40.0,
                ),
                const Center(
                  child: SizedBox(
                    width: 300.0,
                    child: LoginFormController(),
                  ),
                ),
                const SizedBox(height: 40.0),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Forgot password?  ",
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () async => context.vRouter
                          .to("/password-reset", isReplacement: true),
                      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const PasswordResetPage())),
                      child: const Text(
                        'Password Reset',
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
  }
}

const String kFieldNotEnteredMessage = 'Field cannot be left empty';

class LoginFormController extends StatefulWidget {
  const LoginFormController();
  @override
  _LoginFormControllerState createState() => _LoginFormControllerState();
}

class _LoginFormControllerState extends State<LoginFormController> {
  final _formKey = GlobalKey<FormState>();
  final _focusNodeEmail = FocusNode();
  final _focusNodePassword = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Consumer(
        builder: (context, ref, _) {
          // Watch Providers
          final authVM = ref.watch(authVMProvider);
          authVM.context = context;

          return Column(
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  return value == null ? kFieldNotEnteredMessage : null;
                },
                // onEditingComplete: () => _focusNodePassword.requestFocus(),
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
                onFieldSubmitted: (_) {
                  if (_passwordController.text.isNotEmpty &&
                      _emailController.text.isNotEmpty) {
                    _submitLogin(authVM);
                  } else if (_passwordController.text.isEmpty) {
                    _focusNodePassword.requestFocus();
                  }
                },
                focusNode: _focusNodeEmail,
                autofocus: true,
                // autofillHints: [AutofillHints.email],
                controller: _emailController,
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextFormField(
                validator: (value) {
                  return value == null ? kFieldNotEnteredMessage : null;
                },
                style: const TextStyle(fontSize: 18.0),
                decoration: InputDecoration(
                  hintText: 'password',
//                  hintStyle: TextStyle(fontSize: 18.0, color: TEXT_COLOR),
//                  counterStyle: TextStyle(color: TEXT_COLOR),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
//                    color: TEXT_COLOR,
                  ),
//                   suffixIcon: IconButton(
//                       onPressed: () async => setState(() => _hidePassword = !_hidePassword),
//                       icon: const Icon(
//                         Icons.remove_red_eye_outlined,
// //                    color: TEXT_COLOR,
//                       ),
//                   ),
                  suffixIcon: GestureDetector(
                    onTap: () async =>
                        setState(() => _hidePassword = !_hidePassword),
                    child: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
//                    color: TEXT_COLOR,
                    ),
                  ),
//                  labelStyle: TextStyle(color: TEXT_COLOR),
//                  enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: TEXT_CONTENT_COLOR),
//                  ),
//                  focusedBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: LIKE_COLOR),
//                  ),
                ),
                onFieldSubmitted: (_) => _submitLogin(authVM),
                focusNode: _focusNodePassword,
                obscureText: _hidePassword,
                // autofillHints: [AutofillHints.password],
                controller: _passwordController,
              ),
              const SizedBox(height: 50.0),
              if (authVM.state == AuthViewState.busy)
                LoadWidget()
              else
                ElevatedButton(
                  //style: TextStyle(color: TILE_DIV_LINE_COLOR)
                  onPressed: () => _submitLogin(authVM),
                  style: ElevatedButton.styleFrom(primary: kColorAccent),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitLogin(AuthViewModel authVM) async {
    if (_formKey.currentState!.validate()) {
      await authVM.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      _passwordController.clear();
      _focusNodeEmail.requestFocus();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
