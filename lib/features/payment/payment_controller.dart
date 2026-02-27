// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/payment/model/payment_model.dart';
import 'package:jconnect/features/payment/payment_service.dart';

class PaymentController extends GetxController {
  final isLoading = false.obs;
  final PaymentService _paymentService = PaymentService();
  final Rxn<PaymentMethodModel> paymentMethod = Rxn();
  RxInt platformFee = 0.obs;

  final RxBool isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethod();
    loadPlatformFee();
  }

  Future<void> loadPlatformFee() async {
    try {
      isLoading.value = true;
      platformFee.value = await _paymentService.fetchPlatformFee();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPaymentMethod() async {
    try {
      isLoading.value = true;
      paymentMethod.value = await _paymentService.fetchPaymentMethod();
    } catch (e) {
      paymentMethod.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> makePayment(String serviceId, {String? serviceRequestId}) async {
    try {
      isLoading.value = true;

      await _paymentService.makePayment(serviceId);

      // Mark the service request as paid if ID is available
      if (serviceRequestId != null && serviceRequestId.isNotEmpty) {
        try {
          await _paymentService.markServiceRequestPaid(serviceRequestId);
        } catch (e) {
          print('⚠️ Failed to mark service request as paid: $e');
        }
      }

      EasyLoading.showSuccess('Payment completed successfully');
      Get.back(result: true);
    } catch (e) {
      print("payment error: $e");
      EasyLoading.showError('Add your payment method before proceeding ✨');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMethod(String? id) async {
    if (id == null) {
      Get.snackbar('Error', 'Invalid payment method');
      return;
    }

    try {
      isDeleting.value = true;
      final success = await _paymentService.deletePaymentMethod(id);

      if (success) {
        paymentMethod.value = null;
        Get.snackbar('Success', 'Payment method deleted');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> addCard(BuildContext context) async {
    try {
      isLoading.value = true;

      final paymentMethodId = await _collectCardAndCreatePaymentMethod(context);

      if (paymentMethodId == null) return;

      await _paymentService.paymentMethodAdd(paymentMethodId);

      await loadPaymentMethod();

      Get.snackbar(
        'Success',
        'Payment Method Added Successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
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
}

Future<String?> _collectCardAndCreatePaymentMethod(BuildContext context) async {
  String? paymentMethodId;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // 🔥 IMPORTANT
    builder: (_) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 32, left: 16, right: 16, top: 16),
          child: _CardEntrySheet(
            onCreated: (id) {
              paymentMethodId = id;
              Get.back();
            },
          ),
        ),
      );
    },
  );

  return paymentMethodId;
}

class _CardEntrySheet extends StatefulWidget {
  final void Function(String paymentMethodId) onCreated;

  const _CardEntrySheet({required this.onCreated});

  @override
  State<_CardEntrySheet> createState() => _CardEntrySheetState();
}

class _CardEntrySheetState extends State<_CardEntrySheet> {
  CardFieldInputDetails? _card;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),

        Text(
          'Enter card details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 12),

        CardFormField(
          style: CardFormStyle(
            backgroundColor: Colors.white,
            textColor: Colors.black,
            placeholderColor: Colors.black,
            borderRadius: 8,
            cursorColor: Theme.of(context).primaryColor,
            textErrorColor: Colors.red,
          ),
          onCardChanged: (card) {
            setState(() => _card = card);
          },
        ),

        //const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _loading
              ? const CircularProgressIndicator()
              : SizedBox(
                  //width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _card?.complete == true
                        ? () async {
                            await _createPaymentMethod();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Text('Use Card'),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _createPaymentMethod() async {
    setState(() => _loading = true);

    try {
      final pm = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      widget.onCreated(pm.id);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
