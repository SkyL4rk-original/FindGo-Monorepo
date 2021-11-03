import 'package:flutter/material.dart';
import '../core/constants.dart';

class LoadWidget extends StatefulWidget {
  @override
  _LoadWidget createState() => _LoadWidget();
}

class _LoadWidget extends State<LoadWidget> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: kColorAccent,),
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

