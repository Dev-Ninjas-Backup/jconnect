// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_timeline_step.dart';

class OrderDetailsController extends GetxController {
  final order = Rxn<OrderDetailsModel>();
  // seller average rating loaded from user endpoint
  final sellerAverage = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    final dynamic arguments = Get.arguments;

    dynamic incoming;
    Map<String, dynamic>? rawJson;

    if (arguments is Map<String, dynamic>) {
      if (arguments['raw'] is Map<String, dynamic>) {
        rawJson = arguments['raw'];
      }
      incoming ??= arguments['order'];
    } else {
      incoming = arguments;
    }

    // 1 Prefer raw API JSON (contains real timeline)
    if (rawJson != null) {
      try {
        order.value = OrderDetailsModel.fromJson(rawJson);
        return;
      } catch (_) {}
    }

    // 2️Already parsed
    if (incoming is OrderDetailsModel) {
      order.value = incoming;
      return;
    }

    // 3️Coming from OrderModel → build + generate timeline
    if (incoming is OrderModel) {
      final price = incoming.price;

      // Extract possible timestamps from the raw JSON when OrderModel lacks them
      final String? createdAtFromRaw = incoming.raw != null
          ? ((incoming.raw!['createdAt'])?.toString())
          : null;
      final String? deliveryDateFromRaw = incoming.raw != null
          ? ((incoming.raw!['deliveryDate'])?.toString())
          : null;
      final String? updatedAtFromRaw = incoming.raw != null
          ? ((incoming.raw!['updatedAt'])?.toString())
          : null;
      final String? buyerIdFromRaw = incoming.raw != null
          ? ((incoming.raw!['buyerId'])?.toString())
          : null;
      final String? sellerIdFromRaw = incoming.raw != null
          ? ((incoming.raw!['sellerId'])?.toString())
          : null;

      order.value = OrderDetailsModel(
        id: incoming.orderId, // internal DB id
        orderCode: incoming.orderCode, // user-facing code
        platform: incoming.platform,
        serviceTitle: incoming.title,
        subServiceTitle: incoming.description ?? '',
        sellerName: incoming.sellerName,
        sellerEmail: incoming.sellerEmail,
        sellerUsername: incoming.sellerUsername,
        sellerimageUrl: '',
        sellerId: sellerIdFromRaw ?? '',
        rating: 0.0,
        status: incoming.status,
        orderCreated: createdAtFromRaw ?? '',
        deliveryDate: deliveryDateFromRaw ?? '',
        servicePrice: price,
        platformFee: price,
        // OrderModel does not always include a platformRate; use empty string fallback
        platformRate: '',
        buyerId: buyerIdFromRaw ?? '',
        proofUrl: [],
        timeline: _generateTimeline(
          status: incoming.status,
          createdAt: createdAtFromRaw,
          deliveryDate: deliveryDateFromRaw,
          updatedAt: updatedAtFromRaw,
        ),
        isCancalProofSubmitted: false,
      );
      return;
    }

