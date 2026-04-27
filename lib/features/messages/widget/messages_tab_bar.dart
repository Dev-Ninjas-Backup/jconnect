// import 'package:flutter/material.dart';
// import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
// import 'package:jconnect/core/common/constants/app_colors.dart';
// import 'package:jconnect/features/messages/controller/messages_controller.dart';

// class MessagesTabBar extends StatelessWidget {
//   final MessagesController controller;
//   const MessagesTabBar({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final tabs = ['All Chats', 'Active Deals', 'Unread', 'Archived'];

//     return Obx(() {
//       return SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: tabs.map((tab) {
//             final isSelected = controller.selectedTab.value == tab;
//             return Padding(
//               padding: const EdgeInsets.only(right: 8.0),
//               child: GestureDetector(
//                 onTap: () => controller.selectedTab.value = tab,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isSelected ? AppColors.redColor : Colors.transparent,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.white24),
//                   ),
//                   child: Text(
//                     tab,
//                     style: TextStyle(
//                       color: isSelected ? Colors.white : Colors.white70,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     });
//   }
// }
