import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import '../core/constants.dart';
import '../main.dart';
import '../view_models/auth_vm.dart';
import '../view_models/specials_vm.dart';
import '../view_models/stores_vm.dart';
import '../widgets/loading.dart';

class LoginPage extends StatelessWidget {
  const LoginPage();

  @override
  Widget build(BuildContext context) {
    final authVM = context.read(authVMProvider);
    authVM.context = context;

    return Scaffold(
        // backgroundColor: kColorBackground,
        body: Center(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Login',
                    style: TextStyle(
                      fontSize: 40.0,
                    ), //color: TEXT_COLOR
                  ),
                  const SizedBox(height: 40.0,),
                  const Center(
                    child: SizedBox(
                      width: 300.0,
                        child: LoginFormController()
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      const Text("No account? "),
                      TextButton(
                        onPressed: () async => context.vRouter.to("/sign-up"),
                        child: const Text('Sign Up',
                          style: TextStyle(
                            color: kColorAccent,
                            fontStyle: FontStyle.italic,
                            // decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      const Text("Forgot password?  ", textAlign: TextAlign.center,),
                      TextButton(
                        onPressed: () async => context.vRouter.to("/password-reset"),
                        child: const Text('Password Reset',
                          style: TextStyle(
                            color: kColorAccent,
                            fontStyle: FontStyle.italic,
                            // decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async => context.vRouter.to("/terms-conditions"),
                    child: const Text('Terms & Conditions',
                      style: TextStyle(
                        color: kColorAccent,
                        fontStyle: FontStyle.italic,
                        // decoration: TextDecoration.underline,
                      ),
                    ),
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
  late SpecialsViewModel _specialsViewModel;
  late StoresViewModel _storesViewModel;

  final _formKey = GlobalKey<FormState>();
  final _focusNodePassword = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void initState() {
    _specialsViewModel = context.read(specialsVMProvider);
    _storesViewModel = context.read(storesVMProvider);

    _specialsViewModel.clearSpecialsList();
    _storesViewModel.clearStoreList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Consumer(
          builder: (context, watch, child) {
            // Watch Providers
            final authVM = watch(authVMProvider);
            authVM.context = context;

            return Column(
              children: <Widget>[
                TextFormField(
                  validator: (value) => value == null || value.isEmpty ? kFieldNotEnteredMessage : null,
                  onEditingComplete: () => _focusNodePassword.requestFocus(),
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
                  // autofocus: true,
                  autofillHints: [AutofillHints.email],
                  controller: _emailController,
                ),
                const SizedBox(height: 10.0,),
                TextFormField(
                  validator: (value) => value == null || value.isEmpty ? kFieldNotEnteredMessage : null,
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
                      onTap: () async => setState(() => _hidePassword = !_hidePassword),
                      child: Icon(
                        _hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                  focusNode: _focusNodePassword,
                  obscureText: _hidePassword,
                  // autofillHints: [AutofillHints.password],
                  controller: _passwordController,
                ),
                const SizedBox(height: 50.0),
                if (authVM.state == AuthViewState.busy) LoadWidget()
                else ElevatedButton( //style: TextStyle(color: TILE_DIV_LINE_COLOR)
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authVM.loginUser(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                      );

                      _passwordController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(primary: kColorAccent),
                  child: const Text('LOGIN', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
