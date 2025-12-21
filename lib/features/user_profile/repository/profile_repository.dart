import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/edit_profile/model/social_profile_model.dart';

class ProfileRepository {
  final _prefs = SharedPreferencesHelperController();

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String shortBio,
    String? imagePath,
    required List<SocialProfile> socialProfiles,
  }) async {
    final token = await _prefs.getAccessToken();
    if (token == null) throw Exception("Access token not found");

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse(Endpoint.editProfile),
    );

    // Headers
    request.headers['Authorization'] = token;

    request.fields['full_name'] = fullName;
    request.fields['phone'] = phone;
    request.fields['short_bio'] = shortBio;
    request.fields['socialProfiles'] =
        jsonEncode(socialProfiles.map((e) => e.toJson()).toList());

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

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(body);
    }
  }

  Future<void> createProfile() async {
    final token = await _prefs.getAccessToken();
    if (token == null) throw Exception("Access token not found");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(Endpoint.editProfile),
    );

    request.headers['Authorization'] = token;

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(body);
    }
  }
}
