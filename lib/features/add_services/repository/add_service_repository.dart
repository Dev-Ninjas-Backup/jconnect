import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class AddServiceRepository {
  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  /// Create service using multipart request (API accepts multipart in curl)
  Future<Map<String, dynamic>> createService({
    required String serviceName,
    required String serviceType,
    required String description,
    required String price,
  }) async {
    final uri = Uri.parse(Endpoint.addService);

    try {
      // Use the same stored access token format used elsewhere (contains 'Bearer ')
      final token = await pref.getAccessToken();
      // ignore: avoid_print
      print(
        'AddServiceRepository.createService -> access token present: ${token != null && token.isNotEmpty}',
      );

      final request = http.MultipartRequest('POST', uri);

      // Attach headers
      if (token != null && token.isNotEmpty) {
        // Some places use lowercase header name; set both to be safe
        request.headers['Authorization'] = token;
        request.headers['authorization'] = token;
      }
      request.headers['Accept'] = 'application/json';

      // add top-level fields
      request.fields['serviceName'] = serviceName;
      request.fields['serviceType'] = serviceType;
      request.fields['description'] = description;
      request.fields['price'] = price;

      // include user id fields (send multiple variants to satisfy backend)
      try {
        final userId = await pref.getUserId();
        if (userId != null && userId.isNotEmpty) {
          request.fields['creatorId'] = userId;
          request.fields['userId'] = userId;
          request.fields['creator_id'] = userId;
          request.fields['user_id'] = userId;
          // ignore: avoid_print
          print(
            'AddServiceRepository.createService -> attaching user id variants: $userId',
          );

          // Also provide a nested JSON payload under 'data' in case backend expects that
          final payload = {
            'userId': userId,
            'serviceName': serviceName,
            'serviceType': serviceType,
            'description': description,
            'price': price,
          };
          request.fields['data'] = jsonEncode(payload);
        }
      } catch (e) {
        // ignore: avoid_print
        print(
          'AddServiceRepository.createService -> failed to read userId: $e',
        );
      }

      // Some backends expect a 'files' field even if empty (curl example uses files=string)
      request.fields['files'] = '';

      // Log outgoing request for debugging
      // ignore: avoid_print
      print('AddServiceRepository.createService -> POST ${uri.toString()}');
      // ignore: avoid_print
      print('Headers: ${request.headers}');
      // ignore: avoid_print
      print('Fields: ${request.fields}');

      final streamedResp = await request.send();
      final respStr = await streamedResp.stream.bytesToString();

      final status = streamedResp.statusCode;
      // ignore: avoid_print
      print('AddServiceRepository.createService -> status: $status');
      // ignore: avoid_print
      print('AddServiceRepository.createService -> body: $respStr');

      if (status == 200 || status == 201) {
        return jsonDecode(respStr) as Map<String, dynamic>;
      }

      // Try to decode error body when possible and throw
      try {
        final decoded = jsonDecode(respStr) as Map<String, dynamic>;
        throw Exception(
          'Create service failed: ${decoded['message'] ?? decoded}',
        );
      } catch (_) {
        throw Exception('Create service failed: HTTP $status');
      }
    } catch (e) {
      // ignore: avoid_print
      print('AddServiceRepository.createService -> error: $e');
      throw Exception('Create service error: $e');
    }
  }

  /// Try to fetch service type options from the API. Returns empty list on failure.
  Future<List<String>> fetchServiceTypes() async {
    final candidates = [
      '${Endpoint.baseUrl}/services/types',
      '${Endpoint.baseUrl}/service-types',
      '${Endpoint.baseUrl}/services/service-types',
    ];

    for (final url in candidates) {
      try {
        final uri = Uri.parse(url);
        final resp = await http.get(
          uri,
          headers: {'Accept': 'application/json'},
        );
        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body);
          // body may be a list or an object containing a list under data/types
          if (body is List) {
            return body.map((e) => e.toString()).toList();
          }
          if (body is Map) {
            if (body['data'] is List)
              return (body['data'] as List).map((e) => e.toString()).toList();
            if (body['types'] is List)
              return (body['types'] as List).map((e) => e.toString()).toList();
            if (body['serviceTypes'] is List)
              return (body['serviceTypes'] as List)
                  .map((e) => e.toString())
                  .toList();
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('AddServiceRepository.fetchServiceTypes -> failed for $url: $e');
      }
    }
    return <String>[];
  }
}
