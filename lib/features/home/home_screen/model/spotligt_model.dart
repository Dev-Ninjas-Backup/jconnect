import 'package:flutter/material.dart';

class SpotlightModel {
  final String? name;
  final String? followers;
  final IconData? platform;
  final String? avatarUrl;
  final bool? isVerified;

  SpotlightModel({
    this.name,
    this.followers,
    this.platform,
    this.avatarUrl,
    this.isVerified,
  });

  factory SpotlightModel.fromJson(Map<String, dynamic> json) {
    return SpotlightModel(
      name: json['name'] as String?,
      followers: json['followers'] as String?,
      platform: json['platform'] as IconData?,
      avatarUrl: json['avatarUrl'] as String?,
      isVerified: json['isVerified'] as bool?,
    );
  }
}
