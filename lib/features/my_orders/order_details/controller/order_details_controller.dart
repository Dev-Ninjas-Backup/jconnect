// ignore_for_file: avoid_print

import 'dart:async';
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
import 'package:jconnect/features/my_orders/order_socket/order_socket_service.dart';

class OrderDetailsController extends GetxController {
  final order = Rxn<OrderDetailsModel>();
  // seller average rating loaded from user endpoint
  final sellerAverage = Rxn<double>();
  final isLoading = false.obs;
  String? _loadedOrderId;
  StreamSubscription? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    _fetchDetailsIfNeeded();
  }

  @override
  void onReady() {
    super.onReady();
    _fetchDetailsIfNeeded();
  }

  void _fetchDetailsIfNeeded() {
    final orderId = _getOrderIdFromArguments(Get.arguments);
    if (orderId != null && orderId.isNotEmpty && orderId != _loadedOrderId) {
      fetchOrderDetails(orderId);
    }
  }

  String? _getOrderIdFromArguments(dynamic arguments) {
    if (arguments == null) return null;

    if (arguments is Map<String, dynamic>) {
      if (arguments['order'] != null) {
        final incoming = arguments['order'];
        if (incoming is OrderModel) return incoming.orderId;
        if (incoming is OrderDetailsModel) return incoming.id;
        if (incoming is Map<String, dynamic>) {
          return incoming['id']?.toString() ?? incoming['orderId']?.toString();
        }
      }
      if (arguments['raw'] != null) {
        final raw = arguments['raw'];
        if (raw is Map<String, dynamic>) return raw['id']?.toString();
      }
      return arguments['id']?.toString() ??
          arguments['orderId']?.toString() ??
          arguments['orderID']?.toString();
    }

    if (arguments is OrderModel) {
      return arguments.orderId;
    }
    if (arguments is OrderDetailsModel) {
      return arguments.id;
    }
    if (arguments is String) {
      return arguments;
    }
    return null;
  }

  Future<void> fetchOrderDetails(String orderId) async {
    if (_loadedOrderId != orderId) {
      _initSocket(orderId);
    }
    try {
      isLoading.value = true;
      _loadedOrderId = orderId;
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('No auth token available');
        return;
      }

      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final url = Endpoint.orderDetails(orderId);

      print('🔥 [FETCH ORDER DETAILS] Requesting url: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': authHeader, 'accept': '*/*'},
      );

      print('🔥 [FETCH ORDER DETAILS] Status: ${response.statusCode}');
      print('🔥 [FETCH ORDER DETAILS] Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> rawJson = jsonDecode(response.body);
        order.value = OrderDetailsModel.fromJson(rawJson);
        print(
          '✅ [ORDER DETAILS] Fetched from API successfully, ID: ${order.value?.id}',
        );
      } else {
        EasyLoading.showError(
          'Failed to load order details: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [FETCH ORDER DETAILS] Error: $e');
      EasyLoading.showError('Error loading order details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Generates timeline when API doesn't provide one
  List<OrderTimelineStep> _generateTimeline({
    required String status,
    String? createdAt,
    String? deliveryDate,
    String? updatedAt,
    bool isCancalProofSubmitted = false,
    String? reason,
  }) {
    final statusUpper = status.toUpperCase();
    final updated = updatedAt ?? '';
    final isResubmit = statusUpper == 'RESUBMIT' || isCancalProofSubmitted;

    final steps = <OrderTimelineStep>[
      OrderTimelineStep(
        title: 'Order has been placed',
        dateTime: createdAt ?? '',
        isCompleted: true,
      ),
      OrderTimelineStep(
        title: 'Waiting to be Reviewed',
        dateTime: statusUpper != 'PENDING' ? updated : '',
        isCompleted: statusUpper != 'PENDING',
      ),
      OrderTimelineStep(
        title: 'Waiting for proof',
        dateTime: (statusUpper == 'PROOF_SUBMITTED' || isResubmit || statusUpper == 'RELEASED') ? updated : '',
        isCompleted: statusUpper == 'PROOF_SUBMITTED' || statusUpper == 'RELEASED',
      ),
    ];

    if (isResubmit) {
      steps.add(
        OrderTimelineStep(
          title: 'Proof Rejected - Resubmit Required',
          dateTime: updated,
          isCompleted: true,
          description: reason,
        ),
      );
    }

    steps.add(
      OrderTimelineStep(
        title: statusUpper == 'CANCELLED' ? 'Order Cancelled' : 'Completed',
        dateTime: statusUpper == 'RELEASED' ? (deliveryDate ?? updated) : (statusUpper == 'CANCELLED' ? updated : ''),
        isCompleted: statusUpper == 'RELEASED' || statusUpper == 'COMPLETE' || statusUpper == 'COMPLETED' || statusUpper == 'CANCELLED',
      ),
    );

    return steps;
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

        order.value = current.copyWith(
          status: 'PROOF_SUBMITTED',
          proofUrl: newProofUrl,
          isCancalProofSubmitted: isCancalProofSubmitted,
          timeline: newTimeline,
        );

        // Call cancel-proof API with isCancalProofSubmitted=false to ensure proof is marked as accepted
        try {
          final cancelUrl =
              Endpoint.cancelProof(current.id, isCancalProofSubmitted: false);
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

                order.value = current.copyWith(
                  status: 'PROOF_SUBMITTED',
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
  void applyStatusUpdate(
    String orderId,
    String status, {
    String? updatedAt,
    String? reason,
  }) {
    final current = order.value;
    if (current == null) return;
    if (current.id != orderId) return;

    final updatedTime = updatedAt ?? DateTime.now().toIso8601String();
    final isResubmit = status.toUpperCase() == 'RESUBMIT' || current.isCancalProofSubmitted;

    final newTimeline = _generateTimeline(
      status: status,
      createdAt: current.orderCreated.isNotEmpty ? current.orderCreated : null,
      deliveryDate: current.deliveryDate.isNotEmpty
          ? current.deliveryDate
          : null,
      updatedAt: updatedTime,
      isCancalProofSubmitted: isResubmit,
      reason: reason,
    );

    order.value = current.copyWith(
      status: status,
      timeline: newTimeline,
      isCancalProofSubmitted: isResubmit,
    );
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    if (_loadedOrderId != null) {
      try {
        OrderSocketService().leaveOrder(_loadedOrderId!);
      } catch (_) {}
    }
    super.onClose();
  }

  Future<void> _initSocket(String orderId) async {
    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessRowToken();
      if (token != null && token.isNotEmpty) {
        final socketService = OrderSocketService();
        if (!socketService.isConnected) {
          socketService.connect(token: token);
        }

        // Leave previous order room if any
        if (_loadedOrderId != null && _loadedOrderId != orderId) {
          socketService.leaveOrder(_loadedOrderId!);
        }

        // Join the specific order room
        socketService.joinOrder(orderId);

        _socketSubscription?.cancel();
        _socketSubscription = socketService.eventStream.listen((event) {
          final data = event.data;
          print('📩 [ORDER SOCKET EVENT] Event: ${event.event}, Data: $data');

          String? eventOrderId;
          if (data is Map) {
            eventOrderId = data['id']?.toString() ??
                data['orderId']?.toString() ??
                (data['order'] is Map ? data['order']['id']?.toString() : null) ??
                (data['order'] is Map ? data['order']['orderId']?.toString() : null);
          } else if (data is String) {
            eventOrderId = data;
          }

          final isOrderLifecycleEvent = event.event.startsWith('order:') &&
              event.event != 'order:success' &&
              event.event != 'order:error';

          if (eventOrderId == orderId ||
              (isOrderLifecycleEvent && (eventOrderId == null || eventOrderId.isEmpty))) {
            print('🔄 Refreshing order details for $orderId due to socket event: ${event.event}');
            fetchOrderDetails(orderId);
          }
        });
      }
    } catch (e) {
      print('⚠️ Error initializing socket in OrderDetailsController: $e');
    }
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
  Future<bool> rejectProof({required String reason}) async {
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
        headers: {
          'Authorization': authHeader,
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': reason}),
      );
      EasyLoading.dismiss();

      print('🔥 [REJECT PROOF] Status: ${resp.statusCode}');
      print('🔥 [REJECT PROOF] Body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        EasyLoading.showSuccess('Proof rejected. Please upload new proof.');

        final updatedAt = DateTime.now().toIso8601String();
        applyStatusUpdate(
          current.id,
          'RESUBMIT',
          updatedAt: updatedAt,
          reason: reason,
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
