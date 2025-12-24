import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'payment_controller.dart';

class PaymentPage extends StatelessWidget {
  PaymentPage({super.key});

  final controller = Get.put(PaymentController());

  //final serviceId = '19a82b3f-5b92-4c16-bc9c-71281b6daa5a';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stripe Payyyyyyment')),
      body: Center(
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () => controller.addCardAndPay(context),
                  child: const Text('Add Card & Pay'),
                ),
        ),
      ),
    );
  }
}
