import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class AddServiceRepository {
  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  /// CREATE SERVICE
  // Future<Map<String, dynamic>> createService({
  //   required String serviceName,
  //   required String serviceType,
  //   required String description,
  //   required String price,
  // }) async {
  //   final uri = Uri.parse(Endpoint.addService);
  //   final token = await pref.getAccessToken();

  //   final request = http.MultipartRequest('POST', uri);

  //   if (token != null) request.headers['Authorization'] = token;
  //   request.headers['Accept'] = 'application/json';

  //   request.fields.addAll({
  //     'serviceName': serviceName,
  //     'serviceType': serviceType,
  //     'description': description,
  //     'price': price,
  //     'files': '',
  //   });

  //   final streamedResp = await request.send();
  //   final respStr = await streamedResp.stream.bytesToString();

  //   if (streamedResp.statusCode == 200 || streamedResp.statusCode == 201) {
  //     return jsonDecode(respStr);
  //   }
  //   throw Exception(respStr);
  // }




Future<Map<String, dynamic>> createService({
  required String serviceName,
  required String serviceType,
  required String description,
  required String price,
  String? logoAssetPath,
  String? socialPlatform,
}) async {
  final uri = Uri.parse(Endpoint.addService);
  final token = await pref.getAccessToken();

  final request = http.MultipartRequest('POST', uri);

  if (token != null) request.headers['Authorization'] = token;
  request.headers['Accept'] = 'application/json';

  request.fields.addAll({
    'serviceName': serviceName,
    'serviceType': serviceType,
    'description': description,
    'price': price,
  });

  if (socialPlatform != null) {
    request.fields['socialPlatform'] = socialPlatform;
  }

  /// 👇 Attach logo if social service
  if (logoAssetPath != null && logoAssetPath.isNotEmpty) {
    final bytes =
        await rootBundle.load(logoAssetPath);
    request.files.add(
      http.MultipartFile.fromBytes(
        'socialLogoForSocialService',
        bytes.buffer.asUint8List(),
        filename: logoAssetPath.split('/').last,
      ),
    );
  }

  final streamedResp = await request.send();
  final respStr = await streamedResp.stream.bytesToString();

  if (streamedResp.statusCode == 200 ||
      streamedResp.statusCode == 201) {
    return jsonDecode(respStr);
  }

  throw Exception(respStr);
}




  /// FETCH PROFILE
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

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Profile load failed');
  }

  /// DELETE SERVICE
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

  // UPDATE SERVICE
  Future<Map<String, dynamic>> updateService({
    required String id,
    required String serviceName,
    required String serviceType,
    required String description,
    required String price,
    String? logoAssetPath,
    String? socialPlatform,
  }) async {
    final uri = Uri.parse('${Endpoint.addService}/$id');
    final token = await pref.getAccessToken();

    final request = http.MultipartRequest('PATCH', uri);

    if (token != null) request.headers['Authorization'] = token;
    request.headers['Accept'] = 'application/json';

    request.fields.addAll({
      'serviceName': serviceName,
      'serviceType': serviceType,
      'description': description,
      'price': price,
    });

    if (socialPlatform != null) {
      request.fields['socialPlatform'] = socialPlatform;
    }

    /// 👇 Attach logo if social service
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

    final streamedResp = await request.send();
    final respStr = await streamedResp.stream.bytesToString();

    if (streamedResp.statusCode == 200 || streamedResp.statusCode == 201) {
      return jsonDecode(respStr);
    }

    throw Exception(respStr);
  }
}
