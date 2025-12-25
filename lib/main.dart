import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:jconnect/app.dart';
import 'package:jconnect/features/home/notification/controller/notification_controller.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(NotificationController(), permanent: true);
  Get.put(MessagesController(), permanent: true);
  Stripe.publishableKey =
      'pk_test_51STA6VAXBWlDgH16B93sDb5ljUdMznqUvUctIchof13FERdETjlATINexABJmM7zmHq7oAfam4HSikD4zPBXgXrY00pmIwTyNE';
  await Stripe.instance.applySettings();

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
