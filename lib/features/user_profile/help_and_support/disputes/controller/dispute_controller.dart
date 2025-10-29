import 'package:get/get.dart';
import '../model/dispute_model.dart';

class DisputeController extends GetxController {
  var disputes = <DisputeModel>[].obs;

  @override
  void onInit() {
    disputes.assignAll([
      DisputeModel(
        userName: 'DJ Scream',
        dealTitle: 'Music Review Deal',
        description: 'Didn’t receive proof video as agreed.',
        date: 'Sept 20, 2025',
        amount: 85,
        status: 'Under Review',
      ),
      DisputeModel(
        userName: 'DJ Scream',
        dealTitle: 'Music Review Deal',
        description: 'Didn’t receive proof video as agreed.',
        date: 'Sept 20, 2025',
        amount: 85,
        status: 'Resolved',
      ),
      DisputeModel(
        userName: 'DJ Scream',
        dealTitle: 'Music Review Deal',
        description: 'Didn’t receive proof video as agreed.',
        date: 'Sept 20, 2025',
        amount: 85,
        status: 'Pending',
      ),
    ]);
    super.onInit();
  }

  void addDispute(DisputeModel dispute) {
    disputes.add(dispute);
  }
}
