import 'package:get/instance_manager.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessagesController>(() => MessagesController(), fenix: true);
  }
}
