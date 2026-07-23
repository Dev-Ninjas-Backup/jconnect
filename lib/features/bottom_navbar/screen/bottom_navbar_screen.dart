import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/bottom_navbar/controller/bottom_navbar_controller.dart';
import 'package:jconnect/features/home/home_screen/screen/home_page.dart';
import 'package:jconnect/features/messages/screen/messages_screen.dart';
import 'package:jconnect/features/my_orders/screen/my_orders_screen.dart';
import 'package:jconnect/features/search_screen/screen/search_screen.dart';
import 'package:jconnect/features/user_profile/profile/screen/profile_screen.dart';

class NavBarScreen extends StatelessWidget {
  const NavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavBarController controller = Get.put(NavBarController());

    final List<Widget> pages = [
      HomePage(),
      MessagesScreen(),
      SearchScreen(),
      MyOrdersScreen(),
      ProfileScreen(),
    ];

    return Obx(
      () => pages[controller.currentIndex.value],
    );
  }
}
