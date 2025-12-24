import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/payment/model/payment_model.dart';
import 'package:jconnect/features/payment/payment_service.dart';

import '../../../../payment/payment_controller.dart';

class MyPaymentMethodScreen extends StatelessWidget {
  MyPaymentMethodScreen({super.key});
  final PaymentService paymentService = PaymentService();
  final controller = Get.find<PaymentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Card', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<PaymentMethodModel>(
        future: paymentService.fetchPaymentMethod(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No payment method found',style: TextStyle(color: Colors.white),));
          }

          final card = snapshot.data!;

          /// ✅ Safe values
          final brand = card.cardBrand?.toUpperCase() ?? 'CARD';
          final last4 = card.last4 != null ? '•••• ${card.last4}' : '•••• ----';
          final expiry = (card.expMonth != null && card.expYear != null)
              ? 'Expires ${card.expMonth}/${card.expYear}'
              : 'Expiry not available';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.credit_card),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$brand $last4',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // GestureDetector(
                    //   onTap: () {
                    //     controller.deleteMethod(card.id!);

                    //     //    paymentService.deletePaymentMethod(card.);
                    //   },
                    //   child: Icon(Icons.delete, color: Colors.red[400]),
                    // ),
                    GestureDetector(
                      onTap: () {
                        if (card.id == null) {
                          Get.snackbar('Error', 'Invalid payment method');
                          return;
                        }

                        Get.defaultDialog(
                          title: 'Delete card?',
                          middleText: 'This card will be removed permanently.',
                          backgroundColor: Colors.black,
                          titleStyle: const TextStyle(color: Colors.white),
                          middleTextStyle: const TextStyle(
                            color: Colors.white70,
                          ),
                          textConfirm: 'Delete',
                          textCancel: 'Cancel',
                          confirmTextColor: Colors.white,
                          cancelTextColor: Colors.white70,
                          buttonColor: Colors.red,
                          onConfirm: () {
                            Get.back(); // close dialog
                            controller.deleteMethod(card.id);
                          },
                        );
                      },
                      child: Icon(Icons.delete, color: Colors.red[400]),
                    ),
                  ],
                ),
                subtitle: Text(expiry),
              ),
            ),
          );
        },
      ),
    );
  }
}


// class MyPaymentMethodScreen extends StatelessWidget {
//   final controller = Get.find<PaymentController>();

//   MyPaymentMethodScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('My Card', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.black,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final card = controller.paymentMethod.value;

//         if (card == null) {
//           return const Center(
//               child: Text('No payment method found',
//                   style: TextStyle(color: Colors.white70)));
//         }

//         final brand = card.cardBrand?.toUpperCase() ?? 'CARD';
//         final last4 =
//             card.last4 != null ? '•••• ${card.last4}' : '•••• ----';
//         final expiry = (card.expMonth != null && card.expYear != null)
//             ? 'Expires ${card.expMonth}/${card.expYear}'
//             : 'Expiry not available';

//         return Padding(
//           padding: const EdgeInsets.all(16),
//           child: Card(
//             elevation: 4,
//             child: ListTile(
//               leading: const Icon(Icons.credit_card),
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     '$brand $last4',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       if (card.id == null) return;

//                       Get.defaultDialog(
//                         title: 'Delete card?',
//                         middleText:
//                             'This card will be removed permanently.',
//                         backgroundColor: Colors.black,
//                         titleStyle: const TextStyle(color: Colors.white),
//                         middleTextStyle:
//                             const TextStyle(color: Colors.white70),
//                         textConfirm: 'Delete',
//                         textCancel: 'Cancel',
//                         confirmTextColor: Colors.white,
//                         cancelTextColor: Colors.white70,
//                         buttonColor: Colors.red,
//                         onConfirm: () {
//                           Get.back();
//                           controller.deleteMethod(card.id);
//                         },
//                       );
//                     },
//                     child: Icon(Icons.delete, color: Colors.red[400]),
//                   ),
//                 ],
//               ),
//               subtitle: Text(expiry),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
