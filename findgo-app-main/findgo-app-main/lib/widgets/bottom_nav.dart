import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import '../core/constants.dart';
import '../main.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final specialVM = watch(specialsVMProvider);
      final themeVM = watch(themeVMProvider);

      return BottomNavigationBar(
          backgroundColor:
              themeVM.mode == ThemeMode.dark ? kColorCardDark : kColorCardLight,
          selectedItemColor: kColorAccent,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          unselectedItemColor:
              themeVM.mode == ThemeMode.dark ? Colors.white : Colors.black,
          onTap: (index) async {
            if (currentIndex != 0 && index == 0) {
              // await filterVM.initFilterSpecialList();
              context.vRouter.to("/all", isReplacement: true);
            }
            if (currentIndex != 1 && index == 1) {
              // await filterVM.initFilterSpecialList(filterFollowing: true);
              context.vRouter.to("/", isReplacement: true);
            }
            if (currentIndex != 2 && index == 2) {
              if (specialVM.savedSpecialsUuidSet.isEmpty) {
                await specialVM.getAllSavedSpecials();
              }
              // await filterVM.initFilterSpecialList(filterSaved: true);
              context.vRouter.to("/saved", isReplacement: true);
            }
            if (currentIndex != 3 && index == 3) {
              context.vRouter.to("/brands", isReplacement: true);
            }
            if (currentIndex != 4 && index == 4) {
              context.vRouter.to("/map", isReplacement: true);
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.all_inclusive),
              label: "All",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.follow_the_signs),
              label: "Following",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              label: "Saved",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Brands",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: "Map",
            ),
          ]);
    });
  }
}
