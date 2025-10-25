import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  var isEmailSelected = true.obs;

  void selectEmail() => isEmailSelected.value = true;
  void selectPhone() => isEmailSelected.value = false;
}
