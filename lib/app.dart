import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:jconnect/core/binding/controller_binder.dart';
import 'package:jconnect/routes/approute.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
