// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/edit_profile/model/social_profile_model.dart';

class ProfileRepository {
  final _prefs = SharedPreferencesHelperController();

  Future<void> updateProfile({
    required String phone,
    required String shortBio,
    required String location,
    required String username,
    required List<String> hashtags,
    String? imagePath,
    required List<SocialProfile> socialProfiles,
    required List<String> highlightsPaths,
  }) async {
    final token = await _prefs.getAccessToken();
    if (token == null) throw Exception("Access token not found");

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse(Endpoint.editProfile),
    );

    // Headers
    request.headers['Authorization'] = token;

    request.fields['phone'] = phone;
    request.fields['short_bio'] = shortBio;
    request.fields['location'] = location;
    request.fields['username'] = username;
    request.fields['hashTags'] = jsonEncode(hashtags);
    request.fields['socialProfiles'] = jsonEncode(
      socialProfiles.map((e) => e.toJson()).toList(),
    );

    if (imagePath != null && imagePath.isNotEmpty) {
      // Detect file extension
      final extension = imagePath.split('.').last.toLowerCase();
      String mimeType;
      if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'jpeg';
      } else if (extension == 'png') {
        mimeType = 'png';
      } else {
        throw Exception('Only JPG, JPEG, or PNG files are allowed!');
      }

      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: MediaType('image', mimeType),
      );
      request.files.add(multipartFile);
    }

    // Add highlights (images and videos)
    for (int i = 0; i < highlightsPaths.length; i++) {
      final highlightPath = highlightsPaths[i];
      final extension = highlightPath.split('.').last.toLowerCase();
      
      String mimeType;
      late String fieldName;
      
      // Determine if it's a video or image
      if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
        fieldName = 'highlights';
        mimeType = 'video/$extension';
      } else if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        fieldName = 'highlights';
        mimeType = 'image/$extension';
      } else {
        throw Exception('Only images (JPG, PNG, GIF) and videos (MP4, MOV, AVI, MKV) allowed for highlights!');
      }

      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        highlightPath,
        contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
      );
      request.files.add(multipartFile);
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(body);
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> createProfile({
    String? profile_image_url,
    required String shortBio,
    required socialProfiles,
  }) async {
    final token = await _prefs.getAccessToken();
    if (token == null) throw Exception("Access token not found");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse("${Endpoint.baseUrl}/profiles"),
    );

    request.headers['Authorization'] = token;

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(body);
    }
  }
}
