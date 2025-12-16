// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jconnect/core/common/constants/app_colors.dart';
// import 'package:jconnect/core/common/style/global_text_style.dart';
// import '../controller/notification_controller.dart';

// class NotificationScreen extends StatelessWidget {
//   const NotificationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(NotificationController());

//     return Scaffold(
//       backgroundColor: AppColors.backGroundColor,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: const Color.fromRGBO(255, 255, 255, 1),
//             size: 24,
//           ),
//           onPressed: () {
//             Get.back();
//           },
//         ),
//         backgroundColor: AppColors.backGroundColor,
//         title: Text(
//           "Notifications",
//           style: getTextStyle(
//             fontsize: 20,
//             fontweight: FontWeight.w500,
//             color: AppColors.primaryTextColor,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh, color: AppColors.primaryTextColor),
//             onPressed: controller.fetchNotifications,
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.notifications.isEmpty) {
//           return Center(
//             child: Text(
//               "No notifications yet.",
//               style: getTextStyle(fontsize: 16),
//             ),
//           );
//         }

//         return ListView.separated(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           itemCount: controller.notifications.length,
//           separatorBuilder: (_, __) => const Divider(height: 1),
//           itemBuilder: (context, index) {
//             final item = controller.notifications[index];
//             return InkWell(
//               onTap: () => controller.markAsRead(index),
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 decoration: BoxDecoration(),
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CircleAvatar(
//                       radius: 22,
//                       backgroundColor: item.isRead
//                           ? Colors.grey[200]
//                           : Colors.blue[50],
//                       child: Image.asset(item.iconPath, width: 32, height: 32),
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item.title,
//                             style: getTextStyle(
//                               fontweight: FontWeight.w600,
//                               fontsize: 16,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             item.message,
//                             style: getTextStyle(
//                               fontsize: 13,
//                               color: AppColors.secondaryTextColor,
//                             ),
//                           ),
//                           SizedBox(height: 6),
//                           Text(
//                             item.time,
//                             style: getTextStyle(
//                               fontsize: 12,
//                               color: AppColors.secondaryTextColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (!item.isRead)
//                       Container(
//                         margin: const EdgeInsets.only(top: 8),
//                         width: 8,
//                         height: 8,
//                         decoration: const BoxDecoration(
//                           color: Colors.blueAccent,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controller/notification_controller.dart';

// class NotificationScreen extends StatelessWidget {
//   final controller = Get.find<NotificationController>();

//    NotificationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifications')),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (controller.notifications.isEmpty) {
//           return const Center(child: Text('No notifications'));
//         }

//         return ListView.builder(
//           itemCount: controller.notifications.length,
//           itemBuilder: (_, i) {
//             final n = controller.notifications[i];
//             return ListTile(
//               tileColor:
//                   n.read ? null : Colors.blue.withOpacity(.08),
//               title: Text(
//                 n.title,
//                 style: TextStyle(
//                     fontWeight:
//                         n.read ? FontWeight.normal : FontWeight.bold),
//               ),
//               subtitle: Text(n.message),
//               onTap: () => controller.markAsRead(i),
//             );
//           },
//         );
//       }),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  final controller = Get.put(NotificationController());

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const Center(child: Text('No notifications'));
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (_, index) {
            final item = controller.notifications[index];

            return ListTile(
              title: Text(item.title),
              subtitle: Text(item.message),
              trailing: Text(
                "${item.createdAt.hour}:${item.createdAt.minute}",
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        );
      }),
    );
  }
}
