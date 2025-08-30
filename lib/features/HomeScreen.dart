import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import 'homeController.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int selectedIndex = 0;
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Widget> pages = [
    Center(child: Text("Dashboard Page")),
    Center(child: Text("Post Page")),
    Center(child: Text("Schedules Page")),
    Center(child: Text("Profile Page")),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void toggleExpand() {
    if (isExpanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildFloatingOptions() {
    return Positioned(
      bottom: 70,
      left: MediaQuery.of(context).size.width / 2 - 90,
      child: SizeTransition(
        sizeFactor: _animation,
        axisAlignment: -1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            floatingButton("Post", Icons.post_add),
            SizedBox(width: 15),
            floatingButton("Reels", Icons.movie),
            SizedBox(width: 15),
            floatingButton("Story", Icons.history_edu),
          ],
        ),
      ),
    );
  }

  Widget floatingButton(String label, IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF277F), Color(0xFF007CFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {
          print('$label clicked');
          // Navigate to respective page if needed
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pages[selectedIndex],
          buildFloatingOptions(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.dashboard, 0, "Dashboard"),
            navItem(Icons.note, 1, "Posts"),
            SizedBox(width: 60), // space for central button
            navItem(Icons.schedule, 2, "Schedules"),
            navItem(Icons.person, 3, "Profile"),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: toggleExpand,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF277F), Color(0xFF007CFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add,
            size: 35,
            color: isExpanded
                ? LinearGradient(
              colors: [Color(0xFFFF277F), Color(0xFF007CFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, 70, 70)) !=
                null
                ? Colors.white
                : Colors.white
                : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget navItem(IconData icon, int index, String label) {
    bool selected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? Color(0xFF007CFE) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: selected ? Color(0xFF007CFE) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}