
// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class RequestServiceController extends GetxController {
  final SharedPreferencesHelperController pref = Get.find<SharedPreferencesHelperController>();

  final captionTextController = TextEditingController();
  final specialNoteController = TextEditingController();

  Rx<File?> selectedFile = Rx<File?>(null);
  Rx<String?> selectedFileName = Rx<String?>(null);
  Rx<DateTime?> promotionDate = Rx<DateTime?>(null);

  final String apiUrl = Endpoint.serviceRequest;

  String get formattedPromotionDate {
    if (promotionDate.value == null) return "mm/dd/yyyy";
    return DateFormat("MM/dd/yyyy • hh:mm a").format(promotionDate.value!);
  }

  /// Pick file (supports multiple file types)
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'mp4', 'jpg', 'jpeg', 'png', 'gif', 'pdf', 'mov', 'avi', 'flv', 'wav', 'aac'],
      );

      if (result != null && result.files.single.path != null) {
        selectedFile.value = File(result.files.single.path!);
        selectedFileName.value = result.files.single.name;
      }
    } catch (e) {
      EasyLoading.showError("Failed to pick file: $e");
    }
  }

  /// Clear selected file
  void clearFile() {
    selectedFile.value = null;
    selectedFileName.value = null;
  }

  /// Pick promotion date
  Future<void> pickPromotionDate(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    promotionDate.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  /// Submit service request — returns the full `serviceRequest` JSON on success, null on failure.
  Future<Map<String, dynamic>?> submitServiceRequest({
    required String serviceId,
    required double price,
  }) async {
    try {
      EasyLoading.show(status: "Submitting...");

      final token = await pref.getAccessRowToken();

      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Form fields
      request.fields['serviceId'] = serviceId;
      request.fields['price'] = price.toString();
      if (captionTextController.text.trim().isNotEmpty) {
        request.fields['captionOrInstructions'] = captionTextController.text.trim();
      }
      if (specialNoteController.text.trim().isNotEmpty) {
        request.fields['specialNotes'] = specialNoteController.text.trim();
      }
      if (promotionDate.value != null) {
        request.fields['promotionDate'] = promotionDate.value!.toUtc().toIso8601String();
      }

      // Optional file
      if (selectedFile.value != null) {
        request.files.add(await http.MultipartFile.fromPath('files', selectedFile.value!.path));
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess("Service request created successfully");
        final decoded = jsonDecode(respStr) as Map<String, dynamic>;
        final srData = decoded['serviceRequest'] as Map<String, dynamic>?;
        print("Response: $respStr");
        clearForm();
        return srData;
      } else {
        EasyLoading.showError("Failed: ${response.statusCode}");
        print("Response: $respStr");
        return null;
      }
    } catch (e) {
      EasyLoading.showError("Error: $e");
      return null;
    }
  }

  /// Clear form
  void clearForm() {
    captionTextController.clear();
    specialNoteController.clear();
    clearFile();
    promotionDate.value = null;
  }
}
