import 'package:findgo_admin/core/constants.dart';
import 'package:findgo_admin/main.dart';
import 'package:findgo_admin/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyPage extends ConsumerWidget {
  final String code;
  const VerifyPage({required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authVM = ref.read(authVMProvider);
    authVM.context = context;
    authVM.verifyUser(code);

    return Scaffold(
      backgroundColor: kColorBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Verifing User',
              style: TextStyle(
                fontSize: 40.0,
              ), //color: TEXT_COLOR
            ),
            const SizedBox(height: 40.0),
            Center(
              child: SizedBox(
                width: 300.0,
                child: LoadWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
