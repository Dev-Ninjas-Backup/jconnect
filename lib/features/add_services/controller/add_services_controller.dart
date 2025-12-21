import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/features/add_services/repository/add_service_repository.dart';

class AddServiceController extends GetxController {
  final serviceNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  // selected service type (SOCIAL_POST, SERVICE, ...)
  final RxnString selectedServiceType = RxnString();

  var services = <Map<String, String>>[].obs;

  // Currency formatter for price input
  final currencyFormatter = CurrencyTextInputFormatter(symbol: '\$');

  // Reactive variable to track if Save button should be enabled
  var isSaveEnabled = false.obs;

  final AddServiceRepository repository = AddServiceRepository();

  Future<void> addService() async {
    if (serviceNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        selectedServiceType.value == null) {
      return;
    }

    final priceValue = double.tryParse(
          priceController.text.replaceAll(RegExp(r'[^\d.]'), ''),
        ) ??
        0.0;

    try {
      EasyLoading.show(status: 'Saving service...');

      final response = await repository.createService(
        serviceName: serviceNameController.text.trim(),
        serviceType: selectedServiceType.value!,
        description: descriptionController.text.trim(),
        price: priceValue.toString(),
      );

      EasyLoading.dismiss();

      if (response.containsKey('service')) {
        final svc = response['service'];
        services.add({
          'name':
              svc['serviceName']?.toString() ??
              serviceNameController.text.trim(),
          'desc':
              svc['description']?.toString() ??
              descriptionController.text.trim(),
          'price': (svc['price'] != null)
              ? svc['price'].toString()
              : priceController.text.trim(),
        });

        // Clear form
        serviceNameController.clear();
        descriptionController.clear();
        priceController.clear();
        selectedServiceType.value = null;

        isSaveEnabled.value = false;
      } else {
        // Fallback if API returns only a message
        services.add({
          'name': serviceNameController.text.trim(),
          'desc': descriptionController.text.trim(),
          'price': priceController.text.trim(),
        });
      }
    } catch (e) {
      EasyLoading.dismiss();
      rethrow;
    }
  }

  void removeService(int index) {
    services.removeAt(index);
  }

  void checkIfSaveEnabled() {
    isSaveEnabled.value =
        serviceNameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        selectedServiceType.value != null &&
        selectedServiceType.value!.isNotEmpty;
  }

  @override
  void onClose() {
    serviceNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }
}

/// TextInputFormatter for currency input
class CurrencyTextInputFormatter extends TextInputFormatter {
  final String symbol;

  CurrencyTextInputFormatter({this.symbol = '\$'});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final value = double.parse(digitsOnly) / 100;
    final newText = '$symbol${value.toStringAsFixed(2)}';

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
