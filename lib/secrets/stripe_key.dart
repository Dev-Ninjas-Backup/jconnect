import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:jconnect/core/endpoint.dart';

class StripeKey {
  static String? _stripeKey;

  static Future<String> fetchStripeKey() async {
    if (_stripeKey != null) {
      return _stripeKey!;
    }

    try {
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/payments/stripe-public-key'),
        headers: {
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200|| response.statusCode==201) {
        final data = json.decode(response.body);
        _stripeKey = data['stripePublicKey'];
        return _stripeKey!;
      } else {
        debugPrint('Failed to fetch Stripe key: ${response.statusCode}');
        throw Exception('Failed to load Stripe key');
      }
    } catch (e) {
      debugPrint('Error fetching Stripe key: $e');
      throw Exception('Error fetching Stripe key: $e');
    }
  }
}
