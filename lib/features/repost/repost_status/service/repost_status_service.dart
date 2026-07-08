import 'dart:io';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';

class RepostStatusService {
  final NetworkClient client;

  RepostStatusService({required this.client});

  Future<List<RepostStatusItem>> fetchMyRepostOrders() async {
    try {
      final response = await client.getRequest(url: Endpoint.myRepostOrders);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final List data = response.responseData as List;
        // ignore: avoid_print
        print("DATA FROM API : $data");
        return data
            .map((json) =>
                RepostStatusItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw response.errorMessage ?? 'Failed to load repost orders';
      }
    } catch (e) {
      throw 'Something went wrong while fetching repost orders: $e';
    }
  }

  Future<RepostStatusItem> fetchRepostOrderDetail(String id) async {
    try {
      final response = await client.getRequest(url: Endpoint.repostOrderDetails(id));

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return RepostStatusItem.fromJson(response.responseData as Map<String, dynamic>);
      } else {
        throw response.errorMessage ?? 'Failed to load repost order details';
      }
    } catch (e) {
      throw 'Something went wrong while fetching repost order details: $e';
    }
  }

  Future<RepostStatusItem> acceptRepostOrder(String id) async {
    try {
      final response = await client.postRequest(
        url: Endpoint.acceptRepostOrder(id),
        body: {},
      );

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return RepostStatusItem.fromJson(response.responseData as Map<String, dynamic>);
      } else {
        throw response.errorMessage ?? 'Failed to accept repost order';
      }
    } catch (e) {
      throw 'Something went wrong while accepting repost order: $e';
    }
  }

  Future<RepostStatusItem> rejectRepostOrder(String id) async {
    try {
      final response = await client.postRequest(
        url: Endpoint.rejectRepostOrder(id),
        body: {},
      );

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return RepostStatusItem.fromJson(response.responseData as Map<String, dynamic>);
      } else {
        throw response.errorMessage ?? 'Failed to reject repost order';
      }
    } catch (e) {
      throw 'Something went wrong while rejecting repost order: $e';
    }
  }

  Future<RepostStatusItem> submitRepostProof({
    required String orderId,
    required File file,
    required String proofType,
    required String note,
  }) async {
    try {
      final response = await client.uploadFile(
        url: Endpoint.uploadRepostOrderProof(orderId),
        file: file,
        fieldName: 'files',
        extraFields: {
          'proofType': proofType,
          'proofUrl': '',
          'note': note,
        },
      );

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return RepostStatusItem.fromJson(response.responseData as Map<String, dynamic>);
      } else {
        throw response.errorMessage ?? 'Failed to upload proof';
      }
    } catch (e) {
      throw 'Something went wrong while submitting proof: $e';
    }
  }

  Future<RepostStatusItem> reviewRepostOrder({
    required String orderId,
    required String action,
    required String instructions,
  }) async {
    try {
      final response = await client.postRequest(
        url: Endpoint.reviewRepostOrder(orderId),
        body: {
          'action': action,
          'instructions': instructions,
        },
      );

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return RepostStatusItem.fromJson(response.responseData as Map<String, dynamic>);
      } else {
        throw response.errorMessage ?? 'Failed to review repost order';
      }
    } catch (e) {
      throw 'Something went wrong while reviewing repost order: $e';
    }
  }

  Future<List<RepostStatusItem>> fetchMySellerRepostOrders() async {
    try {
      final response = await client.getRequest(url: Endpoint.sellerRepostOrde);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final List data = response.responseData as List;
        // ignore: avoid_print
        print("SELLER DATA FROM API : $data");
        return data
            .map((json) =>
                RepostStatusItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw response.errorMessage ?? 'Failed to load seller repost orders';
      }
    } catch (e) {
      throw 'Something went wrong while fetching seller repost orders: $e';
    }
  }
}
