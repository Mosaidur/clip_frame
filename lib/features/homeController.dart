import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  var isPopupVisible = false.obs;

  final List<Widget> pages = [
    Center(child: Text('Dashboard')),
    Center(child: Text('Posts')),
    Center(child: Text('Schedules')),
    Center(child: Text('My Profile')),
  ];

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  void togglePopup() {
    isPopupVisible.value = !isPopupVisible.value;
  }
}