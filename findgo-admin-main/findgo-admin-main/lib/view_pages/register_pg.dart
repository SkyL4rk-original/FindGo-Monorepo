import 'package:findgo_admin/core/constants.dart';
import 'package:findgo_admin/data_models/user.dart';
import 'package:findgo_admin/main.dart';
import 'package:findgo_admin/view_models/auth_vm.dart';
import 'package:findgo_admin/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerWidget {
  final bool fromAdmin;
  const RegisterPage({this.fromAdmin = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authVM = ref.read(authVMProvider);
    authVM.context = context;

    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: fromAdmin
          ? AppBar(
              leading: BackButton(
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: Scrollbar(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.asset('assets/logo.png', height: 40.0),
                    ),
                    const SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 30.0,
                          ), //color: TEXT_COLOR
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'FindGo Admin',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: kColorSecondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40.0),
                const Center(
                  child: SizedBox(
                    width: 300.0,
                    child: RegisterFormController(),
                  ),
                ),
                // const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String kFieldNotEnteredMessage = 'Field cannot be left empty';

class RegisterFormController extends StatefulWidget {
  const RegisterFormController();
  @override
  _RegisterFormControllerState createState() => _RegisterFormControllerState();
}

class _RegisterFormControllerState extends State<RegisterFormController> {
  final _formKey = GlobalKey<FormState>();

  final _focusNodeEmail = FocusNode();
  final _focusNodePassword = FocusNode();
  final _focusNodeConfirmPassword = FocusNode();
  final _focusNodeFirstName = FocusNode();
  final _focusNodeLastName = FocusNode();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  bool _showConfirmEmailMessage = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Consumer(
        builder: (context, ref, _) {
          // Watch Providers
          final authVM = ref.watch(authVMProvider);
          authVM.context = context;

          if (_showConfirmEmailMessage) {
            return const Center(
              child: Text(
                "Please check your email to verify the new account.",
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (authVM.isNotEmail(value)) {
                    return "Not a valid email address";
                  }

                  return value == null || value.isEmpty
                      ? kFieldNotEnteredMessage
                      : null;
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
                onFieldSubmitted: (_) => _focusNodePassword.requestFocus(),
                focusNode: _focusNodeEmail,
                autofocus: true,
                // autofillHints: [AutofillHints.email],
                controller: _emailController,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return kFieldNotEnteredMessage;
                  }
                  if (!authVM.checkLengthOfPassword(value)) {
                    return kPasswordNotLongEnough;
                  }
                  return null;
                },
                style: const TextStyle(fontSize: 18.0),
                decoration: InputDecoration(
                  hintText: 'password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
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
                onFieldSubmitted: (_) =>
                    _focusNodeConfirmPassword.requestFocus(),
                focusNode: _focusNodePassword,
                obscureText: _hidePassword,
                // autofillHints: [AutofillHints.password],
                controller: _passwordController,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return kFieldNotEnteredMessage;
                  }
                  if (!authVM.checkPasswordsMatch(
                    _passwordController.text.trim(),
                    value,
                  )) {
                    return kPasswordMissMatch;
                  }
                  return null;
                },
                style: const TextStyle(fontSize: 18.0),
                decoration: InputDecoration(
                  hintText: 'confirm password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () async => setState(
                      () => _hideConfirmPassword = !_hideConfirmPassword,
                    ),
                    child: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                onFieldSubmitted: (_) => _focusNodeFirstName.requestFocus(),
                focusNode: _focusNodeConfirmPassword,
                obscureText: _hideConfirmPassword,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                validator: (value) {
                  return value == null || value.isEmpty
                      ? kFieldNotEnteredMessage
                      : null;
                },
                style: const TextStyle(fontSize: 18.0),
                decoration: const InputDecoration(
                  hintText: 'first name',
                  prefixIcon: Icon(Icons.face),
                ),
                onFieldSubmitted: (_) => _focusNodeLastName.requestFocus(),
                focusNode: _focusNodeFirstName,
                controller: _firstNameController,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                validator: (value) {
                  return value == null || value.isEmpty
                      ? kFieldNotEnteredMessage
                      : null;
                },
                style: const TextStyle(fontSize: 18.0),
                decoration: const InputDecoration(
                  hintText: 'last name',
                  prefixIcon: Icon(Icons.face),
                ),
                // onFieldSubmitted: (_) => _focusNodeLastName.requestFocus(),
                focusNode: _focusNodeLastName,
                controller: _lastNameController,
              ),
              const SizedBox(height: 50.0),
              if (authVM.state == AuthViewState.busy)
                LoadWidget()
              else
                ElevatedButton(
                  //style: TextStyle(color: TILE_DIV_LINE_COLOR)
                  onPressed: () => _submitRegister(authVM),
                  style: ElevatedButton.styleFrom(primary: kColorAccent),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitRegister(AuthViewModel authVM) async {
    if (_formKey.currentState!.validate()) {
      final user = User(
        uuid: "",
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: "storeAdmin",
        active: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final success = await authVM.registerUser(user);
      // _passwordController.clear();
      // _confirmPasswordController.clear();
      _focusNodeEmail.requestFocus();

      if (success) _showConfirmEmailMessage = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
