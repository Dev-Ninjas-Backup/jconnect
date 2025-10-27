import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';

class OrderDetailsController extends GetxController {
  final order = Rxn<OrderDetailsModel>();

  @override
  void onInit() {
    super.onInit();
    loadMockOrder();
  }

  void loadMockOrder() {
    order.value = OrderDetailsModel(
      id: '#DJCX29381',
      platform: 'Instagram',
      serviceTitle: 'Social Post Promotion',
      subServiceTitle: 'Fixed service',
      reviewerName: 'DJ Nova',
      reviewerHandle: '@djnova',
      reviewerImage: Imagepath.profileImage,
      rating: 4.9,
      status: 'Pending',
      orderCreated: '14 Oct 2025',
      deliveryDate: '18 Oct 2025',
      servicePrice: 50.00,
      platformFee: 5.00,
      timeline: [
        TimelineStep(
          title: 'Order has been placed',
          dateTime: '14 Oct\n09:30 AM',
          isCompleted: true,
        ),
        TimelineStep(
          title: 'Waiting for Reviewer',
          dateTime: '',
          isCompleted: false,
        ),
        TimelineStep(
          title: 'Waiting for Proof',
          dateTime: '',
          isCompleted: false,
        ),
        TimelineStep(title: 'Completed', dateTime: '', isCompleted: false),
      ],
    );
  }
}
