// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:logger/logger.dart';

part 'network_response.dart';

class NetworkClient {
  final String _defaultErrorMsg = 'Something went wrong';

  final SharedPreferencesHelperController sharedPreferencesHelper = Get.put(
    SharedPreferencesHelperController(),
  );

  final VoidCallback onUnAuthorize;

  final Logger _logger = Logger();

  NetworkClient({required this.onUnAuthorize});

  // get request method

  Future<NetworkResponse> getRequest({required String url}) async {
    final token = await sharedPreferencesHelper.getAccessToken();
    if (url.contains('bookmark')) {
      print('🔐 [NetworkClient] Bookmark request - Token: $token');
    }
    Map<String, String> commonHeaders = {
      'Content-Type': 'application/json',
      'authorization': token ?? '',
    };
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url: url, headers: commonHeaders);
      final http.Response response = await http.get(
        uri,
        headers: commonHeaders,
      );
      _logResponse(response: response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseBody,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (url.contains('bookmark')) {
          print('🔐 [NetworkClient] Bookmark 401/403 - Unauthorized');
        }
        onUnAuthorize();
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: 'Un Authorize',
        );
      } else {
        final responseBody = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: _extractErrorMessage(responseBody['message']),
        );
      }
    } on Exception catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  //post request method

  Future<NetworkResponse> postRequest({
    required String url,
    required Map<String, dynamic>? body,
  }) async {
    Map<String, String> commonHeaders = {
      'content-type': 'application/json',
      'authorization': await sharedPreferencesHelper.getAccessToken() ?? '',
    };
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url: url, headers: commonHeaders, body: body);
      final http.Response response = await http.post(
        uri,
        headers: commonHeaders,
        body: jsonEncode(body),
      );
      _logResponse(response: response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseBody,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        onUnAuthorize();
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: 'Un Authorize',
        );
      } else {
        final responseBody = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: responseBody,
          errorMessage: _extractErrorMessage(responseBody['message']),
        );
      }
    } on Exception catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  //patch request method

  Future<NetworkResponse> patchRequest({
    required String url,
    required Map<String, dynamic>? body,
  }) async {
    Map<String, String> commonHeaders = {
      'content-type': 'application/json',
      'authorization': await sharedPreferencesHelper.getAccessToken() ?? '',
    };
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url: url, headers: commonHeaders, body: body);
      final http.Response response = await http.patch(
        uri,
        headers: commonHeaders,
        body: jsonEncode(body),
      );
      _logResponse(response: response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseBody,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        onUnAuthorize();
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: 'Un Authorize',
        );
      } else {
        final responseBody = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: _extractErrorMessage(responseBody['message']),
        );
      }
    } on Exception catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  //delete request method

  Future<NetworkResponse> deleteRequest(String url) async {
    Map<String, String> commonHeaders = {
      'content-type': 'application/json',
      'authorization': await sharedPreferencesHelper.getAccessToken() ?? '',
    };
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url: url, headers: commonHeaders);
      final http.Response response = await http.delete(
        uri,
        headers: commonHeaders,
      );
      _logResponse(response: response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseBody,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        onUnAuthorize();
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: 'Un Authorize',
        );
      } else {
        final responseBody = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: _extractErrorMessage(responseBody['message']),
        );
      }
    } on Exception catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ADD THIS METHOD ONLY — keep all your existing get/post/patch/delete
  // In NetworkClient class — REPLACE your uploadFile method with this
  Future<NetworkResponse> uploadFile({
    required String url,
    required File file,
    String fieldName = 'file',
    Map<String, String>? extraFields,
  }) async {
    try {
      final token = await sharedPreferencesHelper.getAccessToken() ?? '';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['authorization'] = token;
      request.headers['accept'] = 'application/json';

      if (extraFields != null) request.fields.addAll(extraFields);

      // Detect MIME type
      String mimeType = 'application/octet-stream'; // fallback
      final extension = file.path.split('.').last.toLowerCase();

      if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
        mimeType = 'image/$extension';
        if (extension == 'jpg') mimeType = 'image/jpeg';
      } else if ([
        'mp4',
        'mov',
        'avi',
        'mkv',
        'webm',
        'm4v',
      ].contains(extension)) {
        mimeType = 'video/$extension';
        if (extension == 'mov' || extension == 'm4v') mimeType = 'video/mp4';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
          contentType: MediaType.parse(mimeType),
        ),
      );

      _logger.i('Uploading file to: $url with fields: $extraFields');

      // Set timeout for multipart request (5 minutes)
      var streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );

      var response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(const Duration(minutes: 5));

      _logResponse(response: response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseBody,
        );
      } else {
        try {
          final responseBody = jsonDecode(response.body);
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage: _extractErrorMessage(responseBody['message']),
          );
        } catch (e) {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage: 'Upload failed with status ${response.statusCode}',
          );
        }
      }
    } on SocketException catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: 'Network error: ${e.message}',
      );
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: 'Upload error: ${e.toString()}',
      );
    }
  }

  // Upload multiple files and return list of URLs
  Future<NetworkResponse> uploadMultipleFiles({
    required String url,
    required List<File> files,
    String fieldName = 'files',
  }) async {
    try {
      final token = await sharedPreferencesHelper.getAccessToken() ?? '';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['authorization'] = token;
      request.headers['accept'] = 'application/json';

      // Add all files to the request
      for (final file in files) {
        String mimeType = 'application/octet-stream'; // fallback
        final extension = file.path.split('.').last.toLowerCase();

        if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
          mimeType = 'image/$extension';
          if (extension == 'jpg') mimeType = 'image/jpeg';
        } else if ([
          'mp4',
          'mov',
          'avi',
          'mkv',
          'webm',
          'm4v',
        ].contains(extension)) {
          mimeType = 'video/$extension';
          if (extension == 'mov' || extension == 'm4v') mimeType = 'video/mp4';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            fieldName,
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      _logger.i('Uploading ${files.length} files to: $url');

      // Set timeout for multipart request (5 minutes)
      var streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );

      var response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(const Duration(minutes: 5));

      _logResponse(response: response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseBody,
        );
      } else {
        try {
          final responseBody = jsonDecode(response.body);
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage: _extractErrorMessage(responseBody['message']),
          );
        } catch (e) {
          return NetworkResponse(
            statusCode: response.statusCode,
            isSuccess: false,
            errorMessage: 'Upload failed with status ${response.statusCode}',
          );
        }
      }
    } on SocketException catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: 'Network error: ${e.message}',
      );
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: 'Upload error: ${e.toString()}',
      );
    }
  }

  void _logRequest({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    final String message =
        '''
    URL -> $url
    HEADERS -> $headers
    BODY -> $body
    ''';
    _logger.i(message);
  }

  void _logResponse({required http.Response response}) {
    final String message =
        '''
    URL -> ${response.request?.url}
    HEADERS -> ${response.request?.headers}
    BODY -> ${response.body}
    ''';
    _logger.i(message);
  }

  String _extractErrorMessage(dynamic message) {
    if (message == null) return _defaultErrorMsg;
    if (message is String) return message;
    if (message is List) {
      if (message.isEmpty) return _defaultErrorMsg;
      return message.map((item) => item.toString()).join(', ');
    }
    return message.toString();
  }
}
