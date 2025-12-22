import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/dispute_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisputeController extends GetxController {
  // List of disputes
  var disputes = <DisputeModel>[].obs;

  // List of user's orders
  var orders = <Map<String, dynamic>>[].obs;

  // UI-related reactive variables
  var selectedOrderId = RxnString();
  var proofImage = Rxn<File>();
  var issueController = Rx<TextEditingController>(TextEditingController());

  // Endpoints
  static const String baseUrl = 'https://jconnect-server.saikat.com.bd';
  static const String getDisputesEndpoint = '$baseUrl/disputes/my';
  static const String getOrdersEndpoint = '$baseUrl/orders/my-orders';
  static const String raiseDisputeEndpoint = '$baseUrl/disputes';

  @override
  void onInit() {
    fetchDisputes();
    fetchOrders();
    super.onInit();
  }

  // Fetch all disputes for the current user
  Future<void> fetchDisputes() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse(getDisputesEndpoint),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        disputes.assignAll(data.map((e) => DisputeModel.fromJson(e)).toList());
      } else {
        EasyLoading.showError('Failed to fetch disputes');
      }
    } catch (e) {
      EasyLoading.showError('Something went wrong');
    }
  }

  // Fetch all orders for the current user
  Future<void> fetchOrders() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse(getOrdersEndpoint),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        orders.assignAll(data.map((e) => e as Map<String, dynamic>).toList());
      } else {
        EasyLoading.showError('Failed to fetch orders');
      }
    } catch (e) {
      EasyLoading.showError('Something went wrong');
    }
  }

  // Raise a new dispute
  Future<bool> raiseDispute({
    required String orderId,
    required String description,
    File? proofImage,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(raiseDisputeEndpoint),
      );
      request.headers['Authorization'] = token;
      request.fields['orderId'] = orderId;
      request.fields['description'] = description;

      if (proofImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('files', proofImage.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update local disputes list
        final order = orders.firstWhere((o) => o['id'] == orderId);
        disputes.insert(
          0,
          DisputeModel(
            userName: order['seller']?['full_name'] ?? 'Unknown',
            dealTitle: order['service']?['serviceName'] ?? 'Unknown',
            description: description,
            date: 'Today',
            amount: (order['amount'] ?? 0).toDouble(),
            status: 'UNDER_REVIEW',
          ),
        );

        // Reset UI state
        selectedOrderId.value = null;
        this.proofImage.value = null;
        issueController.value.clear();

        EasyLoading.showSuccess('Dispute submitted');
        return true;
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? 'Failed to submit dispute';
        EasyLoading.showError(message);
        return false;
      }
    } catch (e) {
      EasyLoading.showError('Something went wrong');
      return false;
    }
  }

  // Add dispute manually (used for local UI updates)
  void addDispute(DisputeModel dispute) {
    disputes.insert(0, dispute);
  }

  // Helper: get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
