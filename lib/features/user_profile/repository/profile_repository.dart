// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:get/get.dart';

class ProfileRepository {
  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await pref.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(Endpoint.editProfile),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      print('DEBUG: Get Profile Status: ${response.statusCode}');
      print('DEBUG: Get Profile Response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Get profile failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }

  Future<Map<String, dynamic>> createProfile({
    required String? profileImageUrl,
    required String? shortBio,
    required List<dynamic>? socialProfiles,
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
      if (socialProfiles != null && socialProfiles.isNotEmpty) {
        body['socialProfiles'] = socialProfiles.map((profile) {
          if (profile is Map<String, dynamic>) {
            return profile;
          }
          return profile.toJson();
        }).toList();
      }

      final response = await http.post(
        Uri.parse(Endpoint.editProfile),
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
    required List<dynamic>? socialProfiles,
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
      if (socialProfiles != null && socialProfiles.isNotEmpty) {
        body['socialProfiles'] = socialProfiles.map((profile) {
          if (profile is Map<String, dynamic>) {
            return profile;
          }
          return profile.toJson();
        }).toList();
      }

      final response = await http.put(
        Uri.parse(Endpoint.editProfile),
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
