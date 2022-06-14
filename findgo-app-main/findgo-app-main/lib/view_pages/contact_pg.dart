import 'package:findgo/core/constants.dart';
import 'package:findgo/main.dart';
import 'package:findgo/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vrouter/vrouter.dart';

class ContactPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authVM = ref.read(authVMProvider);
    final themeVM = ref.read(themeVMProvider);

    return SafeArea(
      child: Scaffold(
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
              color:
                  themeVM.mode == ThemeMode.dark ? Colors.white : Colors.black,
            ),
          ),
          title: Text(
            'Contact Us',
            style: TextStyle(
              color:
                  themeVM.mode == ThemeMode.dark ? Colors.white : Colors.black,
            ),
          ),
        ),
        // backgroundColor: kColorBackground,
        body: Column(
          children: <Widget>[
            Card(
              color: themeVM.mode == ThemeMode.dark
                  ? kColorCardDark
                  : kColorCardLight,
              margin: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Text(
                        "Experiencing any faults?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        "Submit a support ticket detailing your phone type and error. We will get back to you via the email you have logged in with.",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              color: themeVM.mode == ThemeMode.dark
                  ? kColorCardDark
                  : kColorCardLight,
              margin: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () async {
                  try {
                    String? encodeQueryParameters(Map<String, String> params) {
                      return params.entries
                          .map(
                            (e) =>
                                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                          )
                          .join('&');
                    }

                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'developer@skylarkdigital.co.za',
                      query: encodeQueryParameters(<String, String>{
                        'from': authVM.currentUser.email,
                        'subject': 'FindGo - Fault & Bugs'
                      }),
                    );

                    await launchUrl(emailLaunchUri);
                  } catch (e) {
                    InfoSnackBar.show(
                      context,
                      "Error sending email. Please try again later.",
                      color: SnackBarColor.error,
                    );
                    print(e);
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.email_outlined),
                        const SizedBox(
                          width: 16.0,
                        ),
                        const Text(
                          "SEND EMAIL",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
