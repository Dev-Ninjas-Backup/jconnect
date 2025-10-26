import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Center(
          child: Text(
            'Home Page',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}