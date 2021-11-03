import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../main.dart';

class SliverCircularLoading extends StatelessWidget {
  const SliverCircularLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final themeVM = watch(themeVMProvider);

      return SliverFillRemaining(
        child: Center(
          // alignment: Alignment.bottomCenter,
          child: CircleAvatar(
            backgroundColor: themeVM.mode == ThemeMode.dark
                ? kColorBackgroundDark
                : kColorBackgroundLight,
            radius: 40,
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class LoadWidget extends StatefulWidget {
  @override
  _LoadWidget createState() => _LoadWidget();
}

class _LoadWidget extends State<LoadWidget> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: kColorAccent,
      ),
    );
  }

//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           const CircularProgressIndicator(
// //              valueColor: new AlwaysStoppedAnimation<Color>(
// //                  LIKE_COLOR),
//           ),
// //              SizedBox(height: 30.0,),
// //              Text('Hello')
//         ],
//       ),
//     );
//   }
}

