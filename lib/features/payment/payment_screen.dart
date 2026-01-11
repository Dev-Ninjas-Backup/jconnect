// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'payment_controller.dart';

// class PaymentPage extends StatelessWidget {
//   PaymentPage({super.key});

//   final controller = Get.put(PaymentController());
//   final dynamic arg = Get.arguments;

//   // Demo service data
//   String get serviceId => arg.service!.id ?? '';
//   String get serviceTitle => arg.service!.serviceName ?? '';
//   final String serviceDescription = 'Get unlimited access to all features.';
//   int get servicePrice => arg.service!.price ?? 0.0;

//   @override
//   Widget build(BuildContext context) {
//     final double totalPrice =
//         servicePrice + (servicePrice * controller.platformFee.value / 100);
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         leading: const BackButton(color: Colors.white),
//         title: const Text('Payment', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Service details
//             Text(
//               serviceTitle,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               serviceDescription,
//               style: const TextStyle(fontSize: 16, color: Colors.white70),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "Platform Fee: ${controller.platformFee.value}%",
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color.fromARGB(255, 240, 190, 105),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Price: \$${servicePrice.toStringAsFixed(2)}',
//               style: const TextStyle(fontSize: 20, color: Colors.greenAccent),
//             ),
//             SizedBox(height: 16),
//             Text(${totalPrice.toStringAsFixed(2)}',},
//               style: const TextStyle(fontSize: 20, color: Colors.greenAccent),
//             ),
//             const Spacer(),

//             // Payment button
//             Center(
//               child: Obx(
//                 () => controller.isLoading.value
//                     ? const CircularProgressIndicator()
//                     : ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 40,
//                             vertical: 16,
//                           ),
//                         ),
//                         onPressed: () => _showConfirmationDialog(context),
//                         child: const Text(
//                           'Pay Now',
//                           style: TextStyle(fontSize: 18),
//                         ),
//                       ),
//               ),
//             ),
//             SizedBox(height: 35),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Show confirmation dialog before payment
//   void _showConfirmationDialog(BuildContext context) {
//     Get.defaultDialog(
//       title: 'Confirm Payment',
//       middleText:
//           'Do you want to pay \$${servicePrice.toStringAsFixed(2)} for $serviceTitle?',
//       backgroundColor: Colors.black,
//       titleStyle: const TextStyle(color: Colors.white),
//       middleTextStyle: const TextStyle(color: Colors.white70),
//       textCancel: 'No',
//       textConfirm: 'Yes',
//       cancelTextColor: Colors.white70,
//       confirmTextColor: Colors.white,
//       buttonColor: Colors.green,
//       onConfirm: () {
//         Get.back(); // close dialog
//         controller.makePayment(serviceId);
//       },
//       onCancel: () {
//         // Do nothing
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'payment_controller.dart';

class PaymentPage extends StatelessWidget {
  PaymentPage({super.key});

  final PaymentController controller = Get.put(PaymentController());
  final dynamic arg = Get.arguments;

  String get serviceId => arg.service!.id ?? '';
  String get serviceTitle => arg.service!.serviceName ?? '';
  final String serviceDescription = 'Get unlimited access to all features.';
  double get servicePrice => (arg.service!.price ?? 0).toDouble();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Service title
            Text(
              serviceTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            /// Description
            Text(
              serviceDescription,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),

            const SizedBox(height: 16),

            /// Platform Fee
            Obx(
              () => Text(
                "Platform Fee: ${controller.platformFee.value}%",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 240, 190, 105),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Base price
            Text(
              'Price: \$${servicePrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, color: Colors.greenAccent),
            ),

            const SizedBox(height: 16),

            /// Total price (price + platform fee)
            Obx(() {
              final double totalPrice =
                  servicePrice +
                  (servicePrice * controller.platformFee.value / 100);

              return Text(
                'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              );
            }),

            const Spacer(),

            /// Pay button
            Center(
              child: Obx(
                () => controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () => _showConfirmationDialog(context),
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  /// Confirmation dialog
  void _showConfirmationDialog(BuildContext context) {
    final double totalPrice =
        servicePrice + (servicePrice * controller.platformFee.value / 100);
    Get.defaultDialog(
      title: 'Confirm Payment',
      middleText:
          'Do you want to pay \$${totalPrice.toStringAsFixed(2)} for $serviceTitle?',
      backgroundColor: Colors.black,
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textCancel: 'No',
      textConfirm: 'Yes',
      cancelTextColor: Colors.white70,
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back();
        controller.makePayment(serviceId);
      },
    );
  }
}