    // 4️ Fallback raw map
    if (incoming is Map<String, dynamic>) {
      try {
        order.value = OrderDetailsModel.fromJson(incoming);
      } catch (_) {}
    }
  }

  // Generates timeline when API doesn’t provide one
  List<OrderTimelineStep> _generateTimeline({
    required String status,
    String? createdAt,
    String? deliveryDate,
    String? updatedAt,
    bool isCancalProofSubmitted = false,
  }) {
    final steps = [
      'Order has been placed',
      'Waiting to be Reviewed',
      'Waiting for proof',
      'Completed',
    ];

    int completedIndex = -1;
    switch (status.toUpperCase()) {
      case 'PENDING':
        completedIndex = -1; // none completed
        break;
      case 'ACTIVE':
      case 'IN_PROGRESS':
        completedIndex =
            1; // "Order placed" and "Waiting to be Reviewed" completed
        break;
      case 'PROOF_SUBMITTED':
        // If proof was cancelled, mark "Waiting for proof" as incomplete
        completedIndex = isCancalProofSubmitted ? 1 : 2;
        break;
      case 'RELEASED':
      case 'COMPLETE':
      case 'COMPLETED':
        completedIndex = 3; // all steps completed
        break;
      case 'PAYMENTCONFIRM':
      case 'PAYMENT_CONFIRM':
        completedIndex = 1;
        break;
    }

    // Determine first step date according to status
    final updated = updatedAt ?? '';
    final statusUpper = status.toUpperCase();

    final firstStepDate = statusUpper == 'PENDING'
        ? ''
        : (statusUpper == 'ACTIVE' || statusUpper == 'IN_PROGRESS'
              ? (updated.isNotEmpty ? updated : '')
              : (createdAt ?? ''));

    return List.generate(steps.length, (i) {
      // Provide timestamps for intermediate steps when relevant
      String dt = '';
      if (i == 0) dt = firstStepDate;
      if ((i == 1 || i == 2) && statusUpper == 'PROOF_SUBMITTED') {
        dt = updated.isNotEmpty ? updated : '';
      }
      if (i == 3) dt = deliveryDate ?? '';

      return OrderTimelineStep(
        title: steps[i],
        dateTime: dt,
        isCompleted: i <= completedIndex,
      );
    });
  }

  /// Upload proof file for the currently loaded order. Returns true on success.
  Future<bool> uploadProof(File file) async {
    final current = order.value;
    if (current == null) return false;

    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('No auth token available');
        return false;
      }

      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final url = '${Endpoint.proofUpload}?orderId=${current.id}';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({'Authorization': authHeader, 'accept': '*/*'});

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      EasyLoading.show(status: 'Uploading proof...');
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      EasyLoading.dismiss();

      print('🔥 [UPLOAD PROOF] Status: ${resp.statusCode}');
      print('🔥 [UPLOAD PROOF] Body: ${resp.body}');

      // Accept 200-299 as success (API might return 201 Created)
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        EasyLoading.showSuccess('Proof uploaded');

        // Parse the response to get updated proof URL and other data
        List<String> newProofUrl = [];
        bool isCancalProofSubmitted = false;

        try {
          final respJson = jsonDecode(resp.body);
          if (respJson is Map<String, dynamic>) {
            // Extract proofUrl from response
            if (respJson['proofUrl'] != null) {
              if (respJson['proofUrl'] is List) {
                newProofUrl = (respJson['proofUrl'] as List)
                    .map((e) => e.toString())
                    .toList();
              } else if (respJson['proofUrl'] is String) {
                newProofUrl = [respJson['proofUrl'].toString()];
              }
            }

            // Extract isCancalProofSubmitted flag
            if (respJson['isCancalProofSubmitted'] != null) {
              isCancalProofSubmitted =
                  respJson['isCancalProofSubmitted'] == true ||
                  respJson['isCancalProofSubmitted'] == 1 ||
                  respJson['isCancalProofSubmitted'] == '1' ||
                  respJson['isCancalProofSubmitted'] == 'true';
            }
          }
        } catch (e) {
          print('⚠️ [UPLOAD PROOF] Could not parse response: $e');
          // If parsing fails, we'll just use empty proofUrl
          newProofUrl = [];
        }

        // Update order with new proof URL and isCancalProofSubmitted flag
        final updatedAt = DateTime.now().toIso8601String();
        final newTimeline = _generateTimeline(
          status: 'PROOF_SUBMITTED',
          createdAt: current.orderCreated.isNotEmpty
              ? current.orderCreated
              : null,
          deliveryDate: current.deliveryDate.isNotEmpty
              ? current.deliveryDate
              : null,
          updatedAt: updatedAt,
          isCancalProofSubmitted: isCancalProofSubmitted,
        );

        order.value = OrderDetailsModel(
          id: current.id,
          orderCode: current.orderCode,
          platform: current.platform,
          serviceTitle: current.serviceTitle,
          subServiceTitle: current.subServiceTitle,
          sellerName: current.sellerName,
          sellerEmail: current.sellerEmail,
          sellerUsername: current.sellerUsername,
          sellerimageUrl: current.sellerimageUrl,
          sellerId: current.sellerId,
          rating: current.rating,
          status: 'PROOF_SUBMITTED',
          orderCreated: current.orderCreated,
          deliveryDate: current.deliveryDate,
          servicePrice: current.servicePrice,
          platformRate: current.platformRate,
          platformFee: current.platformFee,
          buyerId: current.buyerId,
          proofUrl: newProofUrl,
          isCancalProofSubmitted: isCancalProofSubmitted,
          timeline: newTimeline,
        );

        // Call cancel-proof API with isCancalProofSubmitted=false to ensure proof is marked as accepted
        try {
          final cancelUrl =
              '${Endpoint.baseUrl}/orders/${current.id}/cancel-proof?isCancalProofSubmitted=false';
          final cancelResp = await http.patch(
            Uri.parse(cancelUrl),
            headers: {'Authorization': authHeader, 'Accept': '*/*'},
          );

          print('🔥 [RESET PROOF FLAG] Status: ${cancelResp.statusCode}');
          print('🔥 [RESET PROOF FLAG] Body: ${cancelResp.body}');

          if (cancelResp.statusCode >= 200 && cancelResp.statusCode < 300) {
            // Parse response to ensure isCancalProofSubmitted is false
            try {
              final resetJson = jsonDecode(cancelResp.body);
              if (resetJson is Map<String, dynamic>) {
                bool resetFlag = false;
                if (resetJson['isCancalProofSubmitted'] != null) {
                  resetFlag =
                      resetJson['isCancalProofSubmitted'] == true ||
                      resetJson['isCancalProofSubmitted'] == 1 ||
                      resetJson['isCancalProofSubmitted'] == '1' ||
                      resetJson['isCancalProofSubmitted'] == 'true';
                }

                // Update with confirmed false flag
                final confirmedTimeline = _generateTimeline(
                  status: 'PROOF_SUBMITTED',
                  createdAt: current.orderCreated.isNotEmpty
                      ? current.orderCreated
                      : null,
                  deliveryDate: current.deliveryDate.isNotEmpty
                      ? current.deliveryDate
                      : null,
                  updatedAt: updatedAt,
                  isCancalProofSubmitted: resetFlag,
                );

                order.value = OrderDetailsModel(
                  id: current.id,
                  orderCode: current.orderCode,
                  platform: current.platform,
                  serviceTitle: current.serviceTitle,
                  subServiceTitle: current.subServiceTitle,
                  sellerName: current.sellerName,
                  sellerEmail: current.sellerEmail,
                  sellerUsername: current.sellerUsername,
                  sellerimageUrl: current.sellerimageUrl,
                  sellerId: current.sellerId,
                  rating: current.rating,
                  status: 'PROOF_SUBMITTED',
                  orderCreated: current.orderCreated,
                  deliveryDate: current.deliveryDate,
                  servicePrice: current.servicePrice,
                  platformRate: current.platformRate,
                  platformFee: current.platformFee,
                  buyerId: current.buyerId,
                  proofUrl: newProofUrl,
                  isCancalProofSubmitted: resetFlag,
                  timeline: confirmedTimeline,
                );
              }
            } catch (e) {
              print('⚠️ [RESET PROOF FLAG] Could not parse response: $e');
            }
          }
        } catch (e) {
          print('⚠️ [RESET PROOF FLAG] Error calling cancel-proof API: $e');
          // Continue anyway - proof is already uploaded
        }

        return true;
      } else {
        EasyLoading.showError('Failed: ${resp.statusCode}');
        return false;
      }
    } catch (e) {
      EasyLoading.showError('Upload error: $e');
      return false;
    }
  }

  /// Confirm order and release payment (buyer action). Returns true on success.
  Future<bool> confirmOrder() async {
    final current = order.value;
    if (current == null) return false;

    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('No auth token available');
        return false;
      }

      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final url = Endpoint.releasePayment;

      final body = jsonEncode({'orderID': current.id});

      EasyLoading.show(status: 'Confirming order...');
      final resp = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: body,
      );
      EasyLoading.dismiss();

      print('🔥 [CONFIRM ORDER] Status: ${resp.statusCode}');
      print('🔥 [CONFIRM ORDER] Body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        EasyLoading.showSuccess('Order confirmed');
        final updatedAt = DateTime.now().toIso8601String();
        applyStatusUpdate(current.id, 'RELEASED', updatedAt: updatedAt);
        return true;
      } else {
        EasyLoading.showError('Failed: ${resp.statusCode}');
        return false;
      }
    } catch (e) {
      EasyLoading.showError('Confirmation error: $e');
      return false;
    }
  }

  /// Apply a status update to the currently held OrderDetailsModel (if it
  /// matches [orderId]) so UI (timeline) updates immediately without
  /// re-entering the screen.
  void applyStatusUpdate(String orderId, String status, {String? updatedAt}) {
    final current = order.value;
    if (current == null) return;
    if (current.id != orderId) return;

    final newTimeline = _generateTimeline(
      status: status,
      createdAt: current.orderCreated.isNotEmpty ? current.orderCreated : null,
      deliveryDate: current.deliveryDate.isNotEmpty
          ? current.deliveryDate
          : null,
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
      isCancalProofSubmitted: current.isCancalProofSubmitted,
    );

    order.value = OrderDetailsModel(
      id: current.id,
      orderCode: current.orderCode,
      platform: current.platform,
      serviceTitle: current.serviceTitle,
      subServiceTitle: current.subServiceTitle,
      sellerName: current.sellerName,
      sellerUsername: current.sellerUsername,
      sellerimageUrl: current.sellerimageUrl,
      sellerEmail: current.sellerEmail,
      sellerId: current.sellerId,
      rating: current.rating,
      status: status,
      orderCreated: current.orderCreated,
      deliveryDate: current.deliveryDate,
      servicePrice: current.servicePrice,
      platformRate: current.platformRate,
      platformFee: current.platformFee,
      buyerId: current.buyerId,
      proofUrl: current.proofUrl,
      isCancalProofSubmitted: current.isCancalProofSubmitted,
      timeline: newTimeline,
    );
  }

  /// Post a review for the seller. Returns true on success.
  Future<bool> postReview({
    required int rating,
    required String reviewText,
  }) async {
    final current = order.value;
    if (current == null || current.sellerId.isEmpty) {
      EasyLoading.showError('Seller information missing');
      return false;
    }

    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('Authentication required');
        return false;
      }

      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final url = Endpoint.postReview;

      final body = jsonEncode({
        'artistId': current.sellerId,
        'rating': rating,
        'reviewText': reviewText,
      });

      EasyLoading.show(status: 'Posting review...');
      final resp = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: body,
      );
      EasyLoading.dismiss();

      print('🔥 [POST REVIEW] Status: ${resp.statusCode}');
      print('🔥 [POST REVIEW] Body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        EasyLoading.showSuccess('Review posted successfully!');
        return true;
      } else {
        // Parse error message from JSON response
        String errorMsg = 'Failed to post review';
        try {
          final respJson = jsonDecode(resp.body);
          errorMsg = respJson['message'] ?? errorMsg;
        } catch (_) {
          // If JSON parse fails, use generic message
        }
        EasyLoading.showError(errorMsg);
        return false;
      }
    } catch (e) {
      EasyLoading.showError('Review error: $e');
      return false;
    }
  }

  /// Reject proof submitted by seller (buyer action). Returns true on success.
  Future<bool> rejectProof() async {
    final current = order.value;
    if (current == null) return false;

    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('No auth token available');
        return false;
      }

      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final url = Endpoint.cancelProof(current.id);

      EasyLoading.show(status: 'Rejecting proof...');
      final resp = await http.patch(
        Uri.parse(url),
        headers: {'Authorization': authHeader, 'Accept': '*/*'},
      );
      EasyLoading.dismiss();

      print('🔥 [REJECT PROOF] Status: ${resp.statusCode}');
      print('🔥 [REJECT PROOF] Body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        EasyLoading.showSuccess('Proof rejected. Please upload new proof.');
        // Reset to IN_PROGRESS status with empty proofUrl
        final updatedAt = DateTime.now().toIso8601String();
        order.value = OrderDetailsModel(
          id: current.id,
          orderCode: current.orderCode,
          platform: current.platform,
          serviceTitle: current.serviceTitle,
          subServiceTitle: current.subServiceTitle,
          sellerName: current.sellerName,
          sellerEmail: current.sellerEmail,
          sellerUsername: current.sellerUsername,
          sellerimageUrl: current.sellerimageUrl,
          sellerId: current.sellerId,
          rating: current.rating,
          status: 'IN_PROGRESS',
          orderCreated: current.orderCreated,
          deliveryDate: current.deliveryDate,
          servicePrice: current.servicePrice,
          platformRate: current.platformRate,
          platformFee: current.platformFee,
          buyerId: current.buyerId,
          proofUrl: [], // Clear proof URLs
          isCancalProofSubmitted: false,
          timeline: _generateTimeline(
            status: 'IN_PROGRESS',
            createdAt: current.orderCreated.isNotEmpty
                ? current.orderCreated
                : null,
            deliveryDate: current.deliveryDate.isNotEmpty
                ? current.deliveryDate
                : null,
            updatedAt: updatedAt,
          ),
        );
        return true;
      } else {
        EasyLoading.showError('Failed: ${resp.statusCode}');
        return false;
      }
    } catch (e) {
      EasyLoading.showError('Rejection error: $e');
      return false;
    }
  }

  /// Fetch seller's profile (to obtain averageRating) by user id.
}
