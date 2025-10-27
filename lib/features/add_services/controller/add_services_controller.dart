import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddServiceController extends GetxController {
  final serviceNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  var services = <Map<String, String>>[].obs;

  // Currency formatter for price input
  final currencyFormatter = CurrencyTextInputFormatter(symbol: '\$');

  // Reactive variable to track if Save button should be enabled
  var isSaveEnabled = false.obs;

  void addService() {
    if (serviceNameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      services.add({
        'name': serviceNameController.text.trim(),
        'desc': descriptionController.text.trim(),
        'price': priceController.text.trim(),
      });

      serviceNameController.clear();
      descriptionController.clear();
      priceController.clear();

      isSaveEnabled.value = false;
    }
  }

  void removeService(int index) {
    services.removeAt(index);
  }

  void checkIfSaveEnabled() {
    isSaveEnabled.value =
        serviceNameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        priceController.text.isNotEmpty;
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
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');
    double value = double.parse(digitsOnly) / 100;
    final newText = '$symbol${value.toStringAsFixed(2)}';
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
