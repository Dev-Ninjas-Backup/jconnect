import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/app.dart';
import 'package:jconnect/features/home/notification/controller/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(NotificationController(), permanent: true);

  configEasyLoading();
  runApp(const MyApp());
}

void configEasyLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.grey
    ..textColor = Colors.white
    ..indicatorColor = Colors.white
    ..maskColor = Colors.green
    ..userInteractions = false
    ..dismissOnTap = false;
}
