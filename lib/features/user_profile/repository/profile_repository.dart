// ignore_for_file: avoid_print, non_constant_identifier_names, duplicate_ignore

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
    List<String>? existingHighlightUrls,
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

    // Download and re-upload existing highlights (from S3 URLs)
    print('DEBUG: Processing ${existingHighlightUrls?.length ?? 0} existing highlights');
    if (existingHighlightUrls != null && existingHighlightUrls.isNotEmpty) {
      for (int i = 0; i < existingHighlightUrls.length; i++) {
        final url = existingHighlightUrls[i];
        try {
          print('DEBUG: Downloading existing highlight [$i]: $url');
          
          // Download file from S3 URL
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            // Extract filename from URL
            final urlPath = url.split('/').last.split('?').first;
            final filename = urlPath.isNotEmpty ? urlPath : 'highlight_$i';
            
            // Determine MIME type
            final extension = filename.split('.').last.toLowerCase();
            final String mimeMainType;
            if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
              mimeMainType = 'image';
            } else if (['mp4', 'mov', 'avi', 'flv', 'mkv', 'webm'].contains(extension)) {
              mimeMainType = 'video';
            } else {
              mimeMainType = 'application';
            }

            // Create multipart file from downloaded bytes
            final multipartFile = http.MultipartFile.fromBytes(
              'highlights',
              response.bodyBytes,
              filename: filename,
              contentType: MediaType(mimeMainType, extension),
            );
            request.files.add(multipartFile);
            print('DEBUG: Added existing highlight to upload [$i]: $filename');
          } else {
            print('ERROR: Failed to download highlight [$i]: ${response.statusCode}');
          }
        } catch (e) {
          print('ERROR: Exception downloading highlight [$i]: $e');
        }
      }
    }

    // Add new highlight files (local files)
    print('DEBUG: Processing ${highlightsPaths.length} new highlight files');
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
      print('DEBUG: Added new highlight file [$i]: $highlightPath (type: $fieldName)');
    }

    print('DEBUG: ========== UPLOAD SUMMARY ==========');
    print('DEBUG: Total files in request: ${request.files.length}');
    print('DEBUG: Total fields in request: ${request.fields.length}');
    print('DEBUG: All fields: ${request.fields.keys.toList()}');
    print('DEBUG: Files being uploaded:');
    for (var file in request.files) {
      print('  - Field: ${file.field}, Filename: ${file.filename}');
    }
    print('DEBUG: ==================================');

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
