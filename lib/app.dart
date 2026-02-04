import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:jconnect/core/binding/controller_binder.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/secrets/stripe_key.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // ✅ SAFE Stripe initialization
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Stripe.publishableKey =
          // 'pk_test_51STA6VAXBWlDgH16B93sDb5ljUdMznqUvUctIchof13FERdETjlATINexABJmM7zmHq7oAfam4HSikD4zPBXgXrY00pmIwTyNE';
          StripeKey.stripeKey;

      await Stripe.instance.applySettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoute.getSplashScreen(),
          getPages: AppRoute.routes,
          builder: EasyLoading.init(),
          initialBinding: ControllerBinder(),
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
