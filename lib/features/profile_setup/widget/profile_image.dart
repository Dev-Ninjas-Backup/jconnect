import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/features/profile_setup/controller/profile_setup_controller.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.controller,
    required this.size,
  });

  final ProfileSetupController controller;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        final hasImage = controller.hasImage;
        final imageProvider = hasImage
            ? FileImage(File(controller.imagePath)) as ImageProvider
            : AssetImage(Imagepath.profileImage);
    
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: size.width * 0.18,
              backgroundImage: imageProvider,
              backgroundColor: Colors.transparent,
            ),
            Positioned(
              bottom: -12,
              right: size.width * 0.18 - 38,
              child: GestureDetector(
                onTap: controller.showImageSourceSheet,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.backGroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backGroundColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_a_photo,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
