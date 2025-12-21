class ProfileModel {
  final String name;
  final String imageUrl;
  final String shortbio;
  final int totaldeals;
  final double earnings;
  final double rating;
  final String? fullName;
  final String? phone;
  final List<SocialProfileModel>? socialProfiles;

  ProfileModel({
    required this.name,
    required this.imageUrl,
    required this.shortbio,
    required this.totaldeals,
    required this.earnings,
    required this.rating,
    this.fullName,
    this.phone,
    this.socialProfiles,
  });
}

class SocialLinkModel {
  final String platform;
  final String url;

  SocialLinkModel({required this.platform, required this.url});
}

class SocialProfileModel {
  final String? platformName;
  final String? platformLink;

  SocialProfileModel({this.platformName, this.platformLink});
}

class RateModel {
  final String title;
  final String description;
  final double price;

  RateModel({
    required this.title,
    required this.description,
    required this.price,
  });

  copyWith({required String title}) {}
}
