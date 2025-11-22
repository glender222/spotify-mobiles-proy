import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/presentation/controllers/home/home_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController = Get.find<HomeController>();
    return Obx(() => NavigationBar(
            onDestinationSelected: HomeController.onBottonBarTabSelected,
            selectedIndex: HomeController.tabIndex.toInt(),
            backgroundColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                selectedIcon: const Icon(Icons.home),
                icon: const Icon(Icons.home_outlined),
                label: modifyNgetlabel('home'.tr),
              ),
              NavigationDestination(
                icon: const Icon(Icons.search),
                label: modifyNgetlabel('search'.tr),
              ),
              NavigationDestination(
                icon: const Icon(Icons.library_music),
                label: modifyNgetlabel('library'.tr),
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings),
                label: modifyNgetlabel('settings'.tr),
              ),
            ]));
  }

  String modifyNgetlabel(String label) {
    if (label.length > 9) {
      return "${label.substring(0, 8)}..";
    }
    return label;
  }
}
