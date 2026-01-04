import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/features/add_services/repository/add_service_repository.dart';

class AddServiceController extends GetxController {
  final serviceNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final RxnString selectedServiceType = RxnString();

  var services = <Map<String, dynamic>>[].obs;
  var isSaveEnabled = false.obs;

  RxnInt editingIndex = RxnInt(); // ✅00 ADDED: tracks editing

  final AddServiceRepository repository = AddServiceRepository();

  @override
  void onInit() {
    super.onInit();
    fetchServicesFromProfile();

    // ✅ CHANGED: Enable save button when any field changes
    serviceNameController.addListener(checkIfSaveEnabled);
    descriptionController.addListener(checkIfSaveEnabled);
    priceController.addListener(checkIfSaveEnabled);
  }

  @override
  void onClose() {
    serviceNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  /// FETCH SERVICES
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
              'price': svc['price'],
              'serviceType': svc['serviceType'], // ✅ CHANGED: keep type
            };
          }).toList(),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        'Error',
        'Failed to load services',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// ADD OR UPDATE SERVICE
  Future<void> saveService() async {
    // ✅ CHANGED: combines add & update
    if (!isSaveEnabled.value) return;

    final priceValue = double.tryParse(priceController.text) ?? 0.0;

    try {
      EasyLoading.show(
        status: editingIndex.value != null
            ? 'Updating service...'
            : 'Saving service...',
      );

      Map<String, dynamic> response;

      if (editingIndex.value != null) {
        // UPDATE SERVICE
        final index = editingIndex.value!;
        final service = services[index];

        response = await repository.updateService(
          id: service['id'],
          serviceName: serviceNameController.text.trim(),
          serviceType: selectedServiceType.value!,
          description: descriptionController.text.trim(),
          price: priceValue.toString(),
        );

        final updatedSvc = response['service'];
        services[index] = {
          'id': updatedSvc['id'],
          'name': updatedSvc['serviceName'],
          'desc': updatedSvc['description'],
          'price': updatedSvc['price'],
          'serviceType': updatedSvc['serviceType'], // ✅ CHANGED
        };
      } else {
        // ADD NEW SERVICE
        response = await repository.createService(
          serviceName: serviceNameController.text.trim(),
          serviceType: selectedServiceType.value!,
          description: descriptionController.text.trim(),
          price: priceValue.toString(),
        );

        final svc = response['service'];
        services.add({
          'id': svc['id'],
          'name': svc['serviceName'],
          'desc': svc['description'],
          'price': svc['price'],
          'serviceType': svc['serviceType'], // ✅ CHANGED
        });
      }

      EasyLoading.dismiss();
      clearForm();
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        'Error',
        editingIndex.value != null
            ? 'Failed to update service'
            : 'Failed to add service',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// DELETE SERVICE
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

  /// START EDITING SERVICE
  void startEditingService(int index) {
    // ✅ ADDED
    final svc = services[index];
    serviceNameController.text = svc['name'];
    descriptionController.text = svc['desc'];
    priceController.text = svc['price'].toString();
    selectedServiceType.value = svc['serviceType'];
    editingIndex.value = index;
    isSaveEnabled.value = true;
  }

  /// CLEAR FORM
  void clearForm() {
    // ✅ CHANGED
    serviceNameController.clear();
    descriptionController.clear();
    priceController.clear();
    selectedServiceType.value = null;
    isSaveEnabled.value = false;
    editingIndex.value = null;
  }

  /// ENABLE SAVE BUTTON
  void checkIfSaveEnabled() {
    // ✅ CHANGED: reactive form validation
    isSaveEnabled.value =
        serviceNameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        selectedServiceType.value != null &&
        selectedServiceType.value!.isNotEmpty;
  }
}
