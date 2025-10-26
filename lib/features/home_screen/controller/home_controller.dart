import 'package:get/get.dart';
import 'package:jconnect/features/home_screen/model/start_deal_model.dart';

class HomeController extends GetxController {
  final RxList<StartDealModel> startDealList = <StartDealModel>[].obs;
  @override
  void onInit() {
    startDealList.addAll([
      StartDealModel(
        title: "🔥 Weekend Deal – 10% Off on All Deals!",
        subTitle:
            "Promote your content now and get featured feedback before Sunday. (Utilize discount for fast, high-visibility placement.)",
        ontap: () {},
      ),
            StartDealModel(
        title: "🔥 Weekend Deal – 10% Off on All Deals!",
        subTitle:
            "Promote your content now and get featured feedback before Sunday. (Utilize discount for fast, high-visibility placement.)",
        ontap: () {},
      ),
            StartDealModel(
        title: "🔥 Weekend Deal – 10% Off on All Deals!",
        subTitle:
            "Promote your content now and get featured feedback before Sunday. (Utilize discount for fast, high-visibility placement.)",
        ontap: () {},
      ),
    ]);

    super.onInit();
  }
}
