import 'package:findgo/core/constants.dart';
import 'package:findgo/main.dart';
import 'package:findgo/view_models/auth_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

class TermsConditionsPage extends ConsumerStatefulWidget {
  @override
  _TermsConditionsPageState createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends ConsumerState<TermsConditionsPage> {
  @override
  void initState() {
    final _authViewModel = ref.read(authVMProvider);

    // Do after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _authViewModel.getTerms();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer(
        builder: (context, ref, child) {
          final themeVM = ref.read(themeVMProvider);
          final authVM = ref.watch(authVMProvider);

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: themeVM.mode == ThemeMode.dark
                  ? kColorBackgroundDark
                  : kColorBackgroundLight,
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
              title: Text(
                'Terms & Conditions',
                style: TextStyle(
                  color: themeVM.mode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            // backgroundColor: kColorBackground,
            body: authVM.state == AuthViewState.busy
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Html(
                      data: authVM.htmlData,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
