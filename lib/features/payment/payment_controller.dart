// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/payment/model/payment_model.dart';
import 'package:jconnect/features/payment/payment_service.dart';
import 'package:jconnect/routes/approute.dart';

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

  Future<void> makePayment(String serviceId) async {
    try {
      isLoading.value = true;

      await _paymentService.makePayment(serviceId);

      EasyLoading.showSuccess('Payment completed successfully');
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
        paymentMethod.value = null; // 🔥 instant UI update
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

      /// 🔥 RELOAD CARD AFTER ADD
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
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: _CardEntrySheet(
          onCreated: (id) {
            paymentMethodId = id;
            Get.back();
          },
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
        const Text('Enter card details', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        CardFormField(onCardChanged: (card) => setState(() => _card = card)),
        const SizedBox(height: 12),

        // Padding(
        //   padding: const EdgeInsets.only(bottom: 16),
        //   child: _loading
        //       ? const CircularProgressIndicator()
        //       : ElevatedButton(
        //           onPressed:
        //               _card?.complete == true ? _createPaymentMethod : null,
        //           child: const Text('Use Card'),
        //         ),
        // ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _card?.complete == true
                      ? () async {
                          await _createPaymentMethod();

                          // ✅ Navigate when card is complete
                          //Get.toNamed(AppRoute.manageViaStripe);
                        }
                      : null,
                  child: const Text('Use Card'),
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

      // ignore: unnecessary_null_comparison
      if (pm.id != null) {
        widget.onCreated(pm.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
