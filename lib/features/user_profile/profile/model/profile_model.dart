class ProfileModel {
  final String name;
  final String imageUrl;
  final String shortbio;
  final String location;
  final List<String> hashtags; 
  final String username;
  final int totaldeals;
  final double earnings;
  final double rating;
  final String? fullName;
  final String? phone;
  final String?email;
  final List<SocialProfileModel>? socialProfiles;
  final List<String>? highlights;

  ProfileModel({
    required this.name,
    required this.imageUrl,
    required this.shortbio,
    required this.location,
    required this.hashtags,
    required this.username,
    required this.totaldeals,
    required this.earnings,
    required this.rating,
    this.fullName,
    this.phone,
    this.email,
    this.socialProfiles,
    this.highlights,
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
