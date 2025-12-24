import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'payment_service.dart';

class PaymentController extends GetxController {
  final isLoading = false.obs;

  /// Full payment flow
  Future<void> addCardAndPay(BuildContext context, String serviceId) async {
    try {
      isLoading.value = true;

      /// 1️⃣ Create SetupIntent on backend
      final clientSecret = await PaymentService().createSetupIntent();

      /// 2️⃣ Collect card details in-app and create a PaymentMethod
      final paymentMethodId = await _collectCardAndCreatePaymentMethod(context);
      print('Collected paymentMethodId: $paymentMethodId');
      if (paymentMethodId == null) {
        throw Exception('Card entry cancelled or invalid');
      }

      /// 3️⃣ Confirm SetupIntent on backend with the collected payment method id
      await PaymentService().confirmSetupIntent(
        clientSecret: clientSecret,
        token: "tok_vdddfdisa",
      );

      /// 4️⃣ Charge customer
      await PaymentService().makePayment(serviceId);

      Get.snackbar(
        'Success',
        'Payment completed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('payment error: $e');
      Get.snackbar(
        'Payment Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Shows a modal with a `CardFormField`, creates a PaymentMethod and returns its id.
  Future<String?> _collectCardAndCreatePaymentMethod(BuildContext context) async {
    String? paymentMethodId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: _CardEntrySheet(
            onCreated: (id) {
              paymentMethodId = id;
              Navigator.of(ctx).pop();
            },
          ),
        );
      },
    );

    return paymentMethodId;
  }
}

class _CardEntrySheet extends StatefulWidget {
  final void Function(String paymentMethodId) onCreated;
  const _CardEntrySheet({required this.onCreated});

  @override
  State<_CardEntrySheet> createState() => _CardEntrySheetState();
}

class _CardEntrySheetState extends State<_CardEntrySheet> {
  CardFieldInputDetails? _card;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const Text('Enter card details', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        CardFormField(
          onCardChanged: (details) => setState(() => _card = details),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _card?.complete == true ? _createPaymentMethod : null,
                  child: const Text('Use Card'),
                ),
        ),
      ],
    );
  }

  Future<void> _createPaymentMethod() async {
    setState(() => _isLoading = true);
    try {
      final pm = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      final id = pm.id;
      if (id != null) widget.onCreated(id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create payment method: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
