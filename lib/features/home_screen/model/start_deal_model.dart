import 'package:flutter/material.dart';

class StartDealModel {
  final String title;
  final String subTitle;
  final VoidCallback ontap;

  StartDealModel({
    required this.title,
    required this.subTitle,
    required this.ontap,
  });
}
