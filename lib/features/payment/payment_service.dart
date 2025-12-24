// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:jconnect/core/endpoint.dart';
// import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

// class PaymentService {
//   SharedPreferencesHelperController sharedPreferencesHelper =
//       Get.find<SharedPreferencesHelperController>();

//   /// 3️⃣ Make Payment
//   Future<void> makePayment(String serviceId) async {
//     await http.post(
//       Uri.parse('${Endpoint.baseUrl}/payments/make-payment'),
//       headers: {
//         'Content-Type': 'application/json',

//         'authorization': await sharedPreferencesHelper.getAccessToken() ?? '',
//       },
//       body: jsonEncode({'serviceId': serviceId}),
//     );
//   }

//   Future<void> paymentMethodAdd(String paymentMethodId) async {
//     await http.post(
//       Uri.parse(
//         "${Endpoint.baseUrl}/payments/payment_method_attached?payment_method_id=$paymentMethodId",
//       ),
//       headers: {
//         'Content-Type': 'application/json',

//         'authorization': await sharedPreferencesHelper.getAccessToken() ?? '',
//       },
//       body: {},
//     );
//   }
// }


import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/payment/model/payment_model.dart';

class PaymentService {
  final SharedPreferencesHelperController _prefs =
      Get.find<SharedPreferencesHelperController>();

  Future<Map<String, String>> _headers() async {
    return {
      'Content-Type': 'application/json',
      'authorization': await _prefs.getAccessToken() ?? '',
    };
  }

  /// Attach payment method to customer
  Future<void> paymentMethodAdd(String paymentMethodId) async {
    final response = await http.post(
      Uri.parse(
        '${Endpoint.baseUrl}/payments/payment_method_attached'
        '?payment_method_id=$paymentMethodId',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Payment method attach failed: ${response.body}',
      );
    }
  }

  /// Make payment for service
  Future<void> makePayment(String serviceId) async {
    final response = await http.post(
      Uri.parse('${Endpoint.baseUrl}/payments/make-payment'),
      headers: await _headers(),
      body: jsonEncode({'serviceId': serviceId}),
    );

    if (response.statusCode != 200||response.statusCode!=201) {
      throw Exception(
        'Payment failed: ${response.body}',
      );
    }
  }






Future<PaymentMethodModel> fetchPaymentMethod() async {
  final response = await http.get(
    Uri.parse(
      '${Endpoint.baseUrl}/payments/my-paymentsss-methods',
    ),
    headers: await _headers(),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return PaymentMethodModel.fromJson(data);
  } else {
    throw Exception('Failed to load payment method');
  }
}

  
}
