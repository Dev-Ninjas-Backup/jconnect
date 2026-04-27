
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class AddCustomServiceRepository {
  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  /// =========================
  /// CREATE SERVICE
  /// =========================
  Future<Map<String, dynamic>> createService({
    required String serviceName,
    required String serviceType,
    required String description,
    required String price,
    required bool isCustom,
    String? logoAssetPath,
    String? socialPlatform,
  }) async {
    final uri = Uri.parse(Endpoint.addService);
    final token = await pref.getAccessToken();

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': token,
    });

    request.fields.addAll({
      'serviceName': serviceName,
      'serviceType': serviceType,
      'description': description,
      'price': price,
      'isCustom': isCustom.toString(), // FIXED
    });

    if (socialPlatform != null && socialPlatform.isNotEmpty) {
      request.fields['socialPlatform'] = socialPlatform;
    }

    /// Attach logo (if provided)
    if (logoAssetPath != null && logoAssetPath.isNotEmpty) {
      final bytes = await rootBundle.load(logoAssetPath);
      request.files.add(
        http.MultipartFile.fromBytes(
          'socialLogoForSocialService',
          bytes.buffer.asUint8List(),
          filename: logoAssetPath.split('/').last,
        ),
      );
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201) {
      return jsonDecode(responseBody);
    }

    throw Exception(responseBody);
  }

  /// =========================
  /// FETCH MY PROFILE
  /// =========================
  Future<Map<String, dynamic>> fetchMyProfile() async {
    final uri = Uri.parse(Endpoint.getProfile);
    final token = await pref.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': token,
      },
    );

    if (response.statusCode == 200||response.statusCode==201) {
      return jsonDecode(response.body);
    }

    throw Exception('Profile load failed');
  }

  /// =========================
  /// DELETE SERVICE
  /// =========================
  Future<void> deleteService(String serviceId) async {
    final uri = Uri.parse('${Endpoint.addService}/$serviceId');
    final token = await pref.getAccessToken();

    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': token,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete failed');
    }
  }

  /// =========================
  /// UPDATE SERVICE
  /// =========================
  Future<Map<String, dynamic>> updateService({
    required String id,
    required String serviceName,
    required String serviceType,
    required String description,
    required String price,
    bool? isCustom,
    String? logoAssetPath,
    String? socialPlatform,
  }) async {
    final uri = Uri.parse('${Endpoint.addService}/$id');
    final token = await pref.getAccessToken();

    final request = http.MultipartRequest('PATCH', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': token,
    });

    request.fields.addAll({
      'serviceName': serviceName,
      'serviceType': serviceType,
      'description': description,
      'price': price,
      if (isCustom != null) 'isCustom': isCustom.toString(), // FIXED
    });

    if (socialPlatform != null && socialPlatform.isNotEmpty) {
      request.fields['socialPlatform'] = socialPlatform;
    }

    /// Attach logo (if provided)
    if (logoAssetPath != null && logoAssetPath.isNotEmpty) {
      final bytes = await rootBundle.load(logoAssetPath);
      request.files.add(
        http.MultipartFile.fromBytes(
          'socialLogoForSocialService',
          bytes.buffer.asUint8List(),
          filename: logoAssetPath.split('/').last,
        ),
      );
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201) {
      return jsonDecode(responseBody);
    }

    throw Exception(responseBody);
  }
}
