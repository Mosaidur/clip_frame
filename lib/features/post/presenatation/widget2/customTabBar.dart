// import 'package:clip_frame/features/post/presenatation/widget2/reelsScrollContent.dart';
// import 'package:flutter/material.dart';
//
// import '../screen/postScrollPage.dart';
// import '../screen/reelsScrollPage.dart';
//
//
// class CustomTabBar extends StatelessWidget {
//   const CustomTabBar({super.key});
//
//   final List<String> tabs = const ["Reels", "Posts", "Stories"];
//
//   void _onTabSelected(BuildContext context, String tab) {
//     if (tab == "Posts") {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const PostScrollPage()),
//       );
//     } else if (tab == "Reels") {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const Reelsscrollpage()),
//       );
//     } else if (tab == "Stories") {
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(builder: (context) => const StoriesScreen()),
//       // );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: List.generate(tabs.length, (index) {
//           final bool isSelected = index == 0; // default selected first tab
//           return GestureDetector(
//             onTap: () => _onTabSelected(context, tabs[index]),
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(30),
//                 color: isSelected ? const Color(0xFFFF277F) : Colors.transparent,
//                 border: Border.all(
//                   color: isSelected ? const Color(0xFFFF277F) : Colors.transparent,
//                 ),
//               ),
//               child: Text(
//                 tabs[index],
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : const Color(0xFF6D6D73),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }




import 'package:clip_frame/features/post/presenatation/widget2/reelsScrollContent.dart';
import 'package:flutter/material.dart';

import '../screen/postScrollPage.dart';
import '../screen/reelsScrollPage.dart';
import '../screen/storyScrollPage.dart';

// Global variable to store selected tab
String selectedTab = "Reels";

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  final List<String> tabs = const ["Reels", "Posts", "Stories"];

  void _onTabSelected(BuildContext context, String tab) {
    selectedTab = tab; // update global selected tab

    if (tab == "Posts") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PostScrollPage()),
      );
    } else if (tab == "Reels") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Reelsscrollpage()),
      );
    } else if (tab == "Stories") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StoryScrollPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(tabs.length, (index) {
          final bool isSelected = tabs[index] == selectedTab; // use global variable
          return GestureDetector(
            onTap: () => _onTabSelected(context, tabs[index]),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: isSelected ? const Color(0xFFFF277F) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF277F) : Colors.transparent,
                ),
              ),
              child: Text(
                tabs[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6D6D73),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
