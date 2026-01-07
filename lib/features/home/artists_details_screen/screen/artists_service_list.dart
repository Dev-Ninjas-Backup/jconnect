import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import 'package:jconnect/features/home/artists_details_screen/widgets/services.dart';

class ArtistsServiceList extends StatelessWidget {
  const ArtistsServiceList({super.key});

  @override
  Widget build(BuildContext context) {
      // var controller = Get.put(ArtistsDetailsController());
    var controller = Get.put(
      ArtistsDetailsController(
        networkClient: NetworkClient(
          onUnAuthorize: () {
            if (kDebugMode) {
              print("unauthorized");
            }
          },
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,

      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 14, vertical: 60),
        child: Column(
          children: [
            CustomAppBar2(
              title: "Service List",
              leadingIconUrl: Iconpath.backIcon,
              onLeadingTap: Get.back,
            ),
            SizedBox(height: 34.h),
            Services(controller: controller),
          ],
        ),
      ),
    );
  }
}
