import 'package:flutter/material.dart';
import 'package:jconnect/features/payment/model/payment_model.dart';
import 'package:jconnect/features/payment/payment_service.dart';

class MyPaymentMethodScreen extends StatelessWidget {
  MyPaymentMethodScreen({super.key});
  final PaymentService paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('My Card',style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
      body: FutureBuilder<PaymentMethodModel>(
        future: paymentService.fetchPaymentMethod(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No payment method found'));
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
                title: Text(
                  '$brand $last4',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
