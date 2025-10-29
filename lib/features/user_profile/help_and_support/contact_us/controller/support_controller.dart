import 'package:get/get.dart';
import '../model/support_message_model.dart';

class SupportController extends GetxController {
  var messages = <SupportMessageModel>[].obs;

  @override
  void onInit() {
    messages.add(
      SupportMessageModel(
        message: "Hey there 👋\nThanks for reaching out to DJ Connect Support.",
        isUser: false,
      ),
    );
    super.onInit();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add(SupportMessageModel(message: text.trim(), isUser: true));
  }
}
