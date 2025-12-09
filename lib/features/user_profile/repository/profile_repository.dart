import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:get/get.dart';

class ProfileRepository {
  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  Future<Map<String, dynamic>> createProfile({
    required String? profileImageUrl,
    required String? shortBio,
    required String? instagram,
    required String? facebook,
    required String? tiktok,
    required String? youtube,
  }) async {
    try {
      final token = await pref.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final body = <String, dynamic>{};

      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        body['profile_image_url'] = profileImageUrl;
      }
      if (shortBio != null && shortBio.isNotEmpty) {
        body['short_bio'] = shortBio;
      }
      if (instagram != null && instagram.isNotEmpty) {
        body['instagram'] = instagram;
      }
      if (facebook != null && facebook.isNotEmpty) {
        body['facebook'] = facebook;
      }
      if (tiktok != null && tiktok.isNotEmpty) {
        body['tiktok'] = tiktok;
      }
      if (youtube != null && youtube.isNotEmpty) {
        body['youtube'] = youtube;
      }

      final response = await http.post(
        Uri.parse(Endpoint.updateProfile),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode(body),
      );

      print('DEBUG: Create Profile Status: ${response.statusCode}');
      print('DEBUG: Create Profile Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Create profile failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Create profile error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String? profileImageUrl,
    required String? shortBio,
    required String? instagram,
    required String? facebook,
    required String? tiktok,
    required String? youtube,
  }) async {
    try {
      final token = await pref.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final body = <String, dynamic>{};

      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        body['profile_image_url'] = profileImageUrl;
      }
      if (shortBio != null && shortBio.isNotEmpty) {
        body['short_bio'] = shortBio;
      }
      if (instagram != null && instagram.isNotEmpty) {
        body['instagram'] = instagram;
      }
      if (facebook != null && facebook.isNotEmpty) {
        body['facebook'] = facebook;
      }
      if (tiktok != null && tiktok.isNotEmpty) {
        body['tiktok'] = tiktok;
      }
      if (youtube != null && youtube.isNotEmpty) {
        body['youtube'] = youtube;
      }

      final response = await http.put(
        Uri.parse(Endpoint.updateProfile),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode(body),
      );

      print('DEBUG: Update Profile Status: ${response.statusCode}');
      print('DEBUG: Update Profile Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Update profile failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }
}
