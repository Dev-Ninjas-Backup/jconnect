import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/features/add_services/repository/add_service_repository.dart';

class AddServiceController extends GetxController {
  final serviceNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final RxnString selectedServiceType = RxnString();

  /// Stores id + name + desc + price
  var services = <Map<String, dynamic>>[].obs;

  final currencyFormatter = CurrencyTextInputFormatter(symbol: '\$');
  var isSaveEnabled = false.obs;

  final AddServiceRepository repository = AddServiceRepository();

  @override
  void onInit() {
    super.onInit();
    fetchServicesFromProfile();
  }

  /// 🔹 LOAD SERVICES
  Future<void> fetchServicesFromProfile() async {
    try {
      EasyLoading.show(status: 'Loading services...');
      final response = await repository.fetchMyProfile();
      EasyLoading.dismiss();

      if (response['services'] is List) {
        services.assignAll(
          (response['services'] as List).map((svc) {
            return {
              'id': svc['id'],
              'name': svc['serviceName'],
              'desc': svc['description'],
              'price': '\$${svc['price']}',
            };
          }).toList(),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  /// 🔹 ADD SERVICE
  Future<void> addService() async {
    if (!isSaveEnabled.value) return;

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

      final svc = response['service'];

      services.add({
        'id': svc['id'],
        'name': svc['serviceName'],
        'desc': svc['description'],
        'price': '\$${svc['price']}',
      });

      serviceNameController.clear();
      descriptionController.clear();
      priceController.clear();
      selectedServiceType.value = null;
      isSaveEnabled.value = false;
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  /// 🔹 DELETE SERVICE (API + ROLLBACK)
  Future<void> deleteService(int index) async {
    final removedService = services[index];
    final serviceId = removedService['id'];

    services.removeAt(index);

    try {
      EasyLoading.show(status: 'Deleting service...');
      await repository.deleteService(serviceId);
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      services.insert(index, removedService);

      Get.snackbar(
        'Error',
        'Failed to delete service',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void checkIfSaveEnabled() {
    isSaveEnabled.value =
        serviceNameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        selectedServiceType.value != null;
  }

  @override
  void onClose() {
    serviceNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }
}

/// Currency formatter
class CurrencyTextInputFormatter extends TextInputFormatter {
  final String symbol;
  CurrencyTextInputFormatter({this.symbol = '\$'});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    final value = double.parse(digitsOnly) / 100;
    final newText = '$symbol${value.toStringAsFixed(2)}';

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
