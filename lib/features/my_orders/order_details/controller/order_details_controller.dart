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
import 'package:jconnect/features/user_profile/help_and_support/disputes/model/dispute_model.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';

class OrderDetailsController extends GetxController {
  final order = Rxn<OrderDetailsModel>();
  // seller average rating loaded from user endpoint
  final sellerAverage = Rxn<double>();
  final isLoading = false.obs;
  final hasOpenDispute = false.obs;
  final openDispute = Rxn<DisputeModel>();
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
        // Check if there is an active dispute for this order
        await checkDisputeStatus(orderId, authHeader: authHeader);
      } else {
        final errorMsg = _extractErrorMessage(
          response.body,
          fallback: 'Failed to load order details: ${response.statusCode}',
        );
        EasyLoading.showError(errorMsg);
      }
    } catch (e) {
      print('❌ [FETCH ORDER DETAILS] Error: $e');
      EasyLoading.showError('Error loading order details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Query GET /disputes/my to check whether there is an open (UNDER_REVIEW) dispute for this order.
  Future<void> checkDisputeStatus(String orderId, {String? authHeader}) async {
    try {
      String? header = authHeader;
      if (header == null) {
        final prefs = Get.find<SharedPreferencesHelperController>();
        final token = await prefs.getAccessToken();
        if (token == null || token.isEmpty) return;
        header = token.startsWith('Bearer ') ? token : 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(Endpoint.dispute),
        headers: {'Authorization': header, 'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          final active = data.firstWhereOrNull((e) {
            if (e is! Map) return false;
            final dOrderId =
                (e['orderId'] ??
                        e['order']?['id'] ??
                        e['order']?['orderId'] ??
                        '')
                    .toString();
            final status = (e['status'] ?? '').toString().toUpperCase();
            return dOrderId == orderId && status == 'UNDER_REVIEW';
          });

          if (active != null) {
            hasOpenDispute.value = true;
            try {
              openDispute.value = DisputeModel.fromJson(
                Map<String, dynamic>.from(active),
              );
            } catch (_) {}
            return;
          }
        }
      }
      hasOpenDispute.value = false;
      openDispute.value = null;
    } catch (e) {
      print('⚠️ Error checking dispute status: $e');
    }
  }

  // Generates timeline when API doesn't provide one
  List<OrderTimelineStep> _generateTimeline({
    required String status,
    String? createdAt,
    String? inProgressAt,
    String? proofSubmittedAt,
    String? resubmitAt,
    String? releasedAt,
    String? cancelledAt,
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
        dateTime: inProgressAt != null && inProgressAt.isNotEmpty
            ? inProgressAt
            : (statusUpper != 'PENDING' ? updated : ''),
        isCompleted:
            statusUpper != 'PENDING' ||
            (inProgressAt != null && inProgressAt.isNotEmpty),
      ),
      OrderTimelineStep(
        title: 'Waiting for proof',
        dateTime: proofSubmittedAt != null && proofSubmittedAt.isNotEmpty
            ? proofSubmittedAt
            : ((statusUpper == 'PROOF_SUBMITTED' ||
                      isResubmit ||
                      statusUpper == 'RELEASED')
                  ? updated
                  : ''),
        isCompleted:
            statusUpper == 'PROOF_SUBMITTED' ||
            statusUpper == 'RELEASED' ||
            (proofSubmittedAt != null && proofSubmittedAt.isNotEmpty),
      ),
    ];

    if (isResubmit || (resubmitAt != null && resubmitAt.isNotEmpty)) {
      steps.add(
        OrderTimelineStep(
          title: 'Proof Rejected - Resubmit Required',
          dateTime: resubmitAt != null && resubmitAt.isNotEmpty
              ? resubmitAt
              : updated,
          isCompleted: true,
          description: reason,
        ),
      );
    }

    final isCancelled = statusUpper == 'CANCELLED';
    final completedDate = isCancelled
        ? (cancelledAt != null && cancelledAt.isNotEmpty
              ? cancelledAt
              : updated)
        : (releasedAt != null && releasedAt.isNotEmpty
              ? releasedAt
              : (statusUpper == 'RELEASED' ? (deliveryDate ?? updated) : ''));

    steps.add(
      OrderTimelineStep(
        title: isCancelled ? 'Order Cancelled' : 'Completed',
        dateTime: completedDate,
        isCompleted:
            statusUpper == 'RELEASED' ||
            statusUpper == 'COMPLETE' ||
            statusUpper == 'COMPLETED' ||
            statusUpper == 'CANCELLED',
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
          final cancelUrl = Endpoint.cancelProof(
            current.id,
            isCancalProofSubmitted: false,
          );
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
        final errorMsg = _extractErrorMessage(
          resp.body,
          fallback: 'Failed: ${resp.statusCode}',
        );
        if (errorMsg.toLowerCase().contains('dispute') ||
            errorMsg.toLowerCase().contains('locked') ||
            errorMsg.toLowerCase().contains('under review')) {
          hasOpenDispute.value = true;
        }
        EasyLoading.showError(errorMsg);
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
        final errorMsg = _extractErrorMessage(
          resp.body,
          fallback: 'Failed: ${resp.statusCode}',
        );
        if (errorMsg.toLowerCase().contains('dispute') ||
            errorMsg.toLowerCase().contains('locked') ||
            errorMsg.toLowerCase().contains('under review')) {
          hasOpenDispute.value = true;
        }
        EasyLoading.showError(errorMsg);
        return false;
      }
    } catch (e) {
      EasyLoading.showError('Confirmation error: $e');
      return false;
    }
  }

  /// Buyer requests cancellation (PATCH /orders/:id/status?status=CANCELLED).
  /// Only valid while order is IN_PROGRESS, PROOF_SUBMITTED, or RESUBMIT.
  Future<bool> requestCancellation(String orderId) async {
    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('No auth token available');
        return false;
      }
      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final url = '${Endpoint.updateOrderStatus(orderId)}?status=CANCELLED';

      EasyLoading.show(status: 'Sending cancellation request...');
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      EasyLoading.dismiss();

      print('🔥 [REQUEST CANCELLATION] Status: ${response.statusCode}');
      print('🔥 [REQUEST CANCELLATION] Body: ${response.body}');

      if (response.statusCode == 200) {
        String message = 'Cancellation request sent to seller successfully';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) {
            message = body['message'].toString();
          }
        } catch (_) {}

        EasyLoading.showSuccess(message);

        // Update local state: isCancelRequested = true
        final current = order.value;
        if (current != null && current.id == orderId) {
          order.value = current.copyWith(
            isCancelRequested: true,
            cancelRequestedAt: DateTime.now().toIso8601String(),
          );
        }

        // Send courtesy message to seller in chat
        _sendCancellationChatMessage(orderId, authHeader);

        // Refresh details & orders list
        await fetchOrderDetails(orderId);
        try {
          if (Get.isRegistered<MyOrdersController>()) {
            Get.find<MyOrdersController>().loadOrders();
          }
        } catch (_) {}

        return true;
      } else {
        final errorMsg = _extractErrorMessage(
          response.body,
          fallback: 'Failed to request cancellation',
        );
        EasyLoading.showError(errorMsg);
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e');
      return false;
    }
  }

  /// Seller accepts cancellation request (PATCH /orders/:id/status?status=CANCELLED).
  Future<bool> acceptCancellation(String orderId) async {
    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('No auth token available');
        return false;
      }
      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final url = '${Endpoint.updateOrderStatus(orderId)}?status=CANCELLED';

      EasyLoading.show(status: 'Accepting cancellation...');
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      EasyLoading.dismiss();

      print('🔥 [ACCEPT CANCELLATION] Status: ${response.statusCode}');
      print('🔥 [ACCEPT CANCELLATION] Body: ${response.body}');

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Cancellation accepted. Order cancelled.');
        applyStatusUpdate(orderId, 'CANCELLED');
        await fetchOrderDetails(orderId);
        try {
          if (Get.isRegistered<MyOrdersController>()) {
            Get.find<MyOrdersController>().loadOrders();
          }
        } catch (_) {}
        return true;
      } else {
        final errorMsg = _extractErrorMessage(
          response.body,
          fallback: 'Failed to accept cancellation',
        );
        EasyLoading.showError(errorMsg);
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e');
      return false;
    }
  }

  /// Seller declines cancellation request (PATCH /orders/:id/cancel-request/decline).
  Future<bool> declineCancellation(String orderId) async {
    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('No auth token available');
        return false;
      }
      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final url = Endpoint.declineCancelRequest(orderId);

      EasyLoading.show(status: 'Declining cancellation...');
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': authHeader,
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );
      EasyLoading.dismiss();

      print('🔥 [DECLINE CANCELLATION] Status: ${response.statusCode}');
      print('🔥 [DECLINE CANCELLATION] Body: ${response.body}');

      if (response.statusCode == 200) {
        String msg =
            'Cancellation request declined. The order remains in progress.';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) {
            msg = body['message'].toString();
          }
        } catch (_) {}
        EasyLoading.showSuccess(msg);

        final current = order.value;
        if (current != null && current.id == orderId) {
          order.value = current.copyWith(
            isCancelRequested: false,
            cancelRequestedAt: '',
          );
        }

        await fetchOrderDetails(orderId);
        try {
          if (Get.isRegistered<MyOrdersController>()) {
            Get.find<MyOrdersController>().loadOrders();
          }
        } catch (_) {}
        return true;
      } else {
        final errorMsg = _extractErrorMessage(
          response.body,
          fallback: 'Failed to decline cancellation',
        );
        EasyLoading.showError(errorMsg);
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e');
      return false;
    }
  }

  /// Report an Issue / Raise a Dispute (POST /disputes).
  Future<bool> reportAnIssue({
    required String orderId,
    required String description,
    File? proofFile,
  }) async {
    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('Authentication required');
        return false;
      }
      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';

      EasyLoading.show(status: 'Submitting dispute report...');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Endpoint.raiseDispute),
      );
      request.headers['Authorization'] = authHeader;
      request.fields['orderId'] = orderId;
      request.fields['description'] = description;

      if (proofFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('files', proofFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      EasyLoading.dismiss();

      print('🔥 [REPORT AN ISSUE] Status: ${response.statusCode}');
      print('🔥 [REPORT AN ISSUE] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess(
          'Issue reported to DaConnect. Order is now under review.',
        );
        hasOpenDispute.value = true;
        await checkDisputeStatus(orderId, authHeader: authHeader);
        await fetchOrderDetails(orderId);
        return true;
      } else {
        final errorMsg = _extractErrorMessage(
          response.body,
          fallback: 'Failed to report issue',
        );
        EasyLoading.showError(errorMsg);
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error submitting dispute: $e');
      return false;
    }
  }

  /// Sends a courteous cancellation message in chat to seller.
  Future<void> _sendCancellationChatMessage(
    String orderId,
    String authHeader,
  ) async {
    try {
      final current = order.value;
      if (current == null) return;
      final recipientId = current.sellerId.trim();
      if (recipientId.isEmpty) return;

      final cancellationText =
          "Hope you're doing well. I would like to kindly cancel my order "
          "${current.orderCode.isNotEmpty ? '(Order ID: ${current.orderCode}) ' : ''}"
          ". Please let me know if any further action is required from my side. "
          "Thank you for your understanding.";

      await http.post(
        Uri.parse('${Endpoint.sendMessage}/$recipientId'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recipientId': recipientId,
          'content': cancellationText,
        }),
      );
    } catch (e) {
      print('[CANCEL CHAT MSG] Error: $e');
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
    final statusUpper = status.toUpperCase();
    final isResubmit =
        statusUpper == 'RESUBMIT' || current.isCancalProofSubmitted;

    String inProgressAt = current.inProgressAt;
    String proofSubmittedAt = current.proofSubmittedAt;
    String resubmitAt = current.resubmitAt;
    String releasedAt = current.releasedAt;
    String cancelledAt = current.cancelledAt;

    if (statusUpper == 'IN_PROGRESS' && inProgressAt.isEmpty) {
      inProgressAt = updatedTime;
    } else if (statusUpper == 'PROOF_SUBMITTED' && proofSubmittedAt.isEmpty) {
      proofSubmittedAt = updatedTime;
    } else if (statusUpper == 'RESUBMIT' && resubmitAt.isEmpty) {
      resubmitAt = updatedTime;
    } else if (statusUpper == 'RELEASED' && releasedAt.isEmpty) {
      releasedAt = updatedTime;
    } else if (statusUpper == 'CANCELLED' && cancelledAt.isEmpty) {
      cancelledAt = updatedTime;
    }

    final newTimeline = _generateTimeline(
      status: status,
      createdAt: current.orderCreated.isNotEmpty ? current.orderCreated : null,
      inProgressAt: inProgressAt.isNotEmpty ? inProgressAt : null,
      proofSubmittedAt: proofSubmittedAt.isNotEmpty ? proofSubmittedAt : null,
      resubmitAt: resubmitAt.isNotEmpty ? resubmitAt : null,
      releasedAt: releasedAt.isNotEmpty ? releasedAt : null,
      cancelledAt: cancelledAt.isNotEmpty ? cancelledAt : null,
      deliveryDate: current.deliveryDate.isNotEmpty
          ? current.deliveryDate
          : null,
      updatedAt: updatedTime,
      isCancalProofSubmitted: isResubmit,
      reason: reason,
    );

    // Clear deadlines when leaving PENDING or PROOF_SUBMITTED
    String? newAcceptDeadline = current.acceptDeadline;
    String? newProofDeadline = current.proofReviewDeadline;
    if (statusUpper != 'PENDING') {
      newAcceptDeadline = null;
    }
    if (statusUpper != 'PROOF_SUBMITTED') {
      newProofDeadline = null;
    }

    order.value = current.copyWith(
      status: status,
      inProgressAt: inProgressAt,
      proofSubmittedAt: proofSubmittedAt,
      resubmitAt: resubmitAt,
      releasedAt: releasedAt,
      cancelledAt: cancelledAt,
      timeline: newTimeline,
      isCancalProofSubmitted: isResubmit,
      acceptDeadline: newAcceptDeadline,
      proofReviewDeadline: newProofDeadline,
    );
  }

  Timer? _expiryCheckTimer;
  int _expiryRetryCount = 0;

  /// Handle client deadline countdown expiration.
  /// Refetches order and sets up brief polling retries because the server cron runs once a minute.
  void handleDeadlineExpired(String orderId) {
    print(
      '⏱️ [ORDER DEADLINE EXPIRED] Deadline hit zero for $orderId. Triggering refresh...',
    );
    _expiryCheckTimer?.cancel();
    _expiryRetryCount = 0;

    // Immediate refresh
    fetchOrderDetails(orderId);

    // Schedule retries at 15s intervals up to 5 times (75s total) to catch the 60s cron cycle
    _expiryCheckTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _expiryRetryCount++;
      final current = order.value;
      if (current == null || current.id != orderId) {
        timer.cancel();
        return;
      }

      final s = current.status.toUpperCase().trim();
      final isStillPending = s == 'PENDING' && current.acceptDeadline != null;
      final isStillProofSubmitted =
          s == 'PROOF_SUBMITTED' && current.proofReviewDeadline != null;

      if (!isStillPending && !isStillProofSubmitted) {
        print(
          '✅ [ORDER DEADLINE EXPIRED] Order state transitioned to $s. Stopping poll.',
        );
        timer.cancel();
        return;
      }

      if (_expiryRetryCount >= 5) {
        print(
          '⏱️ [ORDER DEADLINE EXPIRED] Max retry count reached. Stopping poll.',
        );
        timer.cancel();
        return;
      }

      print(
        '🔄 [ORDER DEADLINE EXPIRED] Retry $_expiryRetryCount/5 checking server for $orderId...',
      );
      fetchOrderDetails(orderId);
    });
  }

  @override
  void onClose() {
    _expiryCheckTimer?.cancel();
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
            eventOrderId =
                data['id']?.toString() ??
                data['orderId']?.toString() ??
                (data['order'] is Map
                    ? data['order']['id']?.toString()
                    : null) ??
                (data['order'] is Map
                    ? data['order']['orderId']?.toString()
                    : null);
          } else if (data is String) {
            eventOrderId = data;
          }

          final isOrderLifecycleEvent =
              event.event.startsWith('order:') &&
              event.event != 'order:success' &&
              event.event != 'order:error';

          if (eventOrderId == orderId ||
              (isOrderLifecycleEvent &&
                  (eventOrderId == null || eventOrderId.isEmpty))) {
            print(
              '🔄 Refreshing order details for $orderId due to socket event: ${event.event}',
            );
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
        final errorMsg = _extractErrorMessage(
          resp.body,
          fallback: 'Failed to post review',
        );
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
        final errorMsg = _extractErrorMessage(
          resp.body,
          fallback: 'Failed: ${resp.statusCode}',
        );
        EasyLoading.showError(errorMsg);
        return false;
      }
    } catch (e) {
      EasyLoading.showError('Rejection error: $e');
      return false;
    }
  }

  String _extractErrorMessage(
    String body, {
    String fallback = 'Something went wrong',
  }) {
    try {
      final respJson = jsonDecode(body);
      if (respJson is Map<String, dynamic>) {
        if (respJson['message'] != null) {
          if (respJson['message'] is List) {
            final list = (respJson['message'] as List)
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList();
            if (list.isNotEmpty) return list.join(', ');
          } else {
            final msg = respJson['message'].toString().trim();
            if (msg.isNotEmpty) return msg;
          }
        }
        if (respJson['data'] is Map<String, dynamic>) {
          final data = respJson['data'] as Map<String, dynamic>;
          if (data['message'] != null) {
            if (data['message'] is List) {
              final list = (data['message'] as List)
                  .map((e) => e.toString().trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              if (list.isNotEmpty) return list.join(', ');
            } else {
              final msg = data['message'].toString().trim();
              if (msg.isNotEmpty) return msg;
            }
          }
        }
        if (respJson['error'] != null) {
          final err = respJson['error'].toString().trim();
          if (err.isNotEmpty) return err;
        }
      }
    } catch (_) {}
    return fallback;
  }

  /// Fetch seller's profile (to obtain averageRating) by user id.
}
