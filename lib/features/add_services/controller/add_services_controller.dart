import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/features/add_services/repository/add_service_repository.dart';

class AddServiceController extends GetxController {
  final serviceNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final RxnString selectedServiceType = RxnString();

  // Stores id + name + desc + price
  var services = <Map<String, dynamic>>[].obs;

  var isSaveEnabled = false.obs;

  final AddServiceRepository repository = AddServiceRepository();

  @override
  void onInit() {
    super.onInit();
    fetchServicesFromProfile();
  }

  // LOAD SERVICES
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

  // ADD SERVICE
  Future<void> addService() async {
    if (!isSaveEnabled.value) return;

    // Parse price as double, default to 0.0 if invalid
    final priceValue = double.tryParse(priceController.text) ?? 0.0;

    try {
      EasyLoading.show(status: 'Saving service...');

      final response = await repository.createService(
        serviceName: serviceNameController.text.trim(),
        serviceType: selectedServiceType.value!,
        description: descriptionController.text.trim(),
        price: priceValue.toString(), // send as float string
      );

      EasyLoading.dismiss();

      final svc = response['service'];

      services.add({
        'id': svc['id'],
        'name': svc['serviceName'],
        'desc': svc['description'],
        'price': svc['price'], // just show as normal float
      });

      // Clear inputs
      serviceNameController.clear();
      descriptionController.clear();
      priceController.clear();
      selectedServiceType.value = null;
      isSaveEnabled.value = false;
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        'Error',
        'Failed to add service',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  //  DELETE SERVICE (API + ROLLBACK)
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
