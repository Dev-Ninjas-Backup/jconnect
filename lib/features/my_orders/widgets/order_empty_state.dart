import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/home/artists_screen/screen/artists_screen.dart';

class OrderEmptyState extends StatelessWidget {
  const OrderEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No active orders yet',
            style: getTextStyle(
              color: Colors.white,
              fontsize: 18,
              fontweight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start collaborating. Explore artists and services\nfrom the home feed.',
            textAlign: TextAlign.center,
            style: getTextStyle(color: Colors.white60),
          ),
          SizedBox(height: 20),
          CustomPrimaryButton(
            buttonText: 'Browse Artists',
            onTap: () {
              Get.to(ArtistsScreen());
            },
          ),
        ],
      ),
    );
  }
}
