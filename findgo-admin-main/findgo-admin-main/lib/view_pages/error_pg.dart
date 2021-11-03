import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../main.dart';
import '../view_models/auth_vm.dart';

class ErrorPage extends StatefulWidget {
  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  // double _screenWidth = 0.0;
  
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      // _screenWidth = MediaQuery.of(context).size.width;

      final authVM = watch(authVMProvider);
      authVM.context = context;

      return authVM.state == AuthViewState.fetchingUser
          ? const Scaffold(
            backgroundColor: kColorBackground,
            body: Center(child: CircularProgressIndicator()),)
          : Scaffold(
              backgroundColor: kColorBackground,
              body: Scrollbar(
                isAlwaysShown: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height > 450.0
                            ? MediaQuery.of(context).size.height - 210.0
                            : null,
                        child: _errorSection(),
                      ),
                    ],
                  ),
                ),
              ),
          );
    });
  }

  Widget _errorSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: kColorError,),
          const SizedBox(height: 40.0,),
          const Text("Something Went Wrong", style: TextStyle(color: kColorError, fontSize: 20), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}