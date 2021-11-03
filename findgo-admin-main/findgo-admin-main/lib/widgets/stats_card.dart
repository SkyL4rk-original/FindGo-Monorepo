import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../data_models/special.dart';
import '../main.dart';
import '../view_models/specials_vm.dart';

class SpecialStatsCard extends StatefulWidget {
  final Special special;
  const SpecialStatsCard({Key? key, required this.special}) : super(key: key);

  @override
  _SpecialStatsCardState createState() => _SpecialStatsCardState();
}

class _SpecialStatsCardState extends State<SpecialStatsCard> {
  late Special _special;

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, watch, child) {
          final specialVM = watch(specialsVMProvider);

          _special = specialVM.specialsList.firstWhere((special) => special.uuid == widget.special.uuid);
          return Column(
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  splashRadius: 24.0,
                  onPressed: () async {
                    await specialVM.getAllSpecials();
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white,),
                ),
                const Expanded(child: Center(child: Text("Stats"))),
                const SizedBox(width: 40.0)
              ],
            ),
            const SizedBox(height: 8.0),
              if (specialVM.state == SpecialViewState.busy) const CircularProgressIndicator() else Card(
              color: kColorSelected,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                      children: [
                        Row(
                          children: [
                            // _statCard(title: "Impressions", number:_special.impressions),
                            _statCard(title: "Clicks", number: _special.clicks),
                            _statCard(title: "Phone Clicks", number: _special.phoneClicks),
                            _statCard(title: "Saved Clicks", number: _special.savedClicks),
                          ],
                        ),
                        const SizedBox(height: 8.0,),
                        Row(
                          children: [
                            // _statCard(title: "Saved Clicks", number: _special.savedClicks),
                            _statCard(title: "Shared Clicks", number: _special.shareClicks),
                            _statCard(title: "Website Clicks", number: _special.websiteClicks),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                    ),
                ),
              ),
          ],
        );
      }
    );
  }

  final _formHeadingTextStyle = const TextStyle(
      fontSize: 12.0,
      color: kColorSecondaryText
  );

  Widget _statCard({required String title, required num number}) {
    return Expanded(
      child: Column(
          children: [
            Text(title, style: _formHeadingTextStyle,),
            const SizedBox(height: 8.0),
            Text(number.toString(), style: const TextStyle(fontSize: 12),),
          ],
      ),
    );
  }
}

//
// class StoreStatsCard extends StatefulWidget {
//   final Store store;
//   const StoreStatsCard({Key? key, required this.store}) : super(key: key);
//
//   @override
//   _StoreStatsCardState createState() => _StoreStatsCardState();
// }
//
// class _StoreStatsCardState extends State<StoreStatsCard> {
//   late Store _store;
//
//   int impressions = 0;
//   int clicks = 0;
//   int phoneClicks = 0;
//   int impressions = 0;
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//         builder: (context, watch, child) {
//           final specialVM = watch(specialsVMProvider);
//
//
//
//
//           return Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     splashRadius: 24.0,
//                     onPressed: () async {
//                       await specialVM.getAllSpecials();
//                       setState(() {});
//                     },
//                     icon: const Icon(Icons.refresh, color: Colors.white,),
//                   ),
//                   const Expanded(child: Center(child: Text("Stats"))),
//                   const SizedBox(width: 40.0)
//                 ],
//               ),
//               const SizedBox(height: 8.0),
//               if (specialVM.state == SpecialViewState.busy) const CircularProgressIndicator() else Card(
//                 color: kColorSelected,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           _statCard(title: "Impressions", number:_special.impressions),
//                           _statCard(title: "Clicks", number: _special.clicks),
//                           _statCard(title: "Phone Clicks", number: _special.phoneClicks),
//                         ],
//                       ),
//                       const SizedBox(height: 8.0,),
//                       Row(
//                         children: [
//                           _statCard(title: "Saved Clicks", number: _special.savedClicks),
//                           _statCard(title: "Shared Clicks", number: _special.shareClicks),
//                           _statCard(title: "Website Clicks", number: _special.websiteClicks),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }
//     );
//   }
//
//   final _formHeadingTextStyle = const TextStyle(
//       fontSize: 12.0,
//       color: kColorSecondaryText
//   );
//
//   Widget _statCard({required String title, required num number}) {
//     return Expanded(
//       child: Column(
//         children: [
//           Text(title, style: _formHeadingTextStyle,),
//           const SizedBox(height: 8.0),
//           Text(number.toString(), style: const TextStyle(fontSize: 12),),
//         ],
//       ),
//     );
//   }
// }