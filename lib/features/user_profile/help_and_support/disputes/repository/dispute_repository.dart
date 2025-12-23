import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class DisputeRepository {
  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  Future<List<dynamic>> fetchMyDisputes() async {
    final uri = Uri.parse(Endpoint.dispute);
    final token = await pref.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load disputes');
    }
  }
}
