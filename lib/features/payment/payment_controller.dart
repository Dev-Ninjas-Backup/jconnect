// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:get/get.dart';
// import 'package:jconnect/features/payment/payment_service.dart';

// class PaymentController extends GetxController {
//   final isLoading = false.obs;

//   // Future<void> addCardAndPay(BuildContext context) async {
//   //   try {
//   //     isLoading.value = true;

//   //     final paymentMethodId = await _collectCardAndCreatePaymentMethod(context);
//   //     print('Collected paymentMethodId: $paymentMethodId');
//   //     if (paymentMethodId == null) {
//   //       throw Exception('Card entry cancelled or invalid');
//   //     }

//   //     // await PaymentService().paymentMethodAdd(paymentMethodId);

//   //     Get.snackbar(
//   //       'Success',
//   //       'Payment Meethod Added Successfully',
//   //       backgroundColor: Colors.green,
//   //       colorText: Colors.white,
//   //     );
//   //   } catch (e) {
//   //     print('Payment Meethod error: $e');
//   //     Get.snackbar(
//   //       'Payment Meethod Failed',
//   //       e.toString(),
//   //       backgroundColor: Colors.red,
//   //       colorText: Colors.white,
//   //     );
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }

// Future<void> addCardAndPay(BuildContext context) async {
//   try {
//     isLoading.value = true;

//     final paymentMethodId =
//         await _collectCardAndCreatePaymentMethod(context);

//     if (paymentMethodId == null) {
//       throw Exception('Card entry cancelled or invalid');
//     }

//     // 🔥 CALL BACKEND HERE
//     await PaymentService().paymentMethodAdd(paymentMethodId);

//     Get.snackbar(
//       'Success',
//       'Payment Method Added Successfully',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   } catch (e) {
//     Get.snackbar(
//       'Payment Method Failed',
//       e.toString(),
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   } finally {
//     isLoading.value = false;
//   }
// }

//   /// Shows a modal with a `CardFormField`, creates a PaymentMethod and returns its id.
//   Future<String?> _collectCardAndCreatePaymentMethod(
//     BuildContext context,
//   ) async {
//     String? paymentMethodId;

//     await showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       builder: (ctx) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(ctx).viewInsets.bottom,
//             left: 16,
//             right: 16,
//             top: 16,
//           ),
//           child: _CardEntrySheet(
//             onCreated: (id) {
//               paymentMethodId = id;
//               Navigator.of(ctx).pop();
//             },
//           ),
//         );
//       },
//     );

//     return paymentMethodId;
//   }
// }

// class _CardEntrySheet extends StatefulWidget {
//   final void Function(String paymentMethodId) onCreated;
//   const _CardEntrySheet({required this.onCreated});

//   @override
//   State<_CardEntrySheet> createState() => _CardEntrySheetState();
// }

// class _CardEntrySheetState extends State<_CardEntrySheet> {
//   CardFieldInputDetails? _card;
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const SizedBox(height: 8),
//         const Text('Enter card details', style: TextStyle(fontSize: 16)),
//         const SizedBox(height: 12),
//         CardFormField(
//           onCardChanged: (details) => setState(() => _card = details),
//         ),
//         const SizedBox(height: 12),
//         Padding(
//           padding: const EdgeInsets.only(bottom: 16.0),
//           child: _isLoading
//               ? const CircularProgressIndicator()
//               : ElevatedButton(
//                   onPressed: _card?.complete == true
//                       ? _createPaymentMethod
//                       : null,
//                   child: const Text('Use Card'),
//                 ),
//         ),
//       ],
//     );
//   }

//   Future<void> _createPaymentMethod() async {
//     setState(() => _isLoading = true);
//     try {
//       final pm = await Stripe.instance.createPaymentMethod(
//         params: PaymentMethodParams.card(
//           paymentMethodData: PaymentMethodData(),
//         ),
//       );

//       final id = pm.id;
//       if (id != null) widget.onCreated(id);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to create payment method: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
// }

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/payment/payment_service.dart';
import 'package:jconnect/routes/approute.dart';

class PaymentController extends GetxController {
  final isLoading = false.obs;
  final PaymentService _paymentService = PaymentService();

  Future<void> addCardAndPay(BuildContext context) async {
    try {
      isLoading.value = true;

      final paymentMethodId = await _collectCardAndCreatePaymentMethod(context);
      print("paymentMethodId: $paymentMethodId");

      if (paymentMethodId == null) {
        throw Exception('Card entry cancelled');
      }

      await _paymentService.paymentMethodAdd(paymentMethodId);

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

  Future<String?> _collectCardAndCreatePaymentMethod(
    BuildContext context,
  ) async {
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
                          Get.toNamed(AppRoute.manageViaStripe);
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

      if (pm.id != null) {
        widget.onCreated(pm.id!);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
