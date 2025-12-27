import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../payment/payment_controller.dart';

class MyPaymentMethodScreen extends StatelessWidget {
  MyPaymentMethodScreen({super.key});

  final controller = Get.find<PaymentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Card', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final card = controller.paymentMethod.value;

        if (card == null) {
          return const Center(
            child: Text(
              'No payment method found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final brand = card.cardBrand?.toUpperCase() ?? 'CARD';
        final last4 = '•••• ${card.last4 ?? '----'}';
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
                  GestureDetector(
                    onTap: () {
                      Get.defaultDialog(
                        title: 'Delete card?',
                        middleText: 'This card will be removed permanently.',
                        backgroundColor: Colors.black,
                        titleStyle: const TextStyle(color: Colors.white),
                        middleTextStyle: const TextStyle(color: Colors.white70),
                        textConfirm: 'Delete',
                        textCancel: 'Cancel',
                        buttonColor: Colors.red,
                        onConfirm: () {
                          Get.back();
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
      }),
    );
  }
}
