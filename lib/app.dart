import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/binding/controller_binder.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/features/bottom_navbar/controller/bottom_navbar_controller.dart';
import 'package:jconnect/features/bottom_navbar/widgets/global_navbar_layout.dart';

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
          builder: (context, child) {
            child = EasyLoading.init()(context, child);
            return GlobalNavBarLayout(child: child);
          },
          routingCallback: (routing) {
            if (routing != null) {
              final navBarController = Get.put(NavBarController());
              final route = routing.current;
              
              final hiddenRoutes = [
                AppRoute.getSplashScreen(),
                AppRoute.getLoginScreen(),
                AppRoute.getSignupScreen(),
                AppRoute.getForgetPassword(),
                AppRoute.getOtpVerificationScreen(),
                AppRoute.getNewPasswordScreen(),
                AppRoute.getSignupOtpVerificationScreen(),
                AppRoute.getPhoneVerificationScreen(),
                AppRoute.getProfileSetupScreen(),
                AppRoute.getOnboardingScreen(),
              ];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navBarController.showNavBar.value = !hiddenRoutes.contains(route);
              });
            }
          },
          initialBinding: ControllerBinder(),
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
