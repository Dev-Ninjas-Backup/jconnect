import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';

class RepostApiPaymentService {
  final NetworkClient client;

  RepostApiPaymentService({required this.client});

  Future<Map<String, dynamic>> initiateRepostPayment(String listingId) async {
    final String url = "${Endpoint.baseUrl}/repost-listings/$listingId/pay";

    try {
      final response = await client.postRequest(
        url: url,
        body: {},
      );

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (response.responseData is Map<String, dynamic>) {
          return response.responseData as Map<String, dynamic>;
        } else if (response.responseData is Map) {
          return Map<String, dynamic>.from(response.responseData as Map);
        }
        throw "Invalid response data format";
      } else {
        throw response.errorMessage ?? "Failed to initiate payment";
      }
    } catch (e) {
      throw "Something went wrong: $e";
    }
  }

  Future<Map<String, dynamic>> createRepostOrder({
    required String listingId,
    required String contentUrl,
    required String paymentIntentId,
    required String timeframe,
  }) async {
    final String url = "${Endpoint.baseUrl}/repost-orders";

    try {
      final response = await client.postRequest(
        url: url,
        body: {
          "listingId": listingId,
          "contentUrl": contentUrl,
          "paymentIntentId": paymentIntentId,
          "timeframe": timeframe,
        },
      );

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (response.responseData is Map<String, dynamic>) {
          return response.responseData as Map<String, dynamic>;
        } else if (response.responseData is Map) {
          return Map<String, dynamic>.from(response.responseData as Map);
        }
        throw "Invalid response data format";
      } else {
        throw response.errorMessage ?? "Failed to create repost order";
      }
    } catch (e) {
      throw "Something went wrong: $e";
    }
  }
}
